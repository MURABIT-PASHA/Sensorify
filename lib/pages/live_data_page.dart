import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:real_time_chart/real_time_chart.dart';
import 'package:sensorify/backend/sensor_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../types.dart';

class LiveDataPage extends StatefulWidget {
  final SensorType type;
  const LiveDataPage({Key? key, required this.type}) : super(key: key);

  @override
  State<LiveDataPage> createState() => _LiveDataPageState();
}

class _LiveDataPageState extends State<LiveDataPage> {
  RxList<Container> dataList = RxList<Container>([]);
  final List<Color> _colorList = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.orange
  ];
  SensorManager sensorManager = SensorManager();
  @override
  void initState() {
    //TODO: Send 'startStream' message to watch
    super.initState();
  }

  @override
  void dispose() {
    //TODO: Send 'stopStream' message to watch
    super.dispose();
  }

  Stream<dynamic> startStreamData() {
    switch (widget.type) {
      case SensorType.accelerometer:
        return sensorManager.accelerometerEventListener();
      case SensorType.gyroscope:
        return sensorManager.gyroscopeEventListener();
      case SensorType.magnetometer:
        return sensorManager.magnetometerEventListener();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Color backgroundColor = const Color(0xFF1C1C1E);
    // List<Widget> stackedCharts = buildStackedCharts(3);
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        color: backgroundColor,
        alignment: Alignment.center,
        child: SizedBox(
            width: width - 10,
            height: width - 10,
            child: StreamBuilder<dynamic>(
                stream: startStreamData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var event = snapshot.data;
                    String x = event.x.toString();
                    String y = event.y.toString();
                    String z = event.z.toString();

                    Container dataBox = Container(
                      width: width,
                      height: 30,
                      alignment: Alignment.centerLeft,
                      child: Text("x:$x and y:$y and z:$z"),
                    );
                    dataList.value.add(dataBox);
                    return Obx(
                      () => ListView(
                        scrollDirection: Axis.vertical,
                        physics: const AlwaysScrollableScrollPhysics(),
                        reverse: false,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        children: dataList,
                      ),
                    );
                  } else {
                    return Container();
                  }
                })),
      ),
    );
  }
  // List<Widget> buildStackedCharts(int length) {
  //   List<Widget> charts = [];
  //   for (int i = 0; i < length; i++) {
  //     Widget chart = RealTimeGraph(
  //       xAxisColor: Colors.white,
  //       yAxisColor: Colors.white,
  //       graphColor: _colorList[i],
  //       stream: startStreamData(),
  //       supportNegativeValuesDisplay: true,
  //     );
  //     charts.add(
  //       Positioned.fill(
  //         child: Align(
  //           alignment: Alignment.center,
  //           child: chart,
  //         ),
  //       ),
  //     );
  //   }
  //   return charts;
  // }
}
