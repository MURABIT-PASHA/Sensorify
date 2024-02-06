import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sensorify/constants.dart';
import 'package:sensorify/helpers/sensor_helper.dart';
import 'package:sensorify/models/record_settings_model.dart';
import 'package:sensorify/provider/socket_status_provider.dart';

class RecordingPage extends StatefulWidget {
  final RecordSettings settings;
  const RecordingPage({Key? key, required this.settings}) : super(key: key);

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  late Timer _timer;
  final RxInt _seconds = 0.obs;
  SensorManager sensorManager = SensorManager.instance;
  List<Stream> streamData = [];

  @override
  void initState() {
    final socketStatus =
    Provider.of<SocketStatusProvider>(context, listen: false);
    final int initialTimestamp = DateTime.now().millisecondsSinceEpoch;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds.value++;
    });
    widget.settings.selectedSensors.forEach((key, value) {
      if (value) {
        streamData.add(sensorManager.getStreamData(key));
      }
    });
    if (widget.settings.durationType.name == "ms") {
      sensorManager.sendData(
        hostAddress: socketStatus.socketAddress,
          initialTimestamp: initialTimestamp,
          duration: Duration(milliseconds: widget.settings.durationDelay),
          streamData: streamData);
    } else {
      sensorManager.sendData(
        hostAddress: socketStatus.socketAddress,
          initialTimestamp: initialTimestamp,
          duration: Duration(seconds: widget.settings.durationDelay),
          streamData: streamData);
    }
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    sensorManager.cancelSubscription();
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
    return Scaffold(
      body: Container(
        color: primaryBackgroundColor,
        child: Center(
          child: InkWell(
            onTap: () {
              // _bluetoothManager
              //     .sendMessage(MessageModel(orderType: MessageOrderType.stop));
              // Get.back(canPop: false);
            },
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
        ),
      ),
    );
  }
}
