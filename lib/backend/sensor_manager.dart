import 'package:sensors_plus/sensors_plus.dart';

class SensorManager {
  Stream<AccelerometerEvent> accelerometerEventListener() {
    return accelerometerEvents
        .map((event) => event)
        .handleError((error) {
      // Hata işleme mantığını burada ekleyin (varsa)
    });
  }

  Stream<UserAccelerometerEvent> userAccelerometerEventListener() {
    return userAccelerometerEvents
        .map((event) => event)
        .handleError((error) {
      // Hata işleme mantığını burada ekleyin (varsa)
    });
  }

  Stream<GyroscopeEvent> gyroscopeEventListener() {
    return gyroscopeEvents
        .map((event) => event)
        .handleError((error) {
      // Hata işleme mantığını burada ekleyin (varsa)
    });
  }

  Stream<MagnetometerEvent> magnetometerEventListener() {
    return magnetometerEvents
        .map((event) => event)
        .handleError((error) {
      // Hata işleme mantığını burada ekleyin (varsa)
    });
  }

}
