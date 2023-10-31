import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sensorify/backend/bluetooth_manager.dart';
import 'package:sensorify/constants.dart';
import 'package:sensorify/models/message_model.dart';
import 'package:sensorify/models/record_model.dart';
import 'package:sensorify/models/settings_model.dart';
import 'package:sensorify/types.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../backend/sensor_manager.dart';

class RecordingPage extends StatefulWidget {
  final SettingsModel settings;
  const RecordingPage({Key? key, required this.settings}) : super(key: key);

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  late int initialTimestamp;
  late Timer _timer;
  final RxInt _seconds = 0.obs;
  SensorManager sensorManager = SensorManager();
  List<Stream> streamData = [];
  StreamSubscription? subscription;
  BluetoothManager bluetoothManager = BluetoothManager();

  Stream<dynamic> startStreamData(SensorType type) {
    switch (type) {
      case SensorType.accelerometer:
        return sensorManager.accelerometerEventListener();
      case SensorType.gyroscope:
        return sensorManager.gyroscopeEventListener();
      case SensorType.magnetometer:
        return sensorManager.magnetometerEventListener();
    }
  }

  void sendData(Duration duration) {
    for(var stream in streamData) {
      print(stream.runtimeType);
    }
    Stream combinedStream = MergeStream(streamData);
    subscription = combinedStream
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
            timestamp: currentTime);
        bluetoothManager.sendMessage(MessageModel(orderType: MessageOrderType.record, record: sensorData));
      } else if (data is GyroscopeEvent) {
        final sensorData = RecordModel(
            initialName: "Gyroscope$initialTimestamp",
            sensorName: "Gyroscope",
            axisX: data.x,
            axisY: data.y,
            axisZ: data.z,
            timestamp: currentTime);
        bluetoothManager.sendMessage(MessageModel(orderType: MessageOrderType.record, record: sensorData));
      } else {
        final sensorData = RecordModel(
            initialName: "Magnetometer$initialTimestamp",
            sensorName: "Magnetometer",
            axisX: data.x,
            axisY: data.y,
            axisZ: data.z,
            timestamp: currentTime);
        bluetoothManager.sendMessage(MessageModel(orderType: MessageOrderType.record, record: sensorData));
      }
    });
  }

  @override
  void initState() {
    initialTimestamp = DateTime.now().millisecondsSinceEpoch;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds.value++;
    });
    widget.settings.selectedSensors.forEach((key, value) {
      if (value) {
        streamData.add(startStreamData(key));
      }
    });
    if (widget.settings.durationType.name == "ms") {
      sendData(Duration(milliseconds: widget.settings.durationDelay));
    } else {
      sendData(Duration(seconds: widget.settings.durationDelay));
    }
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    if (subscription != null) {
      subscription!.cancel();
    }
    super.dispose();
  }

  String get timerString {
    int minutes = _seconds.value ~/ 60;
    int seconds = _seconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: primaryBackgroundColor,
      child: Center(
        child: InkWell(
          onTap: (){
            bluetoothManager.sendMessage(MessageModel(orderType: MessageOrderType.stop));
            Get.back(canPop: false);
          },
          child: Container(
            width: width / 2,
            height: width / 2,
            decoration: const BoxDecoration(
              color: buttonColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: width/2,
                child: Obx(
                  () => Text(
                    timerString,
                    style: const TextStyle(color: buttonTextColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
