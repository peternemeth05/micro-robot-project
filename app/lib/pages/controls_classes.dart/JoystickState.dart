import 'package:flutter/material.dart';

class JoystickState extends ChangeNotifier {

  double x = 0;
  double y = 0;

  void updateJoystick(double newX, double newY) {
    x = newX;
    y = newY;
    notifyListeners(); 
    print("X:  $newX Y:  $newY");
  }
}