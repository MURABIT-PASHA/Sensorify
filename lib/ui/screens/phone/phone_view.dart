import 'package:flutter/material.dart';
import 'package:sensorify/ui/screens/phone/home_page.dart';
import 'package:sensorify/ui/screens/screen_controller.dart';

class PhoneView extends StatelessWidget {
  final ScreenController state;

  const PhoneView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
