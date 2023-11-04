import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sensorify/backend/bluetooth_manager.dart';
import 'package:sensorify/backend/sensor_manager.dart';
import 'package:sensorify/models/message_model.dart';
import 'package:sensorify/pages/credit_page.dart';
import 'package:sensorify/pages/record_settings_page.dart';
import 'package:sensorify/pages/recording_page.dart';
import 'package:sensorify/pages/training_page.dart';
import 'package:sensorify/provider/device_status_provider.dart';
import 'package:sensorify/types.dart';
import 'package:sensorify/widgets/content_box.dart';
import 'package:sensorify/widgets/scan_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backend/file_manager.dart';
import 'live_data_settings_page.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key}) : super(key: key);

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  BluetoothManager bluetoothManager = BluetoothManager();
  SensorManager sensorManager = SensorManager.instance;
  StreamController<String> messageStreamController = StreamController<String>();
  Stream<dynamic> get messageStream => bluetoothManager.getStream();

  FileManager fileManager = FileManager();

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
  void initState() {
    messageStream.listen((message) {
      MessageModel model = MessageModel.fromJson(json.decode(message));
      switch (model.orderType) {
        case MessageOrderType.start:
          final settings = model.settings;
          if (settings != null) {
            Get.to(() => RecordingPage(settings: settings));
          }
          break;
        case MessageOrderType.stop:
          print("kdjsfkldlkfjlk");
          sensorManager.cancelSubscription();
          fileManager.saveFileToDownloadsDirectory().then((value) {
            if (value) {
              Get.snackbar("x", "xxxxxxxxxxx");
            }
          });
          break;
        case MessageOrderType.record:
          final record = model.record;
          if (record != null) {
            if (record.save) {
              fileManager.saveRecord(record).then((value) => print(value));
            }
          }
          break;
        case MessageOrderType.watch:
          final settings = model.settings;
          if (settings != null) {
            settings.selectedSensors.forEach((key, value) {
              if (value) {
                final streamData = sensorManager.getStreamData(key);
                sensorManager.sendData(
                  initialTimestamp: DateTime.now().millisecondsSinceEpoch,
                  duration: const Duration(milliseconds: 500),
                  streamData: [streamData],
                  save: false,
                );
              }
            });
          }
          break;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    messageStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeviceStatusProvider>(context, listen: true);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
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
                onPressed: () async {
                  if (provider.isDeviceRegistered == false) {
                    Get.defaultDialog(
                        title: 'Select your device',
                        content: ScanDialog(
                            height: height / 3 * 2, width: width - 100));
                  } else {
                    final prefs = await SharedPreferences.getInstance();
                    if (prefs.getBool("isDeviceExist") ?? false) {
                      final address =
                          prefs.getString("deviceAddress") ?? "NULL";
                      if (address != "NULL") {
                        if (await bluetoothManager
                            .connectToBluetoothDevice(address)) {
                          provider.updateConnectionStatus(true);
                        }
                      }
                    }
                  }
                },
                icon: Icon(
                  Icons.watch,
                  color: provider.isDeviceConnected ? Colors.green : Colors.red,
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
                crossAxisCount: 2, childAspectRatio: .8, crossAxisSpacing: 10),
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
    );
  }
}
