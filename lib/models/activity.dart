import 'package:model/models/activityType.dart';
import 'package:model/models/address.dart';
import 'package:model/models/tag.dart';
import 'package:model/models/user.dart';

class Activity {
    String _uuid;
    String _title;
    String _description;
    bool _isGroup;
    DateTime _time;
    Address _address;
    ActivityType _activityType;
    int _duration;
    List<Tag> _tags;
    User _user;
    bool _public;
    bool _needsApproval;

    Activity(this._title, this._description, this._isGroup, this._time,
        this._address, this._activityType, this._duration, this._public,
        this._needsApproval, this._user, {String uuid})
        :this._uuid = uuid;

    Activity.fromJson(Map<String, dynamic> json){
        this._uuid = json['uuid'];
        this._title = json['title'];
        this._description = json['description'];
        this._isGroup = json['is_group'];
        this._time = DateTime.parse(json['time']);
        this._duration = json['duration'];
        this._user = User.fromJson(json['user']);
        this._public = json['public'];
        this._needsApproval = json['needs_approval'];
    }

    List<Tag> get tags => _tags;

    set tags(List<Tag> value) {
        _tags = value;
    }

    set addTag(Tag value) {
        _tags.add(value);
    }

    set addNewTag(String value) {
        _tags.add(new Tag(value));
    }

    int get duration => _duration;

    set duration(int value) {
        _duration = value;
    }

    ActivityType get activityType => _activityType;

    set activityType(ActivityType value) {
        _activityType = value;
    }

    Address get address => _address;

    set address(Address value) {
        _address = value;
    }

    DateTime get time => _time;

    set time(DateTime value) {
        _time = value;
    }

    bool get isGroup => _isGroup;

    set isGroup(bool value) {
        _isGroup = value;
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

    bool get needsApproval => _needsApproval;

    set needsApproval(bool value) {
        _needsApproval = value;
    }

    bool get public => _public;

    set public(bool value) {
        _public = value;
    }

    User get user => _user;

    set user(User value) {
        _user = value;
    }


}
