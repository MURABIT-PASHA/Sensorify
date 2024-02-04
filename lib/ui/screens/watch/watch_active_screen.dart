import 'package:flutter/material.dart';
import 'package:sensorify/ui/screens/watch/watch_home_screen.dart';
import '../../theme/gradients/time_gradient.dart';
import '../screen_controller.dart';

class WatchActiveScreen extends StatelessWidget {
  final ScreenController state;

  const WatchActiveScreen(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: TimeGradient(
        child: WatchHomeScreen(
          state: state,
        ),
      ),
    );
  }
}
