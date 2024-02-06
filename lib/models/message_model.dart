import 'package:sensorify/models/connection_settings_model.dart';
import 'package:sensorify/models/record_model.dart';
import 'package:sensorify/models/record_settings_model.dart';
import 'package:sensorify/types.dart';

class MessageModel{
    final MessageOrderType orderType;
    final RecordSettings? recordSettings;
    final Record? record;
    final ConnectionSettings? connectionSettings;

  MessageModel({required this.orderType, this.record, this.recordSettings, this.connectionSettings});
    Map<String, dynamic> toJson() {
      return {
        'orderType': orderType.name,
        'recordSettings': recordSettings?.toJson(),
        'record': record?.toJson(),
        'connectionSettings': connectionSettings?.toJson(),
      };
    }

    factory MessageModel.fromJson(Map<String, dynamic> json) {
      final String orderTypeString = json['orderType'];
      final MessageOrderType orderType = MessageOrderType.values
          .firstWhere((type) => type.name.toString() == orderTypeString);
      Record? record;
      RecordSettings? recordSettings;
      ConnectionSettings? connectionSettings;
      if (json['record'] != null) {
        record = Record.fromJson(json['record']);
      }
      if (json['recordSettings'] != null) {
        recordSettings = RecordSettings.fromJson(json['recordSettings']);
      }
      if(json['connectionSettings'] != null){
        connectionSettings = ConnectionSettings.fromJson(json['connectionSettings']);
      }

      return MessageModel(orderType: orderType, recordSettings: recordSettings, record: record, connectionSettings: connectionSettings);
    }
}