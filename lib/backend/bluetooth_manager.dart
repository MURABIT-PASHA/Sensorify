import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:sensorify/models/message_model.dart';
import 'package:sensorify/provider/device_status_provider.dart';

class BluetoothManager{
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
    },);

    await Future.delayed(delay);

    await subscription.cancel();

    return deviceMap;
  }


  Future<bool> connectToBluetoothDevice(String deviceId) async {
    try {
      final result = await _flutterReactiveBle.connectToDevice(
        id: deviceId,
        connectionTimeout: const Duration(seconds: 5),
      ).first;

      if(result.connectionState == ConnectionStatus.connected) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }



  Future<bool> sendMessage(MessageModel message) async {
    final DeviceStatusProvider provider = DeviceStatusProvider();

    final Uuid serviceUuid = Uuid.parse("00001234-0000-1000-8000-00805f9b34fb");

    final data = utf8.encode(jsonEncode(message.toJson()));

    try {
      await _flutterReactiveBle.writeCharacteristicWithoutResponse(
        QualifiedCharacteristic(
          characteristicId: provider.deviceCharacteristics.first.id,
          serviceId: serviceUuid,
          deviceId: provider.deviceAddress,
        ),
        value: data,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<String> getStream() {
    final Uuid serviceUuid = Uuid.parse("00001234-0000-1000-8000-00805f9b34fb");
    final DeviceStatusProvider provider = DeviceStatusProvider();
    return _flutterReactiveBle.subscribeToCharacteristic(
      QualifiedCharacteristic(
        characteristicId: provider.deviceCharacteristics.first.id,
        serviceId: serviceUuid,
        deviceId: provider.deviceAddress,
      ),
    ).map((data) {
      return utf8.decode(data);
    });
  }

  Future<List<Characteristic>> getCharacteristics(String deviceId) async {
    List<Characteristic> characteristics = [];

    try {
      final discoveredServices = await _flutterReactiveBle.getDiscoveredServices(deviceId);
      for (final service in discoveredServices) {
        characteristics.addAll(service.characteristics);
      }
      return characteristics;
    } catch (e) {
      print("Hizmet keşfi sırasında hata oluştu: $e");
      return [];
    }
  }

  bool checkBluetoothStatus(){
    final state = _flutterReactiveBle.status;
    return state == BleStatus.ready;
  }

}