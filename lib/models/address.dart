class Address {
    String _address;
    double _latitude;
    double _longitude;

    Address({String address, double latitude, double longitude}) {
        this._address = address;
        this._latitude = latitude;
        this._longitude = longitude;
    }

    double get longitude => this._longitude;

    set longitude(double value) {
        this._longitude = value;
    }

    double get latitude => this._latitude;

    set latitude(double value) {
        this._latitude = value;
    }

    String get address => this._address;

    set address(String value) {
        this._address = value;
    }

}