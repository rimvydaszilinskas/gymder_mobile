# Gymder mobile app

Gymder mobile application developed using Flutter and Dart

## Setup

### Install Flutter

1. Download a stable version of Flutter

```
$ wget https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v1.12.13+hotfix.5-stable.tar.xz
```

2. Extract the archive

```sh
$ tar xf flutter_linux_v1.12.13+hotfix.5-stable.tar.xz
```

3. Add Flutter to your path:

```sh
$ export PATH="$PATH:`pwd`/flutter/bin"
```

4. Verify that Flutter is installed

```sh
which flutter
```

5. Try running Flutter doctor to see if you need to install extra dependencies

```sh
$ flutter doctor
```

If all goes well you should receive all tests have succeeded.

### Install dependencies

Please install dependencies before running the application using the following command:

```sh
flutter pub get
```

## Running

Before running the application, start a simulator or connect your device via USB and enable developer options and USB debugging. After that try running the following command to verify that you are all setup  for to run the application:

```
flutter doctor
```

If all the checks run successfully, you are ready to run the application:

```
flutter run
```

