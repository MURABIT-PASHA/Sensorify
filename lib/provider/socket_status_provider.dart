import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocketStatusProvider extends ChangeNotifier {
  bool _isSocketRegistered = false;

  bool get isSocketRegistered => _isSocketRegistered;

  String _socketAddress = "NULL";

  String get socketAddress => _socketAddress;

  bool _isSocketConnected = false;

  bool get isSocketConnected => _isSocketConnected;

  bool _isOtherDeviceConnected = false;

  bool get isOtherDeviceConnected => _isOtherDeviceConnected;
  

  Future<bool> registerSocketAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    if(address == "NULL"){
      prefs.setBool("isSocketExist", false);
      prefs.setString("socketAddress", 'NULL');
      _socketAddress = 'NULL';
      _updateRegistrationStatus(false);
    }else{
      prefs.setBool("isSocketExist", true);
      prefs.setString("socketAddress", address);
      _socketAddress = address;
      _updateRegistrationStatus(true);
    }
    return true;
  }

  Future checkRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    final existence = prefs.getBool("isSocketExist") ?? false;
    if (existence) {
      final address = prefs.getString("socketAddress") ?? "NULL";
      if (address != "NULL") {
        if (!_isSocketRegistered) {
          _socketAddress = address;
          _updateRegistrationStatus(true);
        }
      }
    }
  }
  

  void _updateRegistrationStatus(bool status) {
    _isSocketRegistered = status;
    notifyListeners();
  }

  void updateConnectionStatus(bool status) {
    _isSocketConnected = status;
    notifyListeners();
  }

  void updateOtherDeviceConnectionStatus(bool status){
    _isOtherDeviceConnected = status;
    notifyListeners();
  }
}
