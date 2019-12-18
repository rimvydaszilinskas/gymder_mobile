import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:model/constants/server.dart';
import 'package:model/models/activity.dart';
import 'package:model/models/group.dart';
import 'package:model/models/membership.dart';
import 'package:model/models/post.dart';
import 'package:model/models/user.dart';

class GroupPreview extends StatefulWidget {
    final Group group;
    final User user;

    GroupPreview(this.group, this.user);

    @override
    State<StatefulWidget> createState() {
        return GroupPreviewState();
    }
}

class GroupPreviewState extends State<GroupPreview> {
    final FlutterSecureStorage storage = new FlutterSecureStorage();
    final TextEditingController postEntryController = new TextEditingController();

    List<Membership> memberships = List<Membership>();
    List<Post> posts = List<Post>();
    List<Activity> activities = List<Activity>();

    bool activitiesLoaded = false;
    bool membershipsLoaded = false;
    bool postsLoaded = false;
    bool allowPost = true;
    String membershipError;
    String postError;

    GroupPreviewState() {
        this.loadMemberships();
        this.loadPosts();
        this.loadActivities();
    }

    void loadActivities() async {
        String token = await this.storage.read(key: 'apiToken');

        Response response = await get(
            SERVERURL.GROUP_PREFIX + this.widget.group.uuid + '/activities/',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Token $token'
            }
        );

        if(response.statusCode == 200) {
            List<dynamic> activitiesJson = jsonDecode(response.body);

            activitiesJson.forEach((element) {
                print(element);
                Post post = Post.fromJson(element);

                this.setState(() {
                    this.posts.add(post);
                });
            });

            this.setState(() {
                this.postsLoaded = true;
            });
        } else {
            print('error loading');
        }
    }

    void loadMemberships() async {
        String token = await this.storage.read(key: 'apiToken');

        Response response = await get(
            SERVERURL.GROUP_PREFIX + this.widget.group.uuid + SERVERURL.GROUP_MEMBERSHIP_SUFFIX,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Token $token'
            }
        );

        if(response.statusCode == 200) {
            List<dynamic> membershipMap = jsonDecode(response.body);

            membershipMap.forEach((element) {
                Membership membership = Membership.fromJson(element);

                this.setState(() {
                    this.memberships.add(membership);
                });
            });

            this.setState(() {
                this.membershipsLoaded = true;
            });
        } else {
            this.setState(() {
                this.membershipError = 'Cannot load memberships';
                this.membershipsLoaded = true;
            });
        }
    }

    void loadPosts() async {
        String token = await this.storage.read(key: 'apiToken');

        Response response = await get(
            SERVERURL.GROUP_PREFIX + this.widget.group.uuid + '/posts/',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Token $token'
            }
        );

        if(response.statusCode == 200) {
            List<dynamic> postsJson = jsonDecode(response.body);

            postsJson.forEach((element) {
                Post post = Post.fromJson(element);

                this.setState(() {
                    this.posts.add(post);
                });
            });

            this.setState(() {
                this.postsLoaded = true;
            });
        } else {
            print('not ok');
        }
    }

    List<Widget> buildMemberships() {
        List<Widget> memberships = List<Widget>();

        if(this.membershipsLoaded && this.membershipError != null) {
            memberships.add(Center(
                child: Text('Can\'t load memberships'),
            ));
        } else if(this.membershipsLoaded) {
            this.memberships.forEach((membership) {
                Widget card = Card(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            ListTile(
                                leading: Icon(Icons.person),
                                title: Text(membership.user.username),
                                subtitle: Text(membership.user.email),
                                trailing: Text(membership.status),
                            )
                        ],
                    ),
                );

                memberships.add(card);
            });
        } else {
            memberships.add(Center(
                child: Text('Loading memberships'),
            ));
        }

        return memberships;
    }

    List<Widget> buildPosts() {
        List<Widget> posts = List<Widget>();

        posts.add(
            Card(
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
                                                color: Colors.white
                                            ),
                                        ),
                                        onPressed: this.allowPost ? this.createPost: null,
                                        color: Colors.blue
                                    )
                                ],
                            )
                        ],
                    ),
                ),
            )
        );

        if(!this.postsLoaded) {
            posts.add(
                Center(
                    child: Text('Loading'),
                )
            );
        } else if(this.posts.length == 0) {
            posts.add(
                Center(
                    child: Text('No posts'),
                )
            );
        } else {
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
        }

        return posts;
    }

    void createPost() async {
        if(this.postEntryController.text.length < 3) {
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

        if(token != null) {
            Response response = await post(
                SERVERURL.GROUP_PREFIX + this.widget.group.uuid + '/posts/',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Token $token'
                },
                body: jsonEncode({
                    'body': body
                })
            );

            if (response.statusCode == 201) {
                var postJson = jsonDecode(response.body);

                Post newPost = Post.fromJson(postJson);

                this.setState(() {
                    this.posts.insert(0, newPost);
                    this.allowPost = true;
                });

                this.postEntryController.text = '';
            } else {
                this.setState(() {
                    this.allowPost = true;
                    this.postError = 'Error while posting';
                });
            }
        }
    }

    List<Widget> buildActivities() {
        List<Widget> activities = List<Widget>();

        print(this.activities);

        if(this.activities.length == 0) {
            activities.add(
                Center(
                    child: Text('No activities'),
                )
            );
        }

        this.activities.forEach((element) {
            String individual = element.isGroup ? 'Group': 'Individual';

            String subtitle = individual + ' | '
                + element.time.year.toString() + '-'
                + element.time.month.toString() + '-'
                + element.time.day.toString();

            activities.add(
                Card(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            ListTile(
                                leading: Icon(Icons.album, size: 50),
                                title: Text(element.title),
                                subtitle: Text(subtitle),
                                onTap: () {
                                    Navigator.pushNamed(context, '/activity', arguments: {
                                        'user': this.widget.user,
                                        'activity': element
                                    });
                                },
                            )
                        ],
                    ),
                )
            );
        });

        return activities;
    }

    @override
    Widget build(BuildContext context) {
        return DefaultTabController(
            length: 3,
            child: Scaffold(
                appBar: AppBar(
                    title: Text(this.widget.group.title),
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
                                                leading: Icon(Icons.title),
                                                title: Text(this.widget.group.title)
                                            ),
                                            Divider(),
                                            ListTile(
                                                leading: Icon(Icons.description),
                                                title: Text(this.widget.group.description.length != 0 ? this.widget.group.description : 'No description'),
                                            ),
                                            Divider(),
                                            ListTile(
                                                leading: Icon(Icons.verified_user),
                                                title: Text('Created by ' + this.widget.group.user.username),
                                            ),
                                            Divider(),
                                            ListTile(
                                                leading: Icon(Icons.format_list_numbered),
                                                title: Text(this.membershipsLoaded ? this.memberships.length.toString() + ' memberships' : 'Loading'),
                                            ),
                                            Divider(),
                                        ],
                                    ),
                                ),
                                ...this.buildActivities()
                            ],
                        ),
                        ListView(
                            padding: EdgeInsets.all(8.0),
                            children: this.buildMemberships(),
                        ),
                        ListView(
                            padding: EdgeInsets.all(8.0),
                            children: this.buildPosts(),
                        )
                    ],
                ),
            ),
        );
    }
}
