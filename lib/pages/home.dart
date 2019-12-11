import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:model/components/drawer.dart';
import 'package:model/components/homeList.dart';
import 'package:model/constants/server.dart';
import 'package:model/models/activity.dart';
import 'package:model/models/user.dart';
import 'package:model/state/auth_state.dart';

class HomePage extends StatefulWidget {
    /* Home page
     * Displays the upcoming activities and search bar
     */
    @override
    State<StatefulWidget> createState() {
        return HomePageState();
    }
}

class HomePageState extends State<HomePage> {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    final TextEditingController searchEntryController = TextEditingController();
    final Geolocator geoLocator = Geolocator();
    User user;
    Position userPosition;

    List<Activity> activities = List<Activity>();
    int _currentIndex = 0;

    void handleTapTab(int index) {
        this.setState(() {
            this._currentIndex = index;
        });
    }

    HomePageState() {
        this.fetchActivities();
    }

    void search() async {
        List<Activity> activities = List<Activity>();
        String token = await this.storage.read(key: 'apiToken');

        String url;

        if (this.userPosition != null) {
            String longitude = this.userPosition.longitude.toStringAsPrecision(5);
            String latitude = this.userPosition.latitude.toStringAsPrecision(5);

            url = SERVERURL.NEARBY_ACTIVITIES + '?longitude=$longitude&latitude=$latitude';
        } else {
            String query = this.searchEntryController.text;
            url = SERVERURL.SEARCH_ACTIVITIES + '?query=$query';
        }

        var response = await get(
            url,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Token $token'
            }
        );

        if(response.statusCode == 200) {
            List<dynamic> jsonResponse = jsonDecode(response.body);

            jsonResponse.forEach((element) {
                Activity activity = Activity.fromJson(element);
                activities.add(activity);
            });
        }

       Navigator.pushNamed(context, '/activity/results', arguments: {
           'user': this.user,
           'activities': activities
       });
    }

    void fetchActivities() async {
        String token = await this.storage.read(key: 'apiToken');

        if (token != null) {
            var response = await get(
                SERVERURL.USER_ACTIVITIES,
                headers: {
                    'content-body': 'application/json',
                    'Authorization': 'Token $token'
                }
            );

            if (response.statusCode == 200) {
                this.activities.clear();
                
                List<dynamic> activityMap = jsonDecode(response.body);
                activityMap.forEach((element) {
                    Activity activity = Activity.fromJson(element);

                    this.setState(() {
                        this.activities.add(activity);
                    });
                });
            } else {
                print('bad request');
            }
        }
    }

    void geoLocate() async {
        this.userPosition = await this.geoLocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

        if (this.userPosition != null) {
            this.searchEntryController.text = this.userPosition.latitude.toString()
                + ', ' + this.userPosition.longitude.toString();
        }
    }

    @override
    Widget build(BuildContext context) {
        // ignore: close_sinks
        final AuthenticationBLoC authenticationBLoC =
            BlocProvider.of<AuthenticationBLoC>(context);

        this.user = authenticationBLoC.state.user;

        return Scaffold(
            appBar: AppBar(
                title: Text('Home'),
                actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: this.fetchActivities,
                    )
                ],
            ),
            drawer: BlocProvider.value(
                value: authenticationBLoC,
                child: DrawerNavigationWidget(),
            ),
            body: BlocProvider.value(
                value: authenticationBLoC,
                child: this._currentIndex == 0 ? HomeList(this.activities) : Container(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            TextField(
                                controller: this.searchEntryController,
                                decoration: InputDecoration(
                                    labelText: 'Search address, activity, etc..'
                                ),
                                onChanged: (text) {
                                    this.userPosition = null;
                                },
                                onTap: () {
                                    if(this.userPosition != null) {
                                        this.searchEntryController.text = '';
                                        this.userPosition = null;
                                    }
                                },
                            ),
                            RaisedButton(
                                child: Text(
                                    'Search',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0
                                    ),
                                ),
                                color: Colors.blue,
                                onPressed: this.search,
                            )
                        ],
                    ),
                ),
            ),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: this._currentIndex,
                onTap: this.handleTapTab,
                items: [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        title: Text('Home')
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.search),
                        title: Text('Find')
                    )
                ]
            ),
            floatingActionButton: this._currentIndex == 0 ? FloatingActionButton(
                onPressed: () {
                    Navigator.pushNamed(context, '/activity/create', arguments: {
                        'user': this.user
                    });
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.blue,
            ) : FloatingActionButton(
                child: Icon(Icons.location_on),
                backgroundColor: Colors.blue,
                onPressed: this.geoLocate,
            ),
        );
    }
}