import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:model/constants/server.dart';
import 'package:model/models/user.dart';
import 'package:model/state/auth_state.dart';
import 'package:model/state/models/auth_model.dart';

class DrawerNavigationWidget extends StatelessWidget {
    /* Universal application side navigation
     * Always pass the AuthenticationBLoC
     * Navigation should be handled here
     */
    final FlutterSecureStorage storage = FlutterSecureStorage();
    AuthenticationBLoC authenticationBLoC;

    @override
    Widget build(BuildContext context) {
        this.authenticationBLoC =
            BlocProvider.of<AuthenticationBLoC>(context);

        return BlocBuilder<AuthenticationBLoC, AuthenticationModel> (
            bloc: authenticationBLoC,
            builder: (context, state) {
                return Drawer(
                    child: ListView(
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                            DrawerHeader(
                                margin: EdgeInsets.zero,
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                    color: Colors.blue
                                ),
                                child: Stack(
                                    children: <Widget>[
                                        Positioned(
                                            bottom: 12.0,
                                            left: 16.0,
                                            child: Text(
                                                '${state.user.firstName} ${state.user.lastName}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w600
                                                ),
                                            ),
                                        )
                                    ],
                                ),
                            ),
                            ListTile(
                                title: Row(
                                    children: <Widget>[
                                        Icon(Icons.home),
                                        Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Text('Home'),
                                        )
                                    ],
                                ),
                                onTap: () {},
                            ),
                            ListTile(
                                title: Row(
                                    children: <Widget>[
                                        Icon(Icons.person),
                                        Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Text('Profile'),
                                        )
                                    ],
                                ),
                                onTap: () {
                                    Navigator.pushNamed(context, '/profile', arguments: {
                                        'user': state.user,
                                    });
                                },
                            ),
                            ListTile(
                                title: Row(
                                    children: <Widget>[
                                        Icon(Icons.group),
                                        Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Text('Groups'),
                                        )
                                    ],
                                ),
                                onTap: () {
                                    Navigator.pushNamed(context, '/groups', arguments: {
                                        'user': state.user
                                    });
                                },
                            ),
                            Divider(),
                            ListTile(
                                title: Row(
                                    children: <Widget>[
                                        Icon(Icons.lock),
                                        Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Text('Logout'),
                                        )
                                    ],
                                ),
                                onTap: () {
                                    authenticationBLoC.add(AuthenticationStateEvent.logout);
                                },
                            )
                        ],
                    )
                );
            }
        );
    }
}
