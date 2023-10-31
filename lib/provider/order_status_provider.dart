import 'package:flutter/material.dart';
import 'package:sensorify/pages/device_page.dart';

class OrderStatusProvider extends ChangeNotifier {
  Widget _currentPage = const DevicePage();

  Widget get currentPage => _currentPage;

  void updateOrderStatus(Widget page) {
    _currentPage = page;
    notifyListeners();
  }
}
