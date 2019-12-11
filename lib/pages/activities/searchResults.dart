import 'package:flutter/material.dart';
import 'package:model/models/activity.dart';
import 'package:model/models/user.dart';

class SearchResultList extends StatefulWidget {
    final List<Activity> activities;
    final User user;

    SearchResultList(this.activities, this.user);

    @override
    State<StatefulWidget> createState() {
        return SearchResultListState();
    }
}

class SearchResultListState extends State<SearchResultList> {
    List<Widget> activities(BuildContext context) {
        List<Widget> activities = List<Widget>();

        this.widget.activities.forEach((element) {
            Widget card = Card(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        ListTile(
                            leading: Icon(Icons.directions_run),
                            title: Text(element.title),
                            subtitle: Text(element.address.address + (element.isGroup ? ' | Group': '')),
                            onTap: () {
                                Navigator.pushNamed(context, '/activity', arguments: {
                                    'user': this.widget.user,
                                    'activity': element
                                });
                            },
                        )
                    ],
                ),
            );
            activities.add(card);
        });

        activities.add(
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    Text(this.widget.activities.length.toString() + ' results')
                ],
            )
        );

        return activities;
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Search results'),
            ),
            body: ListView(
                padding: EdgeInsets.all(8.0),
                children: this.activities(context)
            ),
        );
    }
}
