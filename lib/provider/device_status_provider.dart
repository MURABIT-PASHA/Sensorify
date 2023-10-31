import 'package:flutter/material.dart';

class DeviceStatusProvider extends ChangeNotifier {
  bool _isDeviceRegistered = false;

  bool get isDeviceRegistered => _isDeviceRegistered;

  bool _isDeviceConnected = false;

  bool get isDeviceConnected => _isDeviceConnected;

  void updateConnectionStatus(bool status) {
    _isDeviceConnected = status;
    notifyListeners();
  }

  void updateRegistrationStatus(bool status) {
    _isDeviceRegistered = status;
    notifyListeners();
  }
}
