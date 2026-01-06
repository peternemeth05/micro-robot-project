// lib/services/ble_connection/ble_interface.dart
import 'dart:async';

abstract class BleInterface {
  // Is the robot connected right now?
  bool get isConnected;
  
  // A stream so the UI knows when connection status changes
  Stream<bool> get connectionStateStream;
  
  // Actions
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  
  // Sending Commands (Simple bytes for your C code)
  Future<void> writeToCharacteristic(List<int> data);
}