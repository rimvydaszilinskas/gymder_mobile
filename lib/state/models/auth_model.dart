import 'package:model/models/user.dart';

enum AuthState {none, loading, authorized, failed, loggedOut}

class AuthenticationModel {
    /* Model only used by AuthenticationState BLoC
     * Please use AuthState enums to determine the state instead of classes
     */
    AuthState _authState;
    User _user;

    AuthenticationModel({AuthenticationModel obj}) {
        if (obj != null) {
            this._user = obj._user;
            this._authState = obj._authState;
        } else {
            this._authState = AuthState.none;
        }
    }

    get user => this._user;

    set user(User value) {
        this._user = value;
    }

    get authState => this._authState;

    set authState(AuthState value) {
        this._authState = value;
    }

    get token {
        if(this._user != null)
            return this._user.token;
        return null;
    }

    set token(String token) {
        if(this._user == null)
            this._user = User(token: token);
        else
            this._user.token = token;
    }
}
