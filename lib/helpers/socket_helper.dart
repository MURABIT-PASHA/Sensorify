import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sensorify/models/message_model.dart';

class SocketHelper {

  static const MethodChannel _methodChannel = MethodChannel('com.murabit.akdogan/method');
  static EventChannel eventChannel = const EventChannel("com.murabit.akdogan/event");

  static Future<String> getHostAddress() async{
    return await _methodChannel.invokeMethod('getAddressInfo');
  }
  static Future<void> startServer() async{
    await _methodChannel.invokeMethod('startServer');
  }

  static Future<void> sendMessage(MessageModel message, String address) async{
    final data = jsonEncode(message.toJson());
    await _methodChannel.invokeMethod('sendMessage', {"message": data, "address": address});
  }

  Stream getStream() {
    Stream<dynamic> eventStream = eventChannel.receiveBroadcastStream();
    return eventStream;
  }

}
