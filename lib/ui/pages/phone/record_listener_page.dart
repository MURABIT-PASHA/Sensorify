import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sensorify/constants.dart';
import 'package:sensorify/helpers/file_helper.dart';
import 'package:sensorify/helpers/socket_helper.dart';
import 'package:sensorify/models/message_model.dart';
import 'package:sensorify/provider/socket_status_provider.dart';
import 'package:sensorify/types.dart';
import 'package:sensorify/ui/pages/phone/device_page.dart';

class RecordListenerPage extends StatefulWidget {
  const RecordListenerPage({Key? key}) : super(key: key);

  @override
  State<RecordListenerPage> createState() => _RecordListenerPageState();
}

class _RecordListenerPageState extends State<RecordListenerPage> {
  late Timer _timer;
  final RxInt _seconds = 0.obs;
  late StreamSubscription messageSubscription;
  SocketHelper socket = SocketHelper();
  FileManager fileManager = FileManager();

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds.value++;
    });
    messageSubscription = socket.getStream().listen((message) {
      MessageModel model = MessageModel.fromJson(json.decode(message));
      handleMessage(model);
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    messageSubscription.cancel();
    super.dispose();
  }

  String get timerString {
    int minutes = _seconds.value ~/ 60;
    int seconds = _seconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final socketStatus =
        Provider.of<SocketStatusProvider>(context, listen: false);
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: primaryBackgroundColor,
        child: Center(
          child: InkWell(
            onTap: () {
              SocketHelper.sendMessage(
                  MessageModel(orderType: MessageOrderType.stop),
                  socketStatus.socketAddress);
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

  void handleMessage(MessageModel model) {
    if (model.orderType == MessageOrderType.stop) {
      fileManager.saveFileToDownloadsDirectory().then((value) {
        if (value) {
          Get.snackbar("Başarılı", "Kayıtlar indirildi");
        } else {
          Get.snackbar("Hata", "Kayıt izni bulunamadı");
        }
        Get.offAll(const DevicePage());
      });
    } else if (model.orderType == MessageOrderType.record) {
      final record = model.record;
      if (record != null) {
        if (record.save) {
          fileManager.saveRecord(record).then((value) {});
        }
      }
    }
  }
}
