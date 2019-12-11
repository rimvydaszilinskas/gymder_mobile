import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/models/activity.dart';
import 'package:model/state/auth_state.dart';

class HomeList extends StatelessWidget {
    final List<Activity> activities;

    HomeList(this.activities);

    @override
    Widget build(BuildContext context) {
        // ignore: close_sinks
        final AuthenticationBLoC authenticationBLoC = BlocProvider.of<AuthenticationBLoC>(context);

        List<Widget> cards = new List<Widget>();

        this.activities.forEach((element) {
            String individual = element.isGroup ? 'Group' : 'Individual';

            // Assemble the subtitle string of workout format and date
            String subtitle = individual + ' | '
                + element.time.year.toString() + '-'
                + element.time.month.toString() + '-'
                + element.time.day.toString();

            cards.add(
                Card(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            ListTile(
                                leading: Icon(Icons.album, size: 50),
                                title: Text(element.title),
                                subtitle: Text(subtitle),
                                onTap: () {
                                    Navigator.pushNamed(
                                        context, '/activity', arguments: {
                                            'user': authenticationBLoC.state.user,
                                            'activity': element
                                        });
                                },
                            )
                        ],
                    ),
                )
            );
        });

        return ListView(
            padding: EdgeInsets.all(8),
            children: cards
        );
    }
}