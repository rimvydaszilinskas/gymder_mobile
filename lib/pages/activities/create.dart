import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:model/constants/server.dart';
import 'package:model/constants/styles.dart';
import 'package:model/models/activity.dart';
import 'package:model/models/address.dart';
import 'package:model/models/post.dart';
import 'package:model/models/user.dart';

class CreateActivity extends StatefulWidget {
    final User user;

    CreateActivity(this.user);

    @override
    State<StatefulWidget> createState() {
        return CreateActivityState();
    }
}

class CreateActivityState extends State<CreateActivity> {
    final Geolocator geoLocator = Geolocator();
    final FlutterSecureStorage storage = FlutterSecureStorage();

    final TextEditingController titleEditingController = TextEditingController();
    final TextEditingController descriptionEditingController = TextEditingController();
    final TextEditingController addressEditingController = TextEditingController();
    final TextEditingController attendeeEditingController = TextEditingController();
    final TextEditingController durationEditingController = TextEditingController(text: 60.toString());

    String titleError;
    String addressError;
    String durationError;

    Position userPosition;
    bool requireApproval = false;
    bool public = true;
    DateTime dateTime;
    int numberOfAttendees = 1;
    Address address;

    bool addressOK = false;

    CreateActivityState() {
        this.attendeeEditingController.text = this.numberOfAttendees.toString();
    }

    void selectDateTime() async {
        final DateTime date = await showDatePicker(
            context: context,
            initialDate: DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 60 * 24 * 7),
            firstDate: DateTime.now(),
            lastDate: DateTime(2030),
        );

        if(date == null) {
            return;
        }

