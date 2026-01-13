import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum paths {spiral, random, grid, line, manual}

class MyAppState1 extends ChangeNotifier {
  bool isConnected = false;

  int pageIndex = 0;

  bool pathOngoing = false;
  var path = paths.manual;

  double x = 0;
  double y = 0;
  int speed = 0;
  List<int> speedhist = [];

  String distanceValue = "N/A";

  void updateJoystick(double newX, double newY) {
    x = newX;
    y = newY;
    speed = (sqrt(x*x+y*y)*10).toInt();
    speedhist.add(speed);
    path = paths.manual;
    notifyListeners(); 
    debugPrint("X:  $newX Y:  $newY");
  }

  void updateDistance(String newDistance) {
    distanceValue = newDistance;
    notifyListeners();
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