import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceStatusProvider extends ChangeNotifier {
  bool _isDeviceRegistered = false;

  bool get isDeviceRegistered => _isDeviceRegistered;

  String _deviceAddress = "NULL";

  String get deviceAddress => _deviceAddress;

  bool _isDeviceConnected = false;

  bool get isDeviceConnected => _isDeviceConnected;


  List<Characteristic> _deviceCharacteristics = [];
  List<Characteristic> get deviceCharacteristics => _deviceCharacteristics;

  Future<bool> registerDeviceAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isDeviceExist", true);
    prefs.setString("deviceAddress", address);
    _deviceAddress = address;
    _updateRegistrationStatus(true);
    return true;
  }

  Future checkRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    final existence = prefs.getBool("isDeviceExist") ?? false;
    if (existence) {
      final address = prefs.getString("deviceAddress") ?? "NULL";
      if (address != "NULL") {
        if (!_isDeviceRegistered) {
          _deviceAddress = address;
          _updateRegistrationStatus(true);
        }
      }
    }
  }

  void updateDeviceCharacteristics(List<Characteristic> characteristics){
    _deviceCharacteristics = characteristics;
    notifyListeners();
  }

  void _updateRegistrationStatus(bool status) {
    _isDeviceRegistered = status;
    notifyListeners();
  }

  void updateConnectionStatus(bool status) {
    _isDeviceConnected = status;
    notifyListeners();
  }
}
