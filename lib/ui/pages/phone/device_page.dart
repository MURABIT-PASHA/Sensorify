import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sensorify/helpers/file_helper.dart';
import 'package:sensorify/helpers/sensor_helper.dart';
import 'package:sensorify/helpers/socket_helper.dart';
import 'package:sensorify/models/message_model.dart';
import 'package:sensorify/ui/pages/phone/credit_page.dart';
import 'package:sensorify/ui/pages/phone/record_settings_page.dart';
import 'package:sensorify/ui/pages/phone/recording_page.dart';
import 'package:sensorify/ui/pages/phone/training_page.dart';
import 'package:sensorify/provider/socket_status_provider.dart';
import 'package:sensorify/types.dart';
import 'package:sensorify/widgets/content_box.dart';
import 'package:sensorify/widgets/scan_dialog.dart';
import 'live_data_settings_page.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key}) : super(key: key);

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  SocketHelper socket = SocketHelper();
  SensorManager sensorManager = SensorManager.instance;
  FileManager fileManager = FileManager();
  late StreamSubscription messageSubscription;

  @override
  void initState() {
    super.initState();
    messageSubscription = socket.getStream().listen((message) {
      MessageModel model = MessageModel.fromJson(json.decode(message));
      handleMessage(model);
    });
  }

  @override
  void dispose() {
    messageSubscription.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> gridChildList = [
    {
      "name": "Live Data",
      "icon": Icons.multiline_chart,
      "onTapPage": const LiveDataSettingsPage(),
    },
    {
      "name": "Record",
      "icon": Icons.add_chart,
      "onTapPage": const RecordSettingsPage(),
    },
    {
      "name": "Training",
      "icon": Icons.cast_for_education,
      "onTapPage": const TrainingPage(),
    },
    {
      "name": "Credit",
      "icon": Icons.person,
      "onTapPage": const CreditPage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SocketStatusProvider>(context, listen: true);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: false,
              snap: false,
              pinned: true,
              expandedHeight: 120,
              collapsedHeight: 60,
              title: const Text("Sensorify"),
              actions: [
                IconButton(
                  onPressed: () {
                    if (provider.isSocketConnected) {
                      provider.updateConnectionStatus(false);
                    } else {
                      Get.defaultDialog(
                        title: "Socket URL",
                        content: ScanDialog(
                          width: MediaQuery.of(context).size.width - 100,
                          height: MediaQuery.of(context).size.height * 2 / 3,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.watch,
                    color:
                        provider.isSocketConnected ? Colors.green : Colors.red,
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  height: 120,
                  alignment: Alignment.bottomCenter,
                  child: const Text("Burada saat durum bilgileri yazar"),
                ),
              ),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .8,
                  crossAxisSpacing: 10),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return ContentBox(
                    width: width / 2 - 10,
                    name: gridChildList[index]["name"],
                    icon: gridChildList[index]["icon"],
                    onTap: () async {
                      Get.to(gridChildList[index]["onTapPage"]);
                    },
                  );
                },
                childCount: gridChildList.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleMessage(MessageModel model) {
    final socketStatus =
        Provider.of<SocketStatusProvider>(context, listen: false);
    switch (model.orderType) {
      case MessageOrderType.start:
        final settings = model.recordSettings;
        if (settings != null) {
          Get.to(() => RecordingPage(settings: settings));
        }
        break;
      case MessageOrderType.stop:
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
        } else {
          print("İPTALLLL");
          sensorManager.cancelSubscription();
        }
        break;
      case MessageOrderType.connect:
        // TODO: Handle this case.
        break;
    }
  }
}
