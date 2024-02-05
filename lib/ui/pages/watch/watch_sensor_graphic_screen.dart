import 'package:flutter/material.dart';
import 'package:sensorify/widgets/frosted_glass_box.dart';

class WatchSensorGraphicScreen extends StatefulWidget {
  final double width;
  final double height;
  final String sensorName;
  const WatchSensorGraphicScreen(
      {Key? key,
      required this.width,
      required this.height,
      required this.sensorName})
      : super(key: key);

  @override
  State<WatchSensorGraphicScreen> createState() =>
      _WatchSensorGraphicScreenState();
}

class _WatchSensorGraphicScreenState extends State<WatchSensorGraphicScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: FrostedGlassBox(
            width: widget.width,
            height: widget.height,
            child: Container(
              width: widget.width - 10,
              height: widget.height - 10,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }
}
