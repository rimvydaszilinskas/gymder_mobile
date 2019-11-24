class Tag {
    String _uuid;
    String _title;

    Tag(this._title, {String uuid})
        : this._uuid = uuid;

    String get title => this._title;

    set title(String value) {
        this._title = value;
    }

    String get uuid => this._uuid;

    set uuid(String value) {
        this._uuid = value;
    }
}