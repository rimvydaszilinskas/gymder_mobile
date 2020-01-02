class Tag {
    String _uuid;
    String _title;

    Tag(this._title, {String uuid})
        : this._uuid = uuid;

    Tag.fromJson(Map<String, dynamic> json) {
        this._uuid = json['uuid'];
        this._title = json['title'];
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
