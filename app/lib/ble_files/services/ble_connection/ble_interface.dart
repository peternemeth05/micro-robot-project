
import 'dart:async';

abstract class BleInterface {
  bool get isConnected;
  
  // A stream so the UI knows when connection status changes
  Stream<bool> get connectionStateStream;

  // for recieving data for the ultrasound sensor
  Stream<String> get sensorDataStream;
  
  // Actions
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  
  // Sending Commands (Simple bytes for your C code)
  Future<void> writeToCharacteristic(List<int> data);
}