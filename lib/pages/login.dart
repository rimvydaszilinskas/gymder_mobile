import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:model/constants/server.dart';
import 'package:model/constants/styles.dart';
import 'package:model/state/auth_state.dart';

class LoginPage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() {
        return LoginPageState();
    }
}

class LoginPageState extends State<LoginPage> {
    final FlutterSecureStorage storage = new FlutterSecureStorage();
    final TextEditingController emailController = new TextEditingController();
    final TextEditingController passwordController = new TextEditingController();

    AuthenticationBLoC authenticationBLoC;

    String errorMessage;
    String emailErrorMessage;
    String passwordErrorMessage;

    LoginPageState() {
        this.errorMessage = null;
        this.emailErrorMessage = null;
        this.passwordErrorMessage = null;
    }

    void _handleLoginClick() async {
        print('click');
        bool error = false;

        this.setState(() {
            this.emailErrorMessage = null;
            this.passwordErrorMessage = null;
            this.errorMessage = null;
        });

        if(this.emailController.text.length < 8) {
            this.setState(() {
                this.emailErrorMessage = 'Please provide a valid email';
            });
            error = true;
        }

        if (this.passwordController.text.length < 6) {
            this.setState(() {
                this.passwordErrorMessage = 'Please provide a valid password';
            });
            error = true;
        }

        if (error)
            return;

        String body = jsonEncode({
            'email': emailController.text,
            'password': passwordController.text
        });

        var response = await post(
            SERVERURL.LOGIN,
            body: body,
            headers: {'content-type': 'application/json'}
        );

        if (response.statusCode == 200) {
            Map<String, dynamic> jsonResponse = jsonDecode(response.body);

            // Get the API token and store it
            String token = jsonResponse['token'];
            await this.storage.write(key: 'apiToken', value: token);

            if(this.authenticationBLoC != null) {
                // now try logging in via the bloc.
                // The token will be taken from the storage
                // This will automatically render anoher view if successful
                this.authenticationBLoC.add(AuthenticationStateEvent.login);
            }
        } else {
            this.setState(() {
                this.errorMessage = 'Wrong credentials';
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        this.authenticationBLoC = BlocProvider.of<AuthenticationBLoC>(context);

        return Scaffold(
            appBar: AppBar(
                title: Text('Login'),
            ),
            body: Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        TextField(
                            obscureText: false,
                            style: InputStyle,
                            textAlign: TextAlign.center,
                            controller: this.emailController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: 'Email',
                                errorText: this.emailErrorMessage,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                )
                            ),
                        ),
                        SizedBox(
                            height: 25.0,
                        ),
                        TextField(
                            obscureText: true,
                            style: InputStyle,
                            textAlign: TextAlign.center,
                            controller: this.passwordController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: 'Password',
                                errorText: this.passwordErrorMessage,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                )
                            ),
                        ),
                        SizedBox(
                            height: 25.0,
                        ),
                        this.errorMessage != null ? Text(
                            this.errorMessage,
                            style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.red
                            ),
                        ) : Text(''),
                        SizedBox(
                            height: 25.0,
                        ),
                        Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(30.0),
                            color: Colors.blueAccent,
                            child: MaterialButton(
                                minWidth: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                onPressed: this._handleLoginClick,
                                child: Text(
                                    'Login',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0
                                    ),
                                ),
                            )
                        )
                    ],
                ),
            ),
        );
    }
}