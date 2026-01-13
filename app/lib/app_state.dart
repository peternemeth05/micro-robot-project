import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'services/ble_connection/ble_interface.dart';

enum paths { spiral, random, grid, line, manual }

class AppState extends ChangeNotifier {
  bool _bleConnected = false;
  bool get bleConnected => _bleConnected;

  bool _sensorLogging = false;
  bool get sensorLogging => _sensorLogging;

  StreamSubscription<bool>? _bleSubscription;

  // subscription for sensor data logging
  StreamSubscription<String>? _sensorSubscription;

  // Bind BLE connection stream 
  void bindBle(BleInterface ble) {
    // Set initial value
    _setBleConnected(ble.isConnected);

    // If already connected at bind time, start logging immediately
    if (ble.isConnected) {
      _startSensorLogging(ble);
    } else {
      _stopSensorLogging();
    }

    // Listen for connection changes
    _bleSubscription?.cancel();
    _bleSubscription = ble.connectionStateStream.listen((connected) {
      _setBleConnected(connected);

      if (connected) {
        _startSensorLogging(ble);
      } else {
        _stopSensorLogging();
      }
    });
  }

  void _setBleConnected(bool value) {
    if (_bleConnected == value) return;
    _bleConnected = value;
    notifyListeners();
  }

  void _setSensorLogging(bool value) {
    if (_sensorLogging == value) return;
    _sensorLogging = value;
    notifyListeners();
  }

  void _startSensorLogging(BleInterface ble) {
    // Prevent double subscription
    if (_sensorSubscription != null) return;

    final box = Hive.box<Map>(
      'sensor_log',
    );

    _sensorSubscription = ble.sensorDataStream.listen((msg) {
      box.add({'timestamp': DateTime.now().toIso8601String(), 'value': msg});

      // Prevent unlimited growth
      const maxEntries = 2000;
      if (box.length > maxEntries) box.deleteAt(0);
    });
    _setSensorLogging(true);
  }

  Future<void> _stopSensorLogging() async {
    await _sensorSubscription?.cancel();
    _sensorSubscription = null;
    _setSensorLogging(false);
  }

  @override
  void dispose() {
    _bleSubscription?.cancel();
    _sensorSubscription?.cancel();
    super.dispose();
  }


  bool _wifiConnected = false;
  bool get wifiConnected => _wifiConnected;

  void toggleWifi() {
    _wifiConnected = !_wifiConnected;
    notifyListeners();
  }
}
