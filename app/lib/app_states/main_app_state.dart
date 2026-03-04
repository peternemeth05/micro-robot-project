/*
 * ----------------------------------------------------------------------------
 * The primary State Management controller for the robot's operation.
 * Handles user inputs (Joystick/Buttons) and converts them into protocol commands sent to the robot via the BLE Interface.
 * * Key Responsibilities:
 * - Calculates robot kinematics from joystick X/Y coordinates.
 * - Stores real-time data for plotting.
 * - Manages UI navigation state (page indices).
 * ----------------------------------------------------------------------------
 */


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
  
  bool isWifiConnected = false;

  void handleRobotStatus(String message) {
   if (message.contains("N#101#") || message.contains("N#301#")) {
     isWifiConnected = true;
      notifyListeners(); // This tells VideoLogPage to rebuild and show the camera!
    } else if (message.contains("N#102#") || message.contains("N#302#")) {
     isWifiConnected = false;
      notifyListeners();
   }
  }

  void updateJoystick(double newX, double newY) {
    x = newX;
    y = newY;
    speed = (sqrt(x*x+y*y)*10).toInt();
    speedhist.add(speed);
    path = Paths.manual;

    if(speed==0){
      heading="N/A";
    } else {
      heading = (-atan2(y,x)* 180 / pi).toStringAsFixed(1);
    }

    distance = sqrt(pow(newX, 2) + pow(newY, 2));

    // convert joystick to robot command
    int alpha = (-atan2(newX, -newY) * 180 / pi).toInt(); // direction in degrees
    int stepLength = (distance * 20).toInt().clamp(0, 20); // scale to 0-20
    int rotation = 0;
    int spd = (distance * 5).toInt().clamp(1, 5); // scale to 1-5

    String command;
    if (newX == 0 && newY == 0) {
      command = 'F#0#0#0#0#'; // stop
    } else {
      command = 'F#$alpha#$stepLength#$rotation#$spd#';
    }

    ()async {
      try {
        await bleDriver.writeToCharacteristic(command.codeUnits);
        debugPrint("✅ Sent: $command");
      } catch (e) {
        debugPrint("❌ Joystick send failed: $e");
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