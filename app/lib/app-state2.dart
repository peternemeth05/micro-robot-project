import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:robot_app/services/ble_connection/ble_interface.dart';
import 'dart:math' as math;


enum Paths {spiral, random, grid, line, manual}


class MyAppState1 extends ChangeNotifier {
  
  final BleInterface bleDriver;
  MyAppState1(this.bleDriver);
  
  bool isConnected = false;

  int pageIndex = 0;

  bool pathOngoing = false;
  var path = Paths.manual;

  double x = 0;
  double y = 0;
  double distance =0;

  void updateJoystick(double newX, double newY) {
    x = newX;
    y = newY;
    distance = math.sqrt(math.pow(newX, 2) + math.pow(newY, 2));
    path = Paths.manual;
    
    String vert = y >= 0 ? 'F' : 'B';
    String horiz = x >= 0 ? 'R' : 'L';
    String command = '$vert ${y.abs().toStringAsFixed(2)} ' 
                     '$horiz ${x.abs().toStringAsFixed(2)} ' 
                     'S ${distance.toStringAsFixed(2)}';

    if (newX == 0 && newY == 0) {
      command = "STOP"; 
    }
    ()async {
        try {
          await bleDriver.writeToCharacteristic(command.codeUnits);
          debugPrint("✅ Joystick Info Sent!");
        } catch (e) {
          debugPrint("❌ Joystick Info");
        }
      }();

    notifyListeners(); 
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