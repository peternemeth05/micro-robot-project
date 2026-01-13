import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:robot_app/ble_files/services/ble_connection/ble_interface.dart';


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
  int speed = 0;
  List<int> speedhist = [];
  String heading = "N/A";

  String distanceValue = "N/A";
  double distance =0;

  void updateJoystick(double newX, double newY) {
    x = newX;
    y = newY;
    speed = (sqrt(x*x+y*y)*10).toInt();
    speedhist.add(speed);
    path = Paths.manual;
    if(speed==0){heading="N/A";}else{
      heading = (-atan2(y,x)* 180 / pi ).toStringAsFixed(1);
    }
    distance = sqrt(pow(newX, 2) + pow(newY, 2));
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