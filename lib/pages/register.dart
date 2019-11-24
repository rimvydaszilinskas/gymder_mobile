import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/constants/styles.dart';
import 'package:model/state/auth_state.dart';

class RegisterPage extends StatefulWidget {
    RegisterPage({var damn}) {
        print(damn);
    }

    @override
    State<StatefulWidget> createState() {
        return RegisterPageState();
    }
}

class RegisterPageState extends State<RegisterPage> {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Register'),
            ),
            body: Center(
                child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(30.0),
                    children: <Widget>[
                        TextField(
                            obscureText: false,
                            style: InputStyle,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: 'Email',
                                errorText: 'Error text',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                )
                            ),
                        ),
                        SizedBox(
                            height: 25.0,
                        ),
                    ],
                ),
            ),
        );
    }
}