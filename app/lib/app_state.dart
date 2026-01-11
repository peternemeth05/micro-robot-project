import 'dart:async';
import 'package:flutter/foundation.dart';
import 'services/ble_connection/ble_interface.dart';
import 'package:flutter/material.dart';

<<<<<<< HEAD
=======
enum Paths {spiral, random, grid, line, manual}
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 4ceae73f (Added 2 unit tests: timer reset after multiple button presses & snackbar appearance)
=======
enum Video {start, stop}
>>>>>>> 4200ab99 (added buttons for video and added bluetooth message on predetermined paths)
=======

>>>>>>> 49b03b30 (addded screen recording)

class AppState extends ChangeNotifier {
  bool _bleConnected = false;
  // getter for BLE connection status
  bool get bleConnected => _bleConnected;

  StreamSubscription<bool>? _bleSubscription;

<<<<<<< HEAD
  /// Bind BLE connection stream → AppState
  void bindBle(BleInterface ble) {
    // Set initial value
    _setBleConnected(ble.isConnected);

    // Listen for changes
    _bleSubscription?.cancel();
    _bleSubscription = ble.connectionStateStream.listen((connected) {
      _setBleConnected(connected);
=======
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
    Timer(Duration(milliseconds: time), (){
      pathOngoing=false;
      notifyListeners();
>>>>>>> 4ceae73f (Added 2 unit tests: timer reset after multiple button presses & snackbar appearance)
    });
  }

  void _setBleConnected(bool value) {
    if (_bleConnected == value) return;
    _bleConnected = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _bleSubscription?.cancel();
    super.dispose();
  }

  bool _wifiConnected = false;
  bool get wifiConnected => _wifiConnected;
  
  void toggleWifi() {
    _wifiConnected = !_wifiConnected;
    notifyListeners();
  }
}