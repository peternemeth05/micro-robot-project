import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  bool isConnected = false;

  void toggleConnection() {
    isConnected = !isConnected;
    notifyListeners();
  }
}
