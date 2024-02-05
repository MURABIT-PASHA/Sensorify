import 'package:flutter/material.dart';
import 'package:sensorify/ui/pages/watch/watch_sensor_timer.dart';
import 'package:sensorify/widgets/frosted_glass_box.dart';

class WatchSaveSensorScreen extends StatefulWidget {
  final List<String> sensorNames;
  const WatchSaveSensorScreen({Key? key, required this.sensorNames})
      : super(key: key);

  @override
  State<WatchSaveSensorScreen> createState() => _WatchSaveSensorScreenState();
}

class _WatchSaveSensorScreenState extends State<WatchSaveSensorScreen> {
  late List<bool> iconStatus;
  late List<String> selectedSensorNames;
  Map<String, bool> selectedSensors = {};
  late Map sensorNames = {};

  @override
  void initState() {
    selectedSensorNames = widget.sensorNames;
    iconStatus = List.filled(widget.sensorNames.length, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    Color backgroundColor = const Color(0xFF1C1C1E);
    return Scaffold(
      body: Container(
        color: backgroundColor,
        height: height,
        width: width,
        padding: const EdgeInsets.only(
          top: 10,
          left: 5,
          right: 5,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 5,
              right: 0,
              left: 0,
              child: SizedBox(
                width: width,
                height: height,
                child: ListView.builder(
                  itemCount: widget.sensorNames.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FrostedGlassBox(
                      width: width,
                      height: height / 3,
                      child: ListTile(
                        leading: Icon(
                          Icons.save,
                          color: iconStatus[index] ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          selectedSensorNames[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            iconStatus[index] = !iconStatus[index];
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              right: 0,
              left: 0,
              child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  width: width,
                  height: 45,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () {
                        if(lastCheck().isEmpty){
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You didn't chose anything")));
                        }
                        else{
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => WatchSensorTimerScreen(sensorNames: lastCheck(),)));
                        }

                      },
                      child: const Text('Save'))),
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
      ),
    );
  }
  List<String> lastCheck(){
    List<String> selectedSensors = [];
    for(int i=0; i<iconStatus.length;i++){
      if(iconStatus[i]){
        selectedSensors.add(widget.sensorNames[i]);
      }
    }
    return selectedSensors;
  }
}
