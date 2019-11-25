import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:model/models/activity.dart';

class HomeList extends StatelessWidget {
    final List<Activity> activities;

    HomeList(this.activities);

    @override
    Widget build(BuildContext context) {
        print(this.activities.length);
        List<Widget> cards = new List<Widget>();

        this.activities.forEach((element) {
            print(element.time);
            String individual = element.isGroup ? 'Group' : 'Individual';
            cards.add(
                Card(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            ListTile(
                                leading: Icon(Icons.album, size: 50),
                                title: Text(element.title),
                                subtitle: Text(individual),
                                onTap: () {},
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