import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/pages/login.dart';
import 'package:model/pages/register.dart';
import 'package:model/state/auth_state.dart';
import 'package:model/state/models/auth_model.dart';

class Application extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        // ignore: close_sinks
        final AuthenticationBLoC authenticationBLoC =
            BlocProvider.of<AuthenticationBLoC>(context);

        return BlocBuilder<AuthenticationBLoC, AuthenticationModel> (
                bloc: authenticationBLoC,
                builder: (context, state) {
                    if(state.authState == AuthState.failed ||
                        state.authState == AuthState.loggedOut) {
                        return BlocProvider.value(
                            value: authenticationBLoC,
                            child: LoginPage()
                        );
                    } else if(state.authState == AuthState.none) {
                        authenticationBLoC.add(AuthenticationStateEvent.login);
                        return Text('Loading1');
                    } else if(state.authState == AuthState.loading) {
                        return Text('Loading2');
                    }
                    // Default return
                    return Text('Logged in');
                },
        );
    }
}