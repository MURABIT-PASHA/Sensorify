import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensorify/backend/bluetooth_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../provider/bluetooth_status_provider.dart';

class ScanDialog extends StatefulWidget {
  final double width;
  final double height;
  const ScanDialog({Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  State<ScanDialog> createState() => _ScanDialogState();
}

class _ScanDialogState extends State<ScanDialog> {
  BluetoothManager bluetoothManager = BluetoothManager();

  Future<bool> _registerDeviceAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isDeviceExist", true);
    prefs.setString("deviceAddress", address);
    return true;
  }

  Future<List<Map<String, String>>> getScanResult() async {
    List<dynamic> dynamicData = await bluetoothManager.getData();
    List<Map<String, String>> scanResults = dynamicData.map((dynamic element) {
      String address = element["address"] ?? "";
      String name = element["name"] ?? "";

      return {"address": address, "name": name};
    }).toList();

    return scanResults;
  }

  Future<void> _refreshData() async {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    getScanResult();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothStatus = Provider.of<BluetoothStatusProvider>(context);
    final contextHeight = widget.height;
    final contextWidth = widget.width;

    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: SizedBox(
          height: contextHeight / 2,
          width: contextWidth,
          child: RefreshIndicator(
            onRefresh: () {
              return _refreshData();
            },
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getScanResult(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<Map<String, dynamic>> scanResults = snapshot.data ?? [];

                  return ListView.builder(
                    itemCount: scanResults.length,
                    itemBuilder: (BuildContext context, int index) {
                      String address = scanResults[index]["address"] ?? "";
                      String name = scanResults[index]["name"] ?? "";

                      return ListTile(
                        leading: Text("$address\n$name"),
                        onTap: () async {
                          await bluetoothManager
                              .connectToBluetoothDevice(address);
                          _registerDeviceAddress(address).then((value) {
                            Get.back();
                            bluetoothStatus.updateConnectionStatus(value);
                          });
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
