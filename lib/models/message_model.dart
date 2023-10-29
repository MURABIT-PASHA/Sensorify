import 'package:sensorify/models/record_model.dart';
import 'package:sensorify/models/settings_model.dart';
import 'package:sensorify/types.dart';

class MessageModel{
    final MessageOrderType orderType;
    final SettingsModel? settings;
    final RecordModel? record;

  MessageModel({required this.orderType, this.record, this.settings});
    Map<String, dynamic> toJson() {
      return {
        'orderType': orderType.name,
        'settings': settings?.toJson(),
        'record': record?.toJson(),
      };
    }

    factory MessageModel.fromJson(Map<String, dynamic> json) {
      final String orderTypeString = json['orderType'];
      final MessageOrderType orderType = MessageOrderType.values
          .firstWhere((type) => type.name.toString() == orderTypeString);
      RecordModel? record;
      SettingsModel? settings;
      if (json['record'] != null) {
        record = RecordModel.fromJson(json['record']);
      }
      if (json['settings'] != null) {
        settings = SettingsModel.fromJson(json['settings']);
      }

      return MessageModel(orderType: orderType, settings: settings, record: record);
    }
}