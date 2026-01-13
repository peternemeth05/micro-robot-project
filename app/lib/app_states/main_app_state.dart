import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:robot_app/ble_files/services/ble_connection/ble_interface.dart';


enum Paths {spiral, random, grid, line, manual} // different path control methods

class MainAppState extends ChangeNotifier { // contains most of the app state information at all times
  
  final BleInterface bleDriver;
  MainAppState(this.bleDriver);
  
  bool isConnected = false;

  int pageIndex = 0;

  bool pathOngoing = false;
  var path = Paths.manual;

  double x = 0; // joystick x position
  double y = 0; // joystick y position
  int speed = 0;
  List<int> speedhist = []; // this is plotted for robot velocity in graphing
  String heading = "N/A";

  String distanceValue = "N/A";
  double distance =0;
  List<int> distancehist = [];

  void updateJoystick(double newX, double newY) { // updates when joystick is moved
    x = newX;
    y = newY;
    speed = (sqrt(x*x+y*y)*10).toInt(); // speed is distance from center (times 10 for legibility)
    speedhist.add(speed); // adds to speed historic
    path = Paths.manual;
    if(speed==0){heading="N/A";}else{
      heading = (-atan2(y,x)* 180 / pi ).toStringAsFixed(1); // calculates heading from x y
    }
    distance = sqrt(pow(newX, 2) + pow(newY, 2));
    path = Paths.manual; // sets path type to manual if joystick is moved
    
    String vert = y >= 0 ? 'F' : 'B';
    String horiz = x >= 0 ? 'R' : 'L';
    String command = '$vert ${y.abs().toStringAsFixed(2)} ' 
                     '$horiz ${x.abs().toStringAsFixed(2)} ' 
                     'S ${distance.toStringAsFixed(2)}';

    if (newX == 0 && newY == 0) {
      command = "STOP";  // controls robot
    }
    ()async {
        try { // checks connection to robot
          await bleDriver.writeToCharacteristic(command.codeUnits);
          debugPrint("✅ Joystick Info Sent!");
        } catch (e) {
          debugPrint("❌ Joystick Info");
        }
      }();

    notifyListeners(); 
  }

  void updateDistance(String newDistance) { // updates distance to surface from ultrasound sensor
    distanceValue = newDistance;
    distancehist.add(int.parse(newDistance));
    notifyListeners();
  }

  void togglePath(int time){ // whenever path change is selected
    pathOngoing = true; // enables path ongoing
    notifyListeners();
    Timer(Duration(milliseconds: time), (){pathOngoing=false;}); // disables path ongoing after time elapses
    notifyListeners();
  }

  void changeIndex(int ind){ // this is main navigation index
    pageIndex = ind;
    notifyListeners();
  }

  void toggleConnection() { // represents the wifi connection
    isConnected = !isConnected;
    notifyListeners();
  }
}