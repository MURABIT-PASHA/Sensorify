import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sensorify/backend/bluetooth_manager.dart';

class RecordSettingsPage extends StatefulWidget {
  const RecordSettingsPage({Key? key}) : super(key: key);

  @override
  State<RecordSettingsPage> createState() => _RecordSettingsPageState();
}

class _RecordSettingsPageState extends State<RecordSettingsPage> {
  BluetoothManager bluetoothManager = BluetoothManager();

  final Widget accelerometerIcon = SvgPicture.asset(
      "assets/icons/accelerometer.svg",
      semanticsLabel: 'Accelerometer Logo'
  );
  final Widget gyroscopeIcon = SvgPicture.asset(
      "assets/icons/gyroscope.svg",
      semanticsLabel: 'Gyroscope Logo'
  );
  final Widget magnetometerIcon = SvgPicture.asset(
      "assets/icons/magnetometer.svg",
      semanticsLabel: 'Magnetometer Logo'
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sensorify"),
      ),
      body: Column(
        children: [
          ElevatedButton(onPressed: (){
            bluetoothManager.sendMessage("record");
          }, child: Text("Test Bluetooth"))
        ],
      )
    );
  }
}
