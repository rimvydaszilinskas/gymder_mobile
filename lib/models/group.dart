import 'package:model/models/user.dart';

class Group {
    String _uuid;
    String _title;
    String _description;
    bool _public;
    bool _needsApproval;
    User _user;

    Group(this._title, this._description, this._public,
      this._needsApproval, this._user, {String uuid}) {
        this._uuid = uuid;
    }

    Group.fromJson(Map<String, dynamic> json) {
        this._uuid = json['uuid'];
        this._title = json['title'];
        this._description = json['description'];
        this._public = json['public'];
        this._needsApproval = json['needs_approval'];

        if(json['user'] != null)
            this._user = User.fromJson(json['user']);
    }

    User get user => _user;

    set user(User value) {
        _user = value;
    }

    bool get needsApproval => _needsApproval;

    set needsApproval(bool value) {
        _needsApproval = value;
    }

    bool get public => _public;

    set public(bool value) {
        _public = value;
    }

    String get description => _description;

    set description(String value) {
        _description = value;
    }

    String get title => _title;

    set title(String value) {
        _title = value;
    }

    String get uuid => _uuid;

    set uuid(String value) {
        _uuid = value;
    }
}