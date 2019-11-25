import 'package:model/models/activity.dart';
import 'package:model/models/user.dart';

class Request {
    String uuid;
    User user;
    Activity activity;
    String status;

    Request(this.user, this.activity, this.status, {String uuid}) {
        this.uuid = uuid;
    }
}