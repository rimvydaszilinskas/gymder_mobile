import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/app.dart';
import 'package:model/router.dart';
import 'package:model/state/auth_state.dart';

void main() => runApp(GymderApplication());

class GymderApplication extends StatelessWidget {
    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Gymder',
            theme: ThemeData(
                primarySwatch: Colors.blue,
            ),
            home: BlocProvider<AuthenticationBLoC> (
                builder: (context) => AuthenticationBLoC(),
                child: Application(),
            ),
            onGenerateRoute: Router.generateRoute,
        );
    }
}
