import 'package:sensorify/models/settings_model.dart';
import 'package:sensorify/types.dart';

class MessageModel{
    final MessageOrderType orderType;
    final SettingsModel? content;

  MessageModel({required this.orderType, this.content});
    Map<String, dynamic> toJson() {
      return {
        'orderType': orderType.name,
        'content': content?.toJson(),
      };
    }

    factory MessageModel.fromJson(Map<String, dynamic> json) {
      final String orderTypeString = json['orderType'];
      final MessageOrderType orderType = MessageOrderType.values
          .firstWhere((type) => type.name.toString() == orderTypeString);
      final SettingsModel content = SettingsModel.fromJson(json['content']);

      return MessageModel(orderType: orderType, content: content);
    }
}