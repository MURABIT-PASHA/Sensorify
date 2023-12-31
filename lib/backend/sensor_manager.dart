import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/message_model.dart';
import '../models/record_model.dart';
import '../types.dart';
import 'bluetooth_manager.dart';

class SensorManager {
  SensorManager._privateConstructor();

  static final SensorManager _instance = SensorManager._privateConstructor();

  static SensorManager get instance => _instance;

  final BluetoothManager _bluetoothManager = BluetoothManager();

  StreamSubscription? _subscription;

  Stream<AccelerometerEvent> _accelerometerEventListener() {
    return accelerometerEvents.map((event) => event).handleError((error) {
      // Hata işleme mantığını burada ekleyin (varsa)
    });
  }

  Stream<GyroscopeEvent> _gyroscopeEventListener() {
    return gyroscopeEvents.map((event) => event).handleError((error) {
      // Hata işleme mantığını burada ekleyin (varsa)
    });
  }

  Stream<MagnetometerEvent> _magnetometerEventListener() {
    return magnetometerEvents.map((event) => event).handleError((error) {
      // Hata işleme mantığını burada ekleyin (varsa)
    });
  }

  /// Verilen [SensorType] ile ilgili veri akışını başlatır ve bir [Stream] döndürür.
  ///
  /// [type] parametresi, hangi sensör türünün veri akışının başlatılacağını belirtir.
  ///
  /// Geri dönen [Stream], belirtilen sensör türünden gelen verileri içerir.
  ///
  /// Örnek kullanım:
  ///
  /// ```dart
  /// Stream<dynamic> accelerometerStream = startStreamData(SensorType.accelerometer);
  ///
  /// accelerometerStream.listen((data) {
  ///   // Verileri işleme kodu burada
  /// });
  /// ```
  ///
  /// Daha fazla bilgi için [SensorType] ve sensör türlerine bakınız.
  Stream<dynamic> getStreamData(SensorType type) {
    switch (type) {
      case SensorType.accelerometer:
        return _accelerometerEventListener();
      case SensorType.gyroscope:
        return _gyroscopeEventListener();
      case SensorType.magnetometer:
        return _magnetometerEventListener();
    }
  }

  void sendData(
      {required int initialTimestamp,
      required Duration duration,
      required List<Stream> streamData,
      bool save = true}) {
    Stream combinedStream = MergeStream(streamData);
    _subscription = combinedStream
        .throttle((event) => TimerStream(true, duration))
        .listen((data) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      if (data is AccelerometerEvent) {
        final sensorData = RecordModel(
            initialName: "Accelerometer$initialTimestamp",
            sensorName: "Accelerometer",
            axisX: data.x,
            axisY: data.y,
            axisZ: data.z,
            timestamp: currentTime,
            save: save);
        _bluetoothManager.sendMessage(MessageModel(
            orderType: MessageOrderType.record, record: sensorData));
      } else if (data is GyroscopeEvent) {
        final sensorData = RecordModel(
            initialName: "Gyroscope$initialTimestamp",
            sensorName: "Gyroscope",
            axisX: data.x,
            axisY: data.y,
            axisZ: data.z,
            timestamp: currentTime,
            save: save);
        _bluetoothManager.sendMessage(MessageModel(
            orderType: MessageOrderType.record, record: sensorData));
      } else {
        final sensorData = RecordModel(
            initialName: "Magnetometer$initialTimestamp",
            sensorName: "Magnetometer",
            axisX: data.x,
            axisY: data.y,
            axisZ: data.z,
            timestamp: currentTime,
            save: save);
        _bluetoothManager.sendMessage(MessageModel(
            orderType: MessageOrderType.record, record: sensorData));
      }
    });
  }

  Future cancelSubscription() async {
    await _subscription?.cancel();
  }
}
