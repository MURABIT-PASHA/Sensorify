import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(onPressed: (){
          Get.to(()=>LiveDataPage(type: SensorType.accelerometer));
        }, child: Text("Accelerometer"),),
        ElevatedButton(onPressed: (){
          Get.to(()=>LiveDataPage(type: SensorType.gyroscope));
        }, child: Text("Gyroscope"),),
        ElevatedButton(onPressed: (){
          Get.to(()=>LiveDataPage(type: SensorType.magnetometer));
        }, child: Text("Magnetometer"),),
      ],
    );
  }
}
