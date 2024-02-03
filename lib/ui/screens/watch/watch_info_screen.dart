import 'package:flutter/material.dart';
import 'package:sensorify/widgets/frosted_glass_box.dart';


class WatchInfoScreen extends StatefulWidget {
  final int code;
  const WatchInfoScreen({Key? key, required this.code}) : super(key: key);

  @override
  State<WatchInfoScreen> createState() => _WatchInfoScreenState();
}

class _WatchInfoScreenState extends State<WatchInfoScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Color backgroundColor = const Color(0xFF1C1C1E);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        alignment: Alignment.center,
        child: FrostedGlassBox(
          height: height - 20,
          width: width - 10,
          child: Container(
            alignment: Alignment.center,
              child: Text("Your watch code is:\n${widget.code}",textAlign: TextAlign.center, style: TextStyle(color: Colors.white),)),
        ),
      ),
    );
  }
}
