import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:model/components/drawer.dart';
import 'package:model/components/homeList.dart';
import 'package:model/constants/server.dart';
import 'package:model/models/activity.dart';
import 'package:model/state/auth_state.dart';
import 'package:model/state/models/auth_model.dart';

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

    List<Activity> activities = List<Activity>();
    int _currentIndex = 0;

    List<Widget> _children;

    void handleTapTab(int index) {
        this.setState(() {
            this._currentIndex = index;
        });
    }

    HomePageState() {
        this._children = [
            HomeList(this.activities),
            Text('Bye')
        ];

        this.fetchActivities();
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
                List<dynamic> activityMap = jsonDecode(response.body);
                activityMap.forEach((element) {
                    Activity activity = Activity.fromJson(element);

                    this.setState(() {
                        this.activities.add(activity);
                    });
                });
//            print(response.body);
            } else {
                print('bad request');
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        // ignore: close_sinks
        final AuthenticationBLoC authenticationBLoC =
            BlocProvider.of<AuthenticationBLoC>(context);

        return Scaffold(
            appBar: AppBar(
                title: Text('Home')
            ),
            drawer: BlocProvider.value(
                value: authenticationBLoC,
                child: DrawerNavigationWidget(),
            ),
            body: BlocProvider.value(
                value: authenticationBLoC,
//                child: this._children[this._currentIndex],
                child: this._currentIndex == 0 ? HomeList(this.activities) : Text('heyoas'),
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
            floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: Icon(Icons.add),
                backgroundColor: Colors.blue,
            ),
        );
    }
}