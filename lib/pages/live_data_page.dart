import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:real_time_chart/real_time_chart.dart';
import 'package:sensorify/backend/bluetooth_manager.dart';
import 'package:sensorify/constants.dart';
import 'package:sensorify/models/message_model.dart';

import '../types.dart';

class LiveDataPage extends StatefulWidget {
  const LiveDataPage({Key? key}) : super(key: key);

  @override
  State<LiveDataPage> createState() => _LiveDataPageState();
}

class _LiveDataPageState extends State<LiveDataPage> {
  BluetoothManager bluetoothManager = BluetoothManager();
  Stream<dynamic> get messageStream => bluetoothManager.getStream();
  final StreamController<dynamic> _bluetoothStreamController =
      StreamController<dynamic>();
  final StreamController<double> _axisXStreamController = StreamController<double>();
  final StreamController<double> _axisYStreamController = StreamController<double>();
  final StreamController<double> _axisZStreamController = StreamController<double>();
  final double growth = 5;

  void startBluetoothListening() {
    BluetoothManager bluetoothManager = BluetoothManager();
    bluetoothManager.getStream().listen((message) {
      MessageModel model = MessageModel.fromJson(json.decode(message));
      if (model.orderType == MessageOrderType.record) {
        final record = model.record;
        if (record != null) {
          if (!record.save) {
            _bluetoothStreamController.sink.add(record);
            _axisXStreamController.sink.add(record.axisX * growth);
            _axisYStreamController.sink.add(record.axisY * growth);
            _axisZStreamController.sink.add(record.axisZ * growth);
          }
        }
      }
    });
  }

  @override
  void initState() {
    startBluetoothListening();
    super.initState();
  }

  @override
  void dispose() {
    _bluetoothStreamController.close();
    _axisXStreamController.close();
    _axisYStreamController.close();
    _axisZStreamController.close();
    bluetoothManager
        .sendMessage(MessageModel(orderType: MessageOrderType.stop));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sensorify"),
      ),
      body: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: width -10,
              height: width -10,
              child: StreamBuilder<dynamic>(
                stream: _bluetoothStreamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Color> graphColors = [
                      xAxisColor,
                      yAxisColor,
                      zAxisColor,
                    ];
                    List records = [
                      _axisXStreamController,
                      _axisYStreamController,
                      _axisZStreamController,
                    ];
                    List<Widget> charts = [];
                    for (int i = 0; i < 3; i++) {
                      Widget chart = RealTimeGraph(
                        displayYAxisValues: false,
                        graphStroke: 3,
                        xAxisColor: Colors.white,
                        yAxisColor: Colors.white,
                        graphColor: graphColors[i],
                        stream: records[i].stream,
                        supportNegativeValuesDisplay: true,
                      );
                      charts.add(
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: chart,
                          ),
                        ),
                      );
                    }
                    return Stack(
                      children: charts,
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            SizedBox(
              width: width - 10,
              height: 90,
              child: Column(
                children: [
                  getInfoBox(width: width, color: xAxisColor, title: "X Ekseni"),
                  getInfoBox(width: width, color: yAxisColor, title: "Y Ekseni"),
                  getInfoBox(width: width, color: zAxisColor, title: "Z Ekseni"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget getInfoBox({double height = 30, required double width, required Color color, required String title}){
    const double spacing = 10;
    return SizedBox(
      width: width - spacing,
      height: height,
      child: Row(
        children: [
          Container(
            width: height,
            height: height,
            color: color,
          ),
          Container(
            width: width - spacing - height,
            height: height,
            padding: const EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
            child: Text(title, style: const TextStyle(color: Colors.white, overflow: TextOverflow.ellipsis),),
          ),
        ],
      ),
    );
  }
}
