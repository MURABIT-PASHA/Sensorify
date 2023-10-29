import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sensorify/backend/bluetooth_manager.dart';
import 'package:sensorify/models/message_model.dart';
import 'package:sensorify/pages/credit_page.dart';
import 'package:sensorify/pages/live_data_page.dart';
import 'package:sensorify/pages/record_settings_page.dart';
import 'package:sensorify/pages/recording_page.dart';
import 'package:sensorify/pages/training_page.dart';
import 'package:sensorify/types.dart';
import 'package:sensorify/widgets/content_box.dart';
import 'package:sensorify/widgets/scan_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'live_data_settings_page.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key}) : super(key: key);

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  BluetoothManager bluetoothManager = BluetoothManager();
  final Rx<bool> _isDeviceRegistered = false.obs;
  final Rx<bool> _isConnected = false.obs;
  StreamController<String> messageStreamController = StreamController<String>();
  Stream<dynamic> get messageStream => bluetoothManager.getStream();

  List<Map<String, dynamic>> gridChildList = [
    {
      "name": "Live Data",
      "icon": Icons.multiline_chart,
      "onTapPage": LiveDataSettingsPage(),
    },
    {
      "name": "Record",
      "icon": Icons.add_chart,
      "onTapPage": RecordSettingsPage(),
    },
    {
      "name": "Training",
      "icon": Icons.cast_for_education,
      "onTapPage": TrainingPage(),
    },
    {
      "name": "Credit",
      "icon": Icons.person,
      "onTapPage": CreditPage(),
    },
  ];

  @override
  void initState() {
    messageStream.listen((message) {
      print(message.runtimeType);
      MessageModel model = MessageModel.fromJson(json.decode(message));
      if(model.orderType == MessageOrderType.record){
        // Kayıt gelmiştir bunu csv dosyamıza kaydedelim
      }
      else if(model.orderType == MessageOrderType.start){
        final settings = model.settings;
        if (settings != null){
          Get.to(()=>RecordingPage(settings: settings));
        }
      }
      else if(model.orderType == MessageOrderType.stop){
        // TODO: Devam eden kayıt varsa durdur. Provider kullan
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
              Obx(
                () => IconButton(
                    onPressed: () async {
                      if (_isDeviceRegistered.value == false) {
                        Get.defaultDialog(
                            title: 'Select your device',
                            content: ScanDialog(
                                height: height / 3 * 2, width: width - 100));
                      }
                    },
                    icon: Icon(
                      Icons.watch,
                      color: _isConnected.value ? Colors.green : Colors.red,
                    )),
              )
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
