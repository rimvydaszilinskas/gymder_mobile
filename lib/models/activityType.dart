class ActivityType {
    String _uuid;
    String _title;

    ActivityType(String title, {String uuid}) {
        this._title = title;
        this._uuid = uuid;
    }

    String get title => this._title;

    set title(String value) {
        this._title = value;
    }

    String get uuid => this._uuid;

    set uuid(String value) {
        this._uuid = value;
    }


}