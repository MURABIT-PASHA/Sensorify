import 'dart:async';

extension StreamExtensions<T> on Stream<T> {
  Stream<T> waitress(Duration duration) {
    Timer? throttleTimer;
    StreamController<T> resultStreamController = StreamController<T>();

    listen((event) {
      if (throttleTimer == null || !throttleTimer!.isActive) {
        throttleTimer = Timer(duration, () {});
        resultStreamController.add(event);
      }
    });

    return resultStreamController.stream;
  }
}