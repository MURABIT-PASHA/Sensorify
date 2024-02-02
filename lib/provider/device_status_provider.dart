import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocketStatusProvider extends ChangeNotifier {
  bool _isDeviceRegistered = false;

  bool get isDeviceRegistered => _isDeviceRegistered;

  String _deviceAddress = "NULL";

  String get deviceAddress => _deviceAddress;

  bool _isDeviceConnected = false;

  bool get isDeviceConnected => _isDeviceConnected;
  

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
  

  void _updateRegistrationStatus(bool status) {
    _isDeviceRegistered = status;
    notifyListeners();
  }

  void updateConnectionStatus(bool status) {
    _isDeviceConnected = status;
    notifyListeners();
  }
}
