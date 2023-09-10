import 'package:flutter/foundation.dart';

class BluetoothStatusProvider with ChangeNotifier {
  bool _isDeviceConnected = false;

  bool get isDeviceConnected => _isDeviceConnected;

  void updateConnectionStatus(bool status) {
    _isDeviceConnected = status;
    notifyListeners();
  }
}
