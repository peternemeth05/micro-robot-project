import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  bool isConnected = false;

  int pageIndex = 0;

  void changeIndex(int ind){
    pageIndex = ind;
    notifyListeners();
  }

  void toggleConnection() {
    isConnected = !isConnected;
    notifyListeners();
  }
}
