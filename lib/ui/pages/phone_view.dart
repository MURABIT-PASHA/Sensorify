import 'package:flutter/material.dart';
import 'package:sensorify/ui/pages/phone/home_page.dart';
import 'package:sensorify/ui/pages/screen_controller.dart';

class PhoneView extends StatelessWidget {
  final ScreenController state;

  const PhoneView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
