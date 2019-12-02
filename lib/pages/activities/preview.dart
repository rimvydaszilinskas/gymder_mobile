import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:model/constants/server.dart';
import 'package:model/models/activity.dart';
import 'package:model/models/request.dart' as gymder;
import 'package:model/models/user.dart';

class ActivityPreview extends StatefulWidget {
    final Activity activity;
    final User user;

    ActivityPreview(this.activity, this.user);

    @override
    State<StatefulWidget> createState() {
        return ActivityPreviewState();
    }
}

class ActivityPreviewState extends State<ActivityPreview> {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    Activity activity;

    ActivityPreviewState() {
        this.fetchRequests();
    }
    
    void fetchRequests() async {
        String token = await this.storage.read(key: 'apiToken');
        
        if(token != null) {
            var response = await get(
                SERVERURL.USER_ACTIVITIES + this.widget.activity.uuid + '/',
                headers: {
                    'content-body': 'application/json',
                    'Authorization': 'Token ${token}'
                });

            if (response.statusCode == 200) {
                this.setState(() {
                    this.activity = Activity.fromJson(jsonDecode(response.body));
                });
            }
        }
    }

    String defineStatus() {
        User user = this.widget.user;

        if(this.activity == null) {
            return null;
        }

        for(final request in this.activity.requests) {
            if (request.user.uuid != user.uuid) {
                continue;
            } else {
                return request.status;
            }
        }

        return null;
    }

    List<Widget> attendees() {
        List<Widget> attendees = List<Widget>();

        if(this.activity == null) {
            return attendees;
        }

        this.activity.requests.forEach((element) {
            Widget card = Card(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        ListTile(
                            leading: Icon(Icons.person),
                            title: Text(element.user.username),
                            subtitle: Text(element.user.email),
                            trailing: RaisedButton(
                                child: Text(
                                    'Hello world'
                                ),
                            ),
                        )
                    ],
                ),
            );

            attendees.add(card);
        });

        return attendees;
    }
    
    @override
    Widget build(BuildContext context) {
        bool isOwner = this.widget.activity.user.uuid == this.widget.user.uuid;
        String buttonStatus;
        bool buttonActive = false;

        if (!isOwner) {
            buttonActive = true;
            String status = this.defineStatus();

            if (status == 'denied') {
                buttonActive = false;
                buttonStatus = 'Denied';
            } else if(status == 'approved') {
                buttonActive = true;
                buttonStatus = 'Approved';
            } else if(status == 'pending') {
                buttonActive = true;
                buttonStatus = 'Pending';
            } else {
                buttonActive = true;
                buttonStatus = 'Join';
            }
        } else {
            buttonStatus = 'You\'re the organizer';
        }

        return DefaultTabController(
            length: 3,
            child: Scaffold(
                appBar: AppBar(
                    title: Text(this.widget.activity.title),
                    bottom: TabBar(
                        tabs: <Widget>[
                            Tab(icon: Icon(Icons.home)),
                            Tab(icon: Icon(Icons.group)),
                            Tab(icon: Icon(Icons.message)),
                        ],
                    ),
                ),
                body: TabBarView(
                    children: <Widget>[
                        Column(
                            // the main the view
                            children: <Widget>[
                                Card(
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                            ListTile(
                                                leading: Icon(Icons.directions_run),
                                                title: Text(this.widget.activity.title),
                                                subtitle: Text(this.widget.activity.datetime),
                                            ),
                                            Divider(),
                                            ListTile(
                                                leading: Icon(Icons.timer),
                                                title: Text(
                                                    'Duration: ' + (this.activity != null ? this.activity.duration.toString() + ' minutes': 'Fetching')),
                                            ),
                                            Divider(),
                                            ListTile(
                                                leading: Icon(Icons.people_outline),
                                                title: Text(
                                                    'Total requests: ' + (this.activity != null ? this.activity.requests.length.toString() : 'Fetching')),
                                            ),
                                            Divider(),
                                            ListTile(
                                                leading: Icon(Icons.people),
                                                title: Text(
                                                    'Approved requests: ' + (this.activity != null ? this.activity.approvedRequests.toString() + (this.activity.type == 'Group' ? '/' + this.activity.maxAttendees.toString() : '/1') : 'Fetching')),
                                            ),
                                            Divider(),
                                            ListTile(
                                                leading: Icon(Icons.info),
                                                title: Text(
                                                    'Activity type: ' + (this.activity != null ? this.activity.type : 'Fetching')),
                                            ),
                                            Divider(),
                                            ListTile(
                                                leading: Icon(Icons.description),
                                                title: Text(this.widget.activity.description),
                                            ),
                                        ],
                                    ),
                                ),
                                Spacer(),
                                Card(
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                            ListTile(
                                                leading: Icon(Icons.check),
                                                title: Text('Status')
                                            ),
                                            ButtonTheme.bar(
                                                child: ButtonBar(
                                                    children: <Widget>[
                                                        RaisedButton(
                                                            child: Text(buttonStatus, style: TextStyle(color: Colors.white),),
                                                            onPressed: buttonActive ? () {} : null,
                                                        )
                                                    ],
                                                ),
                                            )
                                        ],
                                    ),
                                )
                            ],
                        ),
                        ListView(
                            padding: EdgeInsets.all(8),
                            children: this.attendees()
                        ),
                        Text('Message')
                    ],
                ),
            ),
        );
    }
}
