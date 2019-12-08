import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/models/activity.dart';
import 'package:model/models/user.dart';
import 'package:model/state/auth_state.dart';

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
    @override
    Widget build(BuildContext context) {
        print(this.widget.activities);
        return Text('ok');
    }
}