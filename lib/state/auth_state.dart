import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:model/constants/server.dart';
import 'package:model/models/user.dart';
import 'package:model/state/models/auth_model.dart';

enum AuthenticationStateEvent {logout, login}

class AuthenticationBLoC extends Bloc<AuthenticationStateEvent, AuthenticationModel> {
    /* Business Logic Component AKA State
     * This component is used throughout the application to determine the user
     * in the system
     */
    final FlutterSecureStorage storage = new FlutterSecureStorage();

    @override
    AuthenticationModel get initialState => AuthenticationModel();

    @override
    Stream<AuthenticationModel> mapEventToState(AuthenticationStateEvent event) async* {
        // Handling event here
        switch(event) {
            case AuthenticationStateEvent.login:
                // First check if the state is already authorized
                if(this.state.authState == AuthState.authorized) {
                    // If already authorized do nothing
                    yield this.state;
                    break;
                }

                AuthenticationModel copyOfState = this.state;
                copyOfState.authState = AuthState.loading;

                yield AuthenticationModel(obj: copyOfState);

                String token = await this.storage.read(key: 'apiToken');

                if (token == null) {
                    // If token is null we cannot access backend and
                    // the authentication is failed
                    copyOfState.authState = AuthState.failed;
                    yield AuthenticationModel(obj: copyOfState);
                    break;
                }

                var response = await get(
                    SERVERURL.AUTHENTICATION_PING,
                    headers: {
                        'content-body': 'application/json',
                        'Authorization': 'Token ${token}'
                    }
                );

                if (response.statusCode != 200) {
                    // server should always return 200 if authorization is
                    // successful, otherwise it's an authentication failure
                    // Delete token, because it is not correct
                    await this.storage.delete(key: 'apiToken');
                    copyOfState.authState = AuthState.failed;
                    yield AuthenticationModel(obj: copyOfState);
                    break;
                } else {
                    // Here we use dynamic as some of the fields may come as
                    // arrays, objects, or something else
                    Map<String, dynamic> jsonResponse = jsonDecode(
                        response.body);

                    copyOfState.user = User(
                        email: jsonResponse['email'],
                        username: jsonResponse['username'],
                        firstName: jsonResponse['first_name'],
                        lastName: jsonResponse['last_name'],
                        uuid: jsonResponse['uuid'],
                        token: token);

                    copyOfState.authState = AuthState.authorized;

                    yield AuthenticationModel(obj: copyOfState);
                    break;
                }
                break;
            case AuthenticationStateEvent.logout:
                // If logout action is dispatched, delete the apiToken from
                // secure storage and clear the state
                AuthenticationModel copyOfState = this.state;

                await this.storage.delete(key: 'apiToken');

                copyOfState.user = null;
                copyOfState.authState = AuthState.loggedOut;

                yield AuthenticationModel(obj: copyOfState);
                break;
        }
    }
}
