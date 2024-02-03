import 'package:flutter/material.dart';
import 'package:sensorify/ui/screens/watch/watch_sensor_graphic_screen.dart';
import 'package:sensorify/widgets/frosted_glass_box.dart';

class LiveSensorScreen extends StatefulWidget {
  final List<String> sensorNames;
  const LiveSensorScreen({Key? key, required this.sensorNames})
      : super(key: key);

  @override
  State<LiveSensorScreen> createState() => _LiveSensorScreenState();
}

class _LiveSensorScreenState extends State<LiveSensorScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    Color backgroundColor = const Color(0xFF1C1C1E);
    return Scaffold(
        body: Container(
      color: backgroundColor,
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
      alignment: Alignment.center,
      height: height,
      width: width,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.only(top:10),
              width: width,
              height: height,
              child: ListView.builder(
                itemCount: widget.sensorNames.length,
                itemBuilder: (BuildContext context, int index) {
                  return FrostedGlassBox(
                    width: width,
                    height: height / 3 - 10,
                    child: ListTile(
                      title: Text(
                        widget.sensorNames[index],
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => WatchSensorGraphicScreen(
                              height: height,
                              width: width,
                              sensorName: widget.sensorNames[index],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
