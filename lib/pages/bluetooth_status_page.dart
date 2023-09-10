import 'package:flutter/material.dart';

class BluetoothStatusPage extends StatelessWidget {
  const BluetoothStatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        Icon(
          Icons.bluetooth_disabled,
          color: Colors.grey,
          size: 100.0,
        ),
        Text("Bluetooth ve Lokasyonu açmanız gerekmekte")
      ],
    ));
  }
}
