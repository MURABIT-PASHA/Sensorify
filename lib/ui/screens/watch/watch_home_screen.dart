import 'package:flutter/material.dart';
import 'package:sensorify/ui/screens/screen_controller.dart';

class WatchHomeScreen extends StatefulWidget {
  final ScreenController state;
  const WatchHomeScreen({Key? key, required this.state}) : super(key: key);

  @override
  State<WatchHomeScreen> createState() => _WatchHomeScreenState();
}

class _WatchHomeScreenState extends State<WatchHomeScreen> {

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Color backgroundColor = const Color(0xFF1C1C1E);
    return Scaffold(
      body: Container()
    );
  }
}
