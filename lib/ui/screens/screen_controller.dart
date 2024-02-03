import 'package:flutter/material.dart';
import 'package:sensorify/helpers/pathfinder.dart';
import 'phone/phone_view.dart';
import 'watch/watch_view.dart';

class ScreenController extends State<Pathfinder> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 300) {
          return WatchView(this);
        } else {
          return PhoneView(this);
        }
      },
    );
  }
}