        final TimeOfDay time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now());

        this.setState(() {
            this.dateTime = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute);
        });
    }

    String formatDateTime() {
        List<String> weekdays = [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday'
        ];

        return '${weekdays[this.dateTime.weekday - 1]} at ${this.dateTime.hour}:${this.dateTime.minute} ${this.dateTime.year}-${this.dateTime.month}-${this.dateTime.day}';
    }

    void handleCreate() async {
        // Handle creation of the activity
        // If successful, navigate to the activity
        // First check all the fields
        String titleError;
        String addressError;
        String durationError;
        bool errors = false;
        int duration;

        String apiToken = await this.storage.read(key: 'apiToken');

        if(this.titleEditingController.text.length < 5) {
            errors = true;
            titleError = 'Title is too short';
        }

        if(this.addressEditingController.text.length < 5 && this.userPosition == null) {
            errors = true;
            addressError = 'Invalid address';
        }

        if(this.durationEditingController.text.length > 5 || this.durationEditingController.text.length < 1) {
            errors = true;
            durationError = 'Invalid duration';
        }

        try {
            duration = int.parse(this.durationEditingController.text);
        } catch(e) {
            errors = true;
            durationError = 'Invalid duration';
        }

        if(duration < 15 || duration > 600) {
            errors = true;
            durationError = 'Invalid duration';
        }


        this.setState(() {
            this.durationError = durationError;
            this.titleError = titleError;
            this.addressError = addressError;
        });

        if(errors)
            return;

        String URL = this.numberOfAttendees == 1 ? SERVERURL.INDIVIDUAL_ACTIVITIES : SERVERURL.GROUP_ACTIVITIES;
        var data = {
            'title': this.titleEditingController.text.toString(),
            'description': this.descriptionEditingController.text.toString(),
            'time': this.dateTime.toIso8601String(),
            'duration': duration,
            'public': this.public,
            'needs_approval': this.requireApproval,
            'max_attendees': this.numberOfAttendees
        };

        if (this.userPosition != null) {
            data.addAll({
                'latitude': this.userPosition.latitude.toString(),
                'longitude': this.userPosition.longitude.toString()
            });
        } else {
            data.addAll({
                'address_uuid': this.address.uuid
            });
        }
        var body = jsonEncode(data);

        Response response = await post(
            URL,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Token $apiToken'
            },
            body: body
        );

        if(response.statusCode == 201) {
            Activity activity = Activity.fromJson(jsonDecode(response.body));

            Navigator.popAndPushNamed(context, '/activity', arguments: {
                'user': this.widget.user,
                'activity': activity
            });
        } else {
            print(response.statusCode);
        }
    }

    void verifyAddress() async {
        String token = await this.storage.read(key: 'apiToken');

        if(this.addressEditingController.text.length < 5) {
            this.setState(() {
                this.addressError = 'Enter at least 5 characters';
            });
            return;
        }

        Response response = await post(
            SERVERURL.VERIFY_ADDRESS,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Token $token'
            },
            body: jsonEncode({
                'address': this.addressEditingController.text.toString()
            })
        );

        if(response.statusCode == 200) {
            List<dynamic> addressMap = jsonDecode(response.body);
            List<Address> options = List<Address>();
            List<Widget> selectOptions = List<Widget>();

            addressMap.forEach((element) {
                Address address = Address.fromJson(element);
                options.add(address);
                selectOptions.add(SimpleDialogOption(
                    child: Text(address.address),
                    onPressed: () {
                        this.setState(() {
                            this.address = address;
                            this.addressEditingController.text = this.address.address;
                            this.addressError = null;
                            this.addressOK = true;
                        });
                        Navigator.pop(context);
                    },
                ));
            });

            showDialog(
                context: context,
                child: SimpleDialog(
                    title: Text('Hello world'),
                    children: selectOptions
                ),
            );
        } else {
            print('Error');
        }
    }

    void geolocate() async {
        this.userPosition = await this.geoLocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);

        if(this.userPosition != null) {
            this.addressEditingController.text = this.userPosition.latitude.toString()
                + ', ' + this.userPosition.longitude.toString();

            this.setState(() {
                this.addressOK = true;
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Create a new activity'),
                actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.check),
                        onPressed: this.addressOK ? this.handleCreate : null,
                    ),
                ],
            ),
            body: Center(
                child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(30.0),
                    children: <Widget>[
                        Text(
                            'Title',
                            style: LabelStyle
                        ),
                        TextField(
                            obscureText: false,
                            style: InputStyle,
                            controller: this.titleEditingController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: 'Title',
                                errorText: this.titleError,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                )
                            ),
                        ),
                        SizedBox(
                            height: 25.0,
                        ),
                        Text(
                            'Description',
                            style: LabelStyle
                        ),
                        TextField(
                            obscureText: false,
                            style: TextStyle(
                                fontSize: 16.0,
                            ),
                            controller: this.descriptionEditingController,
                            textAlign: TextAlign.justify,
                            keyboardType: TextInputType.multiline,
                            maxLines: 10,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: 'Let users know about your activity',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0)
                                ),
                            ),
                        ),
                        SizedBox(
                            height: 25.0,
                        ),
                        Text(
                            'Address',
                            style: LabelStyle,
                        ),
                        TextField(
                            obscureText: false,
                            controller: this.addressEditingController,
                            onTap: () {
                                if(this.userPosition != null) {
                                    this.setState(() {
                                        this.userPosition = null;
                                        this.addressEditingController.text = '';
                                        this.addressOK = false;
                                    });
                                }
                            },
                            onChanged: (s) {
                                this.setState(() {
                                    this.addressOK = false;
                                });
                            },
                            style: TextStyle(
                                fontSize: 16.0,
                            ),
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: 'Where is the event happening?',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                ),
                                errorText: this.addressError,
                            ),
                        ),
                        RaisedButton(
                              child: Text(
                                  'Verify address',
                                  style: TextStyle(
                                      color: Colors.white,
                                  ),
                              ),
                            onPressed: this.userPosition == null ? !this.addressOK ? this.verifyAddress : null : null,
                            color: Colors.blue
                        ),
                        SizedBox(
                            height: 25.0,
                        ),
                        Text(
                            'Date & Time',
                            style: LabelStyle,
                        ),
                        Text(
                            this.dateTime != null ? this.formatDateTime() : '-',
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                            ),
                        ),
                        RaisedButton(
                            child: Text(
                                'Select date',
                                style: TextStyle(
                                    color: Colors.white
                                ),
                            ),
                            onPressed: this.selectDateTime,
                            color: Colors.blue,
                        ),
                        SizedBox(
                            height: 25.0,
                        ),
                        Divider(),
                        Text(
                            'More details about the event',
                            style: DividerTextStyle,
                        ),
                        Text(
                            'Number of attendees',
                            style: LabelStyle,
                        ),
                        TextField(
                            enabled: false,
                            controller: this.attendeeEditingController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                ),
                                helperText: 'Leave "1" to make it individual'
                            ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                                RaisedButton(
                                    child: Text(
                                        '+',
                                        style: TextStyle(
                                            color: Colors.white
                                        ),
                                    ),
                                    onPressed: () {
                                        this.setState(() {
                                            this.numberOfAttendees++;
                                            this.attendeeEditingController.text = this.numberOfAttendees.toString();
                                        });
                                    },
                                    color: Colors.green,
                                ),
                                SizedBox(width: 10.0),
                                RaisedButton(
                                    child: Text(
                                        '-',
                                        style: TextStyle(
                                            color: Colors.white
                                        ),
                                    ),
                                    onPressed: () {
                                        this.setState(() {
                                            if(this.numberOfAttendees > 1) {
                                                this.numberOfAttendees--;
                                                this.attendeeEditingController.text = this.numberOfAttendees.toString();
                                            }
                                        });
                                    },
                                    color: Colors.red,
                                ),
                            ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                                Checkbox(
                                    value: this.requireApproval,
                                    onChanged: (bool) {
                                        this.setState(() {
                                            this.requireApproval = bool;
                                        });
                                    },
                                ),
                                Text(
                                    'Require approval'
                                ),
                            ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                                Checkbox(
                                    value: this.public,
                                    onChanged: (bool) {
                                        this.setState(() {
                                            this.public = bool;
                                        });
                                    },
                                ),
                                Text(
                                    'Public'
                                ),
                            ],
                        ),
                        Text(
                            'Duration',
                            style: LabelStyle,
                        ),
                        TextField(
                            controller: this.durationEditingController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: 'Activity duration',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                ),
                                helperText: 'Duration is in minutes',
                                errorText: this.durationError,
                            ),
                        ),
                    ],
                ),
            ),
            floatingActionButton: FloatingActionButton(
                child: Icon(Icons.location_on),
                backgroundColor: Colors.blue,
                onPressed: this.geolocate,
            ),
        );
    }
}
