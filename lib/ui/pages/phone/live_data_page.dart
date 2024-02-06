import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_time_chart/real_time_chart.dart';
import 'package:sensorify/constants.dart';
import 'package:sensorify/helpers/socket_helper.dart';
import 'package:sensorify/models/message_model.dart';
import 'package:sensorify/provider/socket_status_provider.dart';

import 'package:sensorify/types.dart';

class LiveDataPage extends StatefulWidget {
  const LiveDataPage({Key? key}) : super(key: key);

  @override
  State<LiveDataPage> createState() => _LiveDataPageState();
}

class _LiveDataPageState extends State<LiveDataPage> {
  SocketHelper socket = SocketHelper();
  Stream<dynamic> get messageStream => socket.getStream();
  final StreamController<dynamic> _socketStreamController =
      StreamController<dynamic>();
  final StreamController<double> _axisXStreamController =
      StreamController<double>();
  final StreamController<double> _axisYStreamController =
      StreamController<double>();
  final StreamController<double> _axisZStreamController =
      StreamController<double>();
  final double growth = 5;
  late StreamSubscription liveDataSubscription;
  late SocketStatusProvider socketStatusProvider;

  void startListener() {
    liveDataSubscription = socket.getStream().listen((message) {
      MessageModel model = MessageModel.fromJson(json.decode(message));
      if (model.orderType == MessageOrderType.record) {
        final record = model.record;
        if (record != null) {
          if (!record.save) {
            _socketStreamController.sink.add(record);
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
    socketStatusProvider = Provider.of<SocketStatusProvider>(context, listen: false); // Provider'ı burada alın
    startListener();
    super.initState();
  }

  @override
  void dispose() {
    SocketHelper.sendMessage(MessageModel(orderType: MessageOrderType.watch),
            socketStatusProvider.socketAddress)
        .then((value) {
      _socketStreamController.close();
      _axisXStreamController.close();
      _axisYStreamController.close();
      _axisZStreamController.close();
      liveDataSubscription.cancel();
    });

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
              width: width - 10,
              height: width - 10,
              child: StreamBuilder<dynamic>(
                stream: _socketStreamController.stream,
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
                  getInfoBox(
                      width: width, color: xAxisColor, title: "X Ekseni"),
                  getInfoBox(
                      width: width, color: yAxisColor, title: "Y Ekseni"),
                  getInfoBox(
                      width: width, color: zAxisColor, title: "Z Ekseni"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getInfoBox(
      {double height = 30,
      required double width,
      required Color color,
      required String title}) {
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
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.white, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}
