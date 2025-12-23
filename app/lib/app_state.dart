import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  bool isConnected = false;
  bool physicalControllerEnabled = false;
  bool virtualControllerEnabled = false;
  bool enableWifi = false;

  void toggleConnection() {
    isConnected = !isConnected;
    notifyListeners();
  }

  void setPhysicalController(bool enabled) {
    physicalControllerEnabled = enabled;
    notifyListeners();
  }

  void setVirtualController(bool enabled) {
    virtualControllerEnabled = enabled;
    notifyListeners();
  }

  void toggleWifi() {
    enableWifi = !enableWifi;
    notifyListeners();
  }
}
