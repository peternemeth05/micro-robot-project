import 'dart:async';

import 'package:flutter/material.dart';

enum Paths {spiral, random, grid, line, manual}

class MyAppState1 extends ChangeNotifier {
  bool isConnected = false;

  int pageIndex = 0;

  bool pathOngoing = false;
  var path = Paths.manual;

  double x = 0;
  double y = 0;

  void updateJoystick(double newX, double newY) {
    x = newX;
    y = newY;
    path = Paths.manual;
    notifyListeners(); 
    debugPrint("X:  $newX Y:  $newY");
  }

  void togglePath(int time){
    pathOngoing = true;
    notifyListeners();
    Timer(Duration(milliseconds: time), (){pathOngoing=false;});
    notifyListeners();
  }

  void changeIndex(int ind){
    pageIndex = ind;
    notifyListeners();
  }

  void toggleConnection() {
    isConnected = !isConnected;
    notifyListeners();
  }
}