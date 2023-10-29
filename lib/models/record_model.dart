class RecordModel {
  bool? isFirst;
  bool? isLast;
  final String sensorName;
  final double axisX;
  final double axisY;
  final double axisZ;
  final int timestamp;

  RecordModel({
    required this.sensorName,
    required this.axisX,
    required this.axisY,
    required this.axisZ,
    required this.timestamp,
    this.isFirst,
    this.isLast,
  });


  Map<String, dynamic> toJson() {
    return {
      "isFirst": isFirst,
      "isLast": isLast,
      "sensorName": sensorName,
      "axisX": axisX,
      "axisY": axisY,
      "axisZ": axisZ,
      "timestamp": timestamp,
    };
  }

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    return RecordModel(
      isFirst: json["isFirst"],
      isLast: json["isLast"],
      sensorName: json["sensorName"],
      axisX: json["axisX"].toDouble(),
      axisY: json["axisY"].toDouble(),
      axisZ: json["axisZ"].toDouble(),
      timestamp: json["timestamp"],
    );
  }
}
