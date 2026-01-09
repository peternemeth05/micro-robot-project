import 'dart:async';
import 'package:flutter/foundation.dart';
import 'services/ble_connection/ble_interface.dart';
import 'package:flutter/material.dart';

enum paths {spiral, random, grid, line, manual}


class AppState extends ChangeNotifier {
  bool _bleConnected = false;
  // getter for BLE connection status
  bool get bleConnected => _bleConnected;

  StreamSubscription<bool>? _bleSubscription;

  /// Bind BLE connection stream → AppState
  void bindBle(BleInterface ble) {
    // Set initial value
    _setBleConnected(ble.isConnected);

    // Listen for changes
    _bleSubscription?.cancel();
    _bleSubscription = ble.connectionStateStream.listen((connected) {
      _setBleConnected(connected);
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
  }
}