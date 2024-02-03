import 'package:flutter/material.dart';
import 'package:sensorify/ui/screens/watch/watch_record_screen.dart';
import 'package:sensorify/widgets/frosted_glass_box.dart';

class WatchSensorTimerScreen extends StatefulWidget {
  final List<String> sensorNames;
  const WatchSensorTimerScreen({Key? key, required this.sensorNames})
      : super(key: key);

  @override
  State<WatchSensorTimerScreen> createState() => _WatchSensorTimerScreenState();
}

class _WatchSensorTimerScreenState extends State<WatchSensorTimerScreen> {
  Duration _duration = const Duration(milliseconds: 0);
  int _durationDelay = 0;
  String _durationType = "ms";
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Color backgroundColor = const Color(0xFF1C1C1E);
    return Scaffold(
      body: Container(
        color: backgroundColor,
        width: width,
        height: height,
        padding: const EdgeInsets.all(5),
        child: ListView(
          children: [
            FrostedGlassBox(
              width: width - 10,
              height: height / 2,
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: width - 70,
                      height: 30,
                      child: TextField(
                        onChanged: (value) {
                          try {
                            _durationDelay = int.parse(value);
                          } catch (exception) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Wrong argument")));
                          }
                        },
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            hintText: "Time delay",
                            hintStyle: const TextStyle(
                                color: Colors.white12,
                                fontStyle: FontStyle.italic)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    DropdownButton(
                        items: const [
                          DropdownMenuItem(
                            value: "ms",
                            child: Text("ms"),
                          ),
                          DropdownMenuItem(
                            value: "s",
                            child: Text("s"),
                          )
                        ],
                        onChanged: (value) {
                          _durationType = value ?? "ms";
                        }),
                  ],
                ),
              ),
            ),
            FrostedGlassBox(
              width: width - 10,
              height: height / 3 - 5,
              child: ListTile(
                leading: const Icon(
                  Icons.start,
                  color: Colors.white,
                ),
                title: const Text(
                  "Start",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => WatchRecordScreen(
                          duration: _duration, sensorNames: widget.sensorNames),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void lastCheck() {
    if (_durationDelay == 0) {
      _durationDelay = 1;
      _duration = Duration(seconds: _durationDelay);
    }
    switch (_durationType) {
      case "ms":
        _duration = Duration(milliseconds: _durationDelay);
        break;
      case "s":
        _duration = Duration(seconds: _durationDelay);
        break;
      default:
        _duration = const Duration(seconds: 1);
    }
  }
}
