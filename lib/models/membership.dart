import 'package:model/models/user.dart';

class Membership {
    String _uuid;
    String _status;
    User _user;
    String _membershipType;

    Membership(this._status, this._user, this._membershipType, {String uuid}) {
        this._uuid = uuid;
    }

    Membership.fromJson(Map<String, dynamic> json) {
        this._uuid = json['uuid'];
        this._status = json['status'];
        this._membershipType = json['membership_type'];
        if(json['user'] != null) {
            this._user = User.fromJson(json['user']);
        }
    }

    String get membershipType => _membershipType;

    set membershipType(String value) {
        _membershipType = value;
    }

    User get user => _user;

    set user(User value) {
        _user = value;
    }

    String get status => _status;

    set status(String value) {
        _status = value;
    }

    String get uuid => _uuid;

    set uuid(String value) {
        _uuid = value;
    }
}
