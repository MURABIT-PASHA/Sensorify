import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:sensorify/constants.dart';
import 'package:sensorify/helpers/file_helper.dart';
import 'package:sensorify/helpers/sensor_helper.dart';
import 'package:sensorify/helpers/socket_helper.dart';
import 'package:sensorify/models/message_model.dart';
import 'package:sensorify/provider/socket_status_provider.dart';
import 'package:sensorify/types.dart';
import 'package:sensorify/ui/pages/phone/recording_page.dart';

class ListenerPage extends StatefulWidget {
  const ListenerPage({super.key});

  @override
  State<ListenerPage> createState() => _ListenerPageState();
}

class _ListenerPageState extends State<ListenerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  SocketHelper socket = SocketHelper();
  SensorManager sensorManager = SensorManager.instance;
  StreamController<String> messageStreamController = StreamController<String>();
  Stream<dynamic> get messageStream => socket.getStream();
  FileManager fileManager = FileManager();

  @override
  void initState() {
    startAnimation();
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: primaryBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Builder(
          builder: (context) {
            final socketStatus =
            Provider.of<SocketStatusProvider>(context, listen: false);
            messageStream.listen((message) {
              MessageModel model = MessageModel.fromJson(json.decode(message));
              switch (model.orderType) {
                case MessageOrderType.start:
                  final settings = model.recordSettings;
                  if (settings != null) {
                    Get.to(() => RecordingPage(settings: settings));
                  }
                  break;
                case MessageOrderType.stop:
                  sensorManager.cancelSubscription();
                  fileManager.saveFileToDownloadsDirectory().then((value) {
                    if (value) {
                      Get.snackbar("Başarılı", "Kayıtlar indirildi");
                    } else {
                      Get.snackbar("Hata", "Kayıt izni bulunamadı");
                    }
                  });
                  break;
                case MessageOrderType.record:
                  final record = model.record;
                  if (record != null) {
                    if (record.save) {
                      fileManager.saveRecord(record).then((value) {});
                    }
                  }
                  break;
                case MessageOrderType.watch:
                  final settings = model.recordSettings;
                  if (settings != null) {
                    settings.selectedSensors.forEach((key, value) {
                      if (value) {
                        final streamData = sensorManager.getStreamData(key);
                        sensorManager.sendData(
                          hostAddress: socketStatus.socketAddress,
                          initialTimestamp: DateTime.now().millisecondsSinceEpoch,
                          duration: const Duration(milliseconds: 500),
                          streamData: [streamData],
                          save: false,
                        );
                      }
                    });
                  }
                  else{
                    sensorManager.cancelSubscription();
                    break;
                  }
                  break;
                case MessageOrderType.connect:
                // TODO: Handle this case.
                  break;
              }
            });
            return AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [secondaryForegroundColor, warningColor],
                      begin: _topAlignmentAnimation.value,
                      end: _bottomAlignmentAnimation.value,
                    ),
                  ),
                  child: Center(
                    child: Lottie.asset('assets/lotties/sensorify.json')
                  ),
                );
              },
            );
          }
        ),
      ),
    );
  }

  void startAnimation() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    _topAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(
                begin: Alignment.topLeft, end: Alignment.topRight),
            weight: 1),
        TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(
                begin: Alignment.topRight, end: Alignment.bottomRight),
            weight: 1),
        TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(
                begin: Alignment.bottomRight, end: Alignment.bottomLeft),
            weight: 1),
        TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(
                begin: Alignment.bottomLeft, end: Alignment.topLeft),
            weight: 1),
      ],
    ).animate(_controller);
    _bottomAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(
                begin: Alignment.bottomRight, end: Alignment.bottomLeft),
            weight: 1),
        TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(
                begin: Alignment.bottomLeft, end: Alignment.topLeft),
            weight: 1),
        TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(
                begin: Alignment.topLeft, end: Alignment.topRight),
            weight: 1),
        TweenSequenceItem<Alignment>(
            tween: Tween<Alignment>(
                begin: Alignment.topRight, end: Alignment.bottomRight),
            weight: 1),
      ],
    ).animate(_controller);

    _controller.repeat();
  }
}
