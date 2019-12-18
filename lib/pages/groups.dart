import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:model/constants/server.dart';
import 'package:model/models/group.dart';
import 'package:model/models/user.dart';

class GroupList extends StatefulWidget {
    /* Group list of all groups of the user
     *
     */
    final User user;

    GroupList(this.user);

    @override
    State<StatefulWidget> createState() {
        return GroupListState();
    }
}

class GroupListState extends State<GroupList> {
    final FlutterSecureStorage storage = new FlutterSecureStorage();

    List<Group> groups = new List<Group>();
    bool loaded = false;
    String error;

    GroupListState() {
        this.loadGroups();
    }

    void loadGroups() async {
        String token = await this.storage.read(key: 'apiToken');

        Response response = await get(
            SERVERURL.USER_GROUPS,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Token $token'
            }
        );

        if(response.statusCode != 200) {
            this.setState(() {
                this.error = 'Cannot load groups';
                this.loaded = true;
            });

            return;
        } else {
            this.groups.clear();

            List<dynamic> groupMap = jsonDecode(response.body);

            groupMap.forEach((element) {
                Group group = Group.fromJson(element);

                this.setState(() {
                    this.groups.add(group);
                });
            });

            this.setState(() {
                this.loaded = true;
                this.error = null;
            });
        }
    }

    List<Widget> buildGroupsList() {
        List<Widget> groups = List<Widget>();

        if(this.groups.length == 0) {
            groups.add(
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                        Center(
                            child: Text('No activities'),
                        )
                    ],
                )
            );
        } else {
            this.groups.forEach((element) {
                Widget card = Card(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            ListTile(
                                leading: Icon(Icons.group),
                                title: Text(element.title),
                                subtitle: Text(
                                    element.public ? 'Public' : 'Private'),
                                onTap: () {
                                    Navigator.pushNamed(context, '/group', arguments: {
                                        'user': this.widget.user,
                                        'group': element
                                    });
                                },
                            )
                        ],
                    ),
                );

                groups.add(card);
            });
        }

        return groups;
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Groups'),
            ),
            body: this.loaded && this.error == null ? ListView(
                    children: this.buildGroupsList(),
                    padding: EdgeInsets.all(8.0),
                ) :Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    Center(
                        child: Text('Loading')
                    )
                ],
            )
        );
    }
}
