import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:model/constants/server.dart';
import 'package:model/models/activity.dart';
import 'package:model/models/post.dart';
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
    final TextEditingController postEntryController = TextEditingController();

    Activity activity;
    List<Post> posts;
    bool allowPost = true;
    String postError;

    ActivityPreviewState() {
        this.posts = new List<Post>();

        this.fetchRequests();
        this.fetchPosts();
    }
    
    void fetchRequests() async {
        String token = await this.storage.read(key: 'apiToken');
        
        if(token != null) {
            var response = await get(
                SERVERURL.USER_ACTIVITIES + this.widget.activity.uuid + '/',
                headers: {
                    'content-body': 'application/json',
                    'Authorization': 'Token $token'
                });

            if (response.statusCode == 200) {
                this.setState(() {
                    this.activity = Activity.fromJson(jsonDecode(response.body));
                });
            }
        }
    }

    void fetchPosts() async {
        String token = await this.storage.read(key: 'apiToken');

        if(token != null) {
            var response = await get(
                SERVERURL.USER_ACTIVITIES + this.widget.activity.uuid + '/posts/',
                headers: {
                    'content-type': 'application/json',
                    'Authorization': 'Token $token'
                });

            if (response.statusCode == 200) {
                List<dynamic> activityMap = jsonDecode(response.body);

                activityMap.forEach((element) {
                    Post post = Post.fromJson(element);

                    this.setState(() {
                        this.posts.add(post);
                    });
                });
            }
        }
    }

    void createPost() async {
        // Create post in the backend from the data entered in the field
        if (this.postEntryController.text.length < 3) {
            this.setState(() {
                this.postError = 'Post must be at least 3 characters long';
            });

            return;
        }

        this.setState(() {
            this.postError = null;
            this.allowPost = false;
        });

        String token = await this.storage.read(key: 'apiToken');

        String body = this.postEntryController.text.toString();

        if (token != null) {
            var response = await post(
                SERVERURL.USER_ACTIVITIES + this.widget.activity.uuid + '/posts/',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Token $token'
                },
                body: jsonEncode({
                    'body': body
                })
            );

            if (response.statusCode == 201) {
                var postJSON = jsonDecode(response.body);

                Post newPost = Post.fromJson(postJSON);

                this.setState(() {
                    this.posts.insert(0, newPost);
                    this.allowPost = true;
                });

                this.postEntryController.text = '';
            } else {
                this.setState(() {
                    this.allowPost = true;
                    this.postError = 'There was an error posting!';
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

    List<Widget> postsCards() {
        List<Widget> posts = List<Widget>();

        posts.add(Card(
            child: Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                    children: <Widget>[
                        Row(
                            children: <Widget>[
                                Expanded(
                                    child: TextField(
                                        controller: this.postEntryController,
                                        decoration: InputDecoration(
                                            labelText: 'Post',
                                            errorText: this.postError
                                        ),
                                    ),
                                ),
                                RaisedButton(
                                    child: Text(
                                        'Post',
                                        style: TextStyle(
                                            color: Colors.white,
                                        ),
                                    ),
                                    onPressed: this.allowPost ? this.createPost : null,
                                    color: Colors.blue,
                                )
                            ],
                        )
                    ],
                ),
            ),
        ));

        this.posts.forEach((post) {
            String subtitleLine = '${post.user.username} | ${post.datetime}';

            posts.add(Card(
               child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: <Widget>[
                       ListTile(
                           leading: Icon(Icons.person),
                           title: Text(post.body),
                           subtitle: Text(subtitleLine),
                       )
                   ],
               ),
            ));
        });

        return posts;
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
                        ListView(
                            padding: EdgeInsets.all(8.0),
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
                                                leading: Icon(Icons.location_on),
                                                title: Text(this.activity != null && this.activity.address != null ? this.activity.address.address : 'No location provided'),
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
                                                title: Text(this.widget.activity.description.length != 0 ? this.widget.activity.description : 'No description'),
                                            ),
                                        ],
                                    ),
                                ),
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
                        ListView(
                            padding: EdgeInsets.all(8),
                            children: this.postsCards(),
                        )
                    ],
                ),
            ),
        );
    }
}
