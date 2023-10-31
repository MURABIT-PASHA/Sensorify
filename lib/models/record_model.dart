class RecordModel {
  final String initialName;
  final String sensorName;
  final double axisX;
  final double axisY;
  final double axisZ;
  final int timestamp;

  RecordModel({
    required this.initialName,
    required this.sensorName,
    required this.axisX,
    required this.axisY,
    required this.axisZ,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      "initialName": initialName,
      "sensorName": sensorName,
      "axisX": axisX,
      "axisY": axisY,
      "axisZ": axisZ,
      "timestamp": timestamp,
    };
  }

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    return RecordModel(
      initialName: json["initialName"],
      sensorName: json["sensorName"],
      axisX: json["axisX"].toDouble(),
      axisY: json["axisY"].toDouble(),
      axisZ: json["axisZ"].toDouble(),
      timestamp: json["timestamp"],
    );
  }
}
