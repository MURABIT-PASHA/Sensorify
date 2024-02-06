import "package:sensorify/types.dart";

class RecordSettings {
  final int durationDelay;
  final DurationType durationType;
  final Map<SensorType, bool> selectedSensors;

  RecordSettings(
      {required this.durationDelay,
      required this.durationType,
      required this.selectedSensors});

  Map<String, dynamic> toJson() {
    return {
      "durationDelay": durationDelay,
      "durationType": durationType.toString(),
      "selectedSensors":
          selectedSensors.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  factory RecordSettings.fromJson(Map<String, dynamic> json) {
    final int durationDelay = json["durationDelay"];
    final DurationType durationType = DurationType.values
        .firstWhere((type) => type.toString() == json["durationType"]);
    final Map<String, dynamic> selectedSensorsJson = json["selectedSensors"];
    final Map<SensorType, bool> selectedSensors = Map.fromEntries(
      selectedSensorsJson.entries.map(
        (entry) => MapEntry(
            SensorType.values
                .firstWhere((type) => type.toString() == entry.key),
            entry.value),
      ),
    );

    return RecordSettings(
      durationDelay: durationDelay,
      durationType: durationType,
      selectedSensors: selectedSensors,
    );
  }
}
