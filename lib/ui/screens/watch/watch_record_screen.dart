import "package:flutter/material.dart";

class WatchRecordScreen extends StatefulWidget {
  final Duration duration;
  final List<String> sensorNames;
  const WatchRecordScreen(
      {Key? key, required this.duration, required this.sensorNames})
      : super(key: key);

  @override
  State<WatchRecordScreen> createState() => _WatchRecordScreenState();
}

class _WatchRecordScreenState extends State<WatchRecordScreen> {
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = const Color(0xFF1C1C1E);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: backgroundColor,
        alignment: Alignment.center,
        width: width,
        height: height,
      ),
    );
  }
}
