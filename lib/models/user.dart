class User {
    String _uuid;
    String _email;
    String _username;
    String _firstName;
    String _lastName;
    String _token;

    User({
        String uuid,
        String email,
        String username,
        String firstName,
        String lastName,
        String token}) {
        this._uuid = uuid;
        this._email = email;
        this._username = username;
        this._firstName = firstName;
        this._lastName = lastName;
        this._token = token;
    }

    User.fromJson(Map<String, dynamic> json):
            this._uuid = json['uuid'],
            this._email = json['email'],
            this._username = json['username'],
            this._firstName = json['first_name'],
            this._lastName = json['last_name'],
            this._token = json['token'];

    String get token => this._token;

    String get lastName => _lastName;

    String get firstName => _firstName;

    String get username => _username;

    String get email => _email;

    String get uuid => _uuid;

    set token(String value) {
        this._token = value;
    }

    set lastName(String value) {
        this._lastName = value;
    }

    set firstName(String value) {
        this._firstName = value;
    }

    set username(String value) {
        this._username = value;
    }

    set email(String value) {
        this._email = value;
    }

    set uuid(String value) {
        this._uuid = value;
    }
}