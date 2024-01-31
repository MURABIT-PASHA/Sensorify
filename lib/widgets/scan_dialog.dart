import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensorify/backend/bluetooth_manager.dart';
import 'package:get/get.dart';
import '../provider/device_status_provider.dart';

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

  Future<List<Map<String, dynamic>>> getScanResult() async {
    return await bluetoothManager
        .scanBluetoothDevices(const Duration(seconds: 5));
  }

  Future<void> _refreshData() async {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceStatus = Provider.of<DeviceStatusProvider>(context);
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
                              .connectToBluetoothDevice(address)
                              .then((value) async {
                            if (value) {
                              deviceStatus.updateDeviceCharacteristics(await bluetoothManager.getCharacteristics(address));
                              deviceStatus
                                  .registerDeviceAddress(address)
                                  .then((value) {
                                Get.back();
                                deviceStatus.updateConnectionStatus(value);
                              });
                            }
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
