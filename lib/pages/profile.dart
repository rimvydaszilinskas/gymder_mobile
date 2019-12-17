import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:model/constants/server.dart';
import 'package:model/constants/styles.dart';
import 'package:model/models/user.dart';

class ProfilePreview extends StatefulWidget {
    /* View for previewing self profile
     * Pass the user as an argument in the router
     */
    final User user;

    ProfilePreview(this.user);

    @override
    State<StatefulWidget> createState() {
        return ProfilePreviewState(this.user);
    }
}

class ProfilePreviewState extends State<ProfilePreview> {
    final FlutterSecureStorage storage = new FlutterSecureStorage();
    final TextEditingController firstNameController = new TextEditingController();
    final TextEditingController lastNameController = new TextEditingController();

    String firstNameError;
    String lastNameError;
    String generalError;
    bool allowSave = true;

    ProfilePreviewState(User user) {
        this.firstNameController.text = user.firstName;
        this.lastNameController.text = user.lastName;
    }

    void saveChanges() async {
        this.setState(() {
            this.allowSave = false;
            this.generalError = null;
        });

        if(this.firstNameController.text.length < 3) {
            this.setState(() {
                this.firstNameError = 'Name should be at least 3 characters';
                this.allowSave = true;
            });
            return;
        } else {
            this.setState(() {
                this.firstNameError = null;
            });
        }

        if(this.lastNameController.text.length < 3) {
            this.setState(() {
                this.lastNameError = 'Last name should be at least 3 characters long';
                this.allowSave = true;
            });
            return;
        } else {
            this.setState(() {
                this.lastNameError = null;
            });
        }

        String token = await this.storage.read(key: 'apiToken');

        Response response = await post(
            SERVERURL.USER,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Token $token'
            },
            body: jsonEncode({
                'first_name': this.firstNameController.text,
                'last_name': this.lastNameController.text
            })
        );

        if(response.statusCode != 200) {
            this.setState(() {
                this.generalError = 'Something went wrong while updating';
            });
        }

        this.setState(() {
            this.allowSave = true;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(this.widget.user.email),
                actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.save),
                        onPressed: this.allowSave ? this.saveChanges : null,
                    )
                ],
            ),
            body: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(30.0),
                children: <Widget>[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Container(
                                width: 100.0,
                                height: 100.0,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(
                                            'https://gymder.appspot.com/static/images/default_profile.jpeg'
                                        )
                                    )
                                ),
                            ),
                            SizedBox(
                                height: 25.0,
                            ),
                            Text(
                                this.widget.user.username,
                                style: TextStyle(
                                    fontSize: 25.0
                                ),
                            ),
                        ],
                    ),
                    SizedBox(
                        height: 25.0,
                    ),
                    TextField(
                        obscureText: false,
                        style: InputStyle,
                        controller: this.firstNameController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            hintText: 'First Name',
                            errorText: this.firstNameError,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0)
                            )
                        ),
                    ),
                    SizedBox(
                        height: 25.0,
                    ),
                    TextField(
                        obscureText: false,
                        style: InputStyle,
                        controller: this.lastNameController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            hintText: 'Last Name',
                            errorText: this.lastNameError,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0)
                            )
                        ),
                    ),
                    SizedBox(
                        height: 25.0,
                    ),
                ],
            ),
        );
    }
}
