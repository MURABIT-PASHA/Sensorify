import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sensorify/constants.dart';
import 'package:sensorify/pages/live_data_page.dart';
import 'package:sensorify/types.dart';

class LiveDataSettingsPage extends StatefulWidget {
  const LiveDataSettingsPage({Key? key}) : super(key: key);

  @override
  State<LiveDataSettingsPage> createState() => _LiveDataSettingsPageState();
}

class _LiveDataSettingsPageState extends State<LiveDataSettingsPage> {
  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width / 2;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sensorify"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: getStyle(buttonWidth),
              onPressed: () {
                Get.to(
                    () => const LiveDataPage(type: SensorType.accelerometer));
              },
              child: const Text(
                "Accelerometer",
                style: TextStyle(color: buttonTextColor),
              ),
            ),
            ElevatedButton(
              style: getStyle(buttonWidth),
              onPressed: () {
                Get.to(() => const LiveDataPage(type: SensorType.gyroscope));
              },
              child: const Text(
                "Gyroscope",
                style: TextStyle(color: buttonTextColor),
              ),
            ),
            ElevatedButton(
              style: getStyle(buttonWidth),
              onPressed: () {
                Get.to(() => const LiveDataPage(type: SensorType.magnetometer));
              },
              child: const Text(
                "Magnetometer",
                style: TextStyle(color: buttonTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle getStyle(double width) {
    return ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      minimumSize: Size(width, 50),
      maximumSize: Size(width, 50),
    );
  }
}
