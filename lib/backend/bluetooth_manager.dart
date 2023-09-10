import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothManager{
  static MethodChannel methodChannel = const MethodChannel("com.sensorify/bluetooth");
  static EventChannel eventChannel = const EventChannel("com.sensorify/sensor");
  final FlutterReactiveBle _flutterReactiveBle = FlutterReactiveBle();

  Future<List<Map<String, dynamic>>> scanBluetoothDevices(Duration delay) async {
    List<Map<String, dynamic>> deviceMap = [];
    final Set<String> addedDeviceIds = {};

    final subscription = _flutterReactiveBle.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      if (device.name != "" && device.id != "" && device.serviceUuids != []) {
        final deviceId = device.id.toString();
        if (!addedDeviceIds.contains(deviceId)) {
          addedDeviceIds.add(deviceId);
          deviceMap.add({
            "name": device.name,
            "id": deviceId,
            "serviceData": device.serviceData,
          });
        }
      }
    }, onError: (object) {
      print(object.runtimeType);
    });

    await Future.delayed(delay);

    await subscription.cancel();

    return deviceMap;
  }

  Future<List> getData() async {
    List tmp = await methodChannel.invokeMethod('scanDevices');
    return tmp;
  }

  Future<bool> connectToBluetoothDevice(String address) async{
    bool tmp = await methodChannel.invokeMethod("startRead",{"address": address});
    return tmp;
  }

  Future<bool> sendMessage(String message) async {
    bool tmp = await methodChannel.invokeMethod("write",{"message": message});
    return tmp;
  }
  Stream getStream() {
    Stream<dynamic> eventStream = eventChannel.receiveBroadcastStream();
    return eventStream;
  }

  bool checkBluetoothStatus(){
    final state = _flutterReactiveBle.status;
    return state == BleStatus.ready;
  }

}