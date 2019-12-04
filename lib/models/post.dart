import 'package:model/models/user.dart';

class Post {
    String _uuid;
    String _body;
    DateTime _time;
    User _user;

    Post(this._body, this._time, this._user, {String uuid}) : this._uuid = uuid;

    Post.fromJson(Map<String, dynamic> json) {
        this._uuid = json['uuid'];
        this._body = json['body'];
        this._time = DateTime.parse(json['created_at']);
        this._user = User.fromJson(json['user']);
    }

    String get uuid => _uuid;

    set uuid(String value) {
        _uuid = value;
    }

    String get body => _body;

    set body(String value) {
        _body = value;
    }

    User get user => _user;

    set user(User value) {
        _user = value;
    }

    DateTime get time => _time;

    set time(DateTime value) {
        _time = value;
    }

    String get datetime {
        return this.time.year.toString() + '-'
            + this.time.month.toString() + '-'
            + this.time.day.toString() + ' '
            + this.time.hour.toString() + ':'
            + this.time.minute.toString();
    }
}
