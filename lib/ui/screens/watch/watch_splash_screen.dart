import 'package:flutter/material.dart';
import 'package:sensorify/ui/screens/watch/watch_home_screen.dart';

import '../screen_controller.dart';

class WatchSplashScreen extends StatefulWidget {
  final ScreenController state;
  const WatchSplashScreen({Key? key, required this.state}) : super(key: key);

  @override
  State<WatchSplashScreen> createState() => _WatchSplashScreenState();
}

class _WatchSplashScreenState extends State<WatchSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  Color backgroundColor = const Color(0xFF0D1117);
  double opacityLevel = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        opacityLevel = 1.0;
      });
    });
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: const Offset(2.5, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            height: height/3,
            width: width - 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SlideTransition(
                  position: _animation,
                  child: Image.asset(
                    'assets/icons/logo.png',
                    height: 50.0,
                    width: 50.0,
                  ),
                ),
                AnimatedOpacity(
                    duration: const Duration(seconds: 2),
                    onEnd: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => WatchHomeScreen(
                                    state: widget.state,
                                  )),
                          (route) => false);
                    },
                    opacity: opacityLevel,
                    child: const Text(
                      "KONYA TECHNICAL\nUNIVERSITY",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Times New Roman",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10),
                    ))
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: height/3,
            width: width - 10,
            padding: const EdgeInsets.all(10),
            child: const Text(
              "SENSOR BOX",
              style: TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 9),
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: height/3,
            width: width - 10,
            padding: const EdgeInsets.all(10),
            child: const Text(
              "Created by MURABIT-PASHA",
              style: TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 9),
            ),
          )
        ],
      ),
    );
  }
}
