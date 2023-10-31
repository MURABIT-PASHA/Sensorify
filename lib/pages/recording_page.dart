import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sensorify/constants.dart';
import 'package:sensorify/models/settings_model.dart';
import 'package:sensorify/types.dart';

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
    Stream combinedStream = MergeStream(streamData);
    subscription =
        combinedStream.throttle((event) => TimerStream(true, duration))
            .listen((data) {
              print(data);
              print(data.runtimeType);
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
    if(subscription!=null){
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
        child: Container(
          width: width / 2,
          height: width / 2,
          decoration: const BoxDecoration(
            color: buttonColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Obx(
              () => Text(
                timerString,
                style: const TextStyle(color: buttonTextColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
