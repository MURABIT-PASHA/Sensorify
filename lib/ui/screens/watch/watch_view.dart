import 'package:flutter/material.dart';
import '../screen_controller.dart';
import 'package:wear/wear.dart';
import 'watch_active_screen.dart';
import 'watch_ambient_screen.dart';

class WatchView extends StatelessWidget {
  final ScreenController state;

  const WatchView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (BuildContext context, WearShape shape, Widget? child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return mode == WearMode.active
                ? WatchActiveScreen(state)
                : WatchAmbientScreen(state);
          },
        );
      },
    );
  }
}
