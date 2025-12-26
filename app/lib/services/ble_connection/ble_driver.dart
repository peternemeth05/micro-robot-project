// lib/services/ble_connection/ble_driver.dart
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_interface.dart';
import '../../constants.dart';


export 'ble_native.dart' 
  if (dart.library.html) 'ble_web.dart';

class BleDriver implements BleInterface {

  static const String _serviceUuid = BleConstants.serviceUuid;
  static const String _commandUuid = BleConstants.commandUuid;


  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _commandChar;

  // Stream controller to tell the UI when we connect/disconnect
  final _connectionStateController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  @override
  bool get isConnected => _connectedDevice != null;

  // 1. SCANNING IS HANDLED IN THE UI (ScanScreen), so we just focus on Connecting here.

  @override
  Future<void> connect(String deviceId) async {
    try {
      // Create device object from ID
      final device = BluetoothDevice.fromId(deviceId);

      // Connect (autoConnect: false usually works better for BLE)
      await device.connect(autoConnect: false);

      // Discover Services (Find the "Folder" with our UUID)
      final services = await device.discoverServices();

      // Find our specific Service
      final targetService = services.firstWhere(
        (s) => s.uuid.toString() == _serviceUuid,
        orElse: () => throw Exception("Robot Service not found!"),
      );

      // Find the Command Characteristic (The "Mailbox")
      _commandChar = targetService.characteristics.firstWhere(
        (c) => c.uuid.toString() == _commandUuid,
        orElse: () => throw Exception("Command Characteristic not found!"),
      );

      _connectedDevice = device;
      _connectionStateController.add(true); // Tell UI we are green!
      print("✅ Connected to Robot!");
    } catch (e) {
      print("❌ Connection Failed: $e");
      disconnect(); // Cleanup if failed
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _commandChar = null;
      _connectionStateController.add(false); // Tell UI we are blue/disconnected
      print("○ Disconnected.");
    }
  }

  @override
  Future<void> writeToCharacteristic(List<int> data) async {
    if (_commandChar == null) {
      print("⚠️ Cannot write: Not connected.");
      return;
    }
    // Write the bytes to the robot
    await _commandChar!.write(data, withoutResponse: true);
  }
}
