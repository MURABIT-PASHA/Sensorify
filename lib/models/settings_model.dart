import "package:sensorify/types.dart";

class SettingsModel {
  final int durationDelay;
  final DurationType durationType;
  final Map<SensorType, bool> selectedSensors;

  SettingsModel(
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

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
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

    return SettingsModel(
      durationDelay: durationDelay,
      durationType: durationType,
      selectedSensors: selectedSensors,
    );
  }
}
