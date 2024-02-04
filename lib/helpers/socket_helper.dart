import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sensorify/models/message_model.dart';
import 'package:web_socket_client/web_socket_client.dart';

class SocketHelper {

  static const MethodChannel _methodChannel = MethodChannel('com.murabit.akdogan/socket');

  static Future<void> onRightClick() async{
    await _methodChannel.invokeMethod('event', {"type": "rightClick"});
  }
  static Future<void> onDrag(double length, double degree) async{
    await _methodChannel.invokeMethod('event', {"type": "drag", "length": length, "degree": degree});
  }
  static Future<void> onLeftClick() async{
    await _methodChannel.invokeMethod('event', {"type": "leftClick"});
  }
  static Future<void> onOpen() async{
    await _methodChannel.invokeMethod('event', {"type": "open"});
  }
  static Future<String> getHost() async{
    return await _methodChannel.invokeMethod('getAddressInfo');
  }
  static Future<void> startServer() async{
    await _methodChannel.invokeMethod('startServer');
  }

  WebSocket socket = WebSocket(Uri.parse('http://localhost:8080'));

  static Future<void> sendMessage(MessageModel message, String address) async{
    final data = utf8.encode(jsonEncode(message.toJson()));
    await _methodChannel.invokeMethod('sendMessage', {"message": data, "address": address});
  }

  getStream() {
    socket.messages.listen((message) {
      // Handle incoming messages.
    });
  }

  Future<bool> connect({required String url}) async {
    socket = WebSocket(Uri.parse(url));
    if (socket.connection.state is Connected) {
      return true;
    } else {
      return false;
    }
  }

  void closeConnection() {
    if (socket.connection.state is Connected) {
      socket.close();
    }
  }
}
