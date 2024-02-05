import 'package:flutter/material.dart';
import 'package:sensorify/ui/pages/watch/watch_home_screen.dart';
import '../../theme/gradients/time_gradient.dart';
import '../screen_controller.dart';

class ActivePage extends StatelessWidget {
  final ScreenController state;

  const ActivePage(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: TimeGradient(
        child: HomePage(
          state: state,
        ),
      ),
    );
  }
}
