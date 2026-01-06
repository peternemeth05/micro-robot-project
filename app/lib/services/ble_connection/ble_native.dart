import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_interface.dart';
import '../../constants.dart';

class BleNative implements BleInterface {
  // CONFIGURATION
  static const String _serviceUuid = BleConstants.serviceUuid;
  static const String _commandUuid = BleConstants.commandUuid;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _commandChar;
  
  // Native uses 'BluetoothConnectionState' instead of a boolean for the listener
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  final _connectionStateController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  @override
  bool get isConnected => _connectedDevice != null;

  @override
  Future<void> connect(String deviceId) async {
    print("⏳ (Native) Connecting to $deviceId...");
    try {
      final device = BluetoothDevice.fromId(deviceId);

      // 1. Listen to the device's connection state immediately
      // This handles if the device disconnects (e.g. goes out of range or turned off)
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
           print("⚠️ (Native) Device reported disconnection!");
           // We only trigger cleanup if we thought we were connected
           if (_connectedDevice != null) {
             disconnect();
           }
        }
      });
      
      // Connect (autoConnect: false is generally more reliable for explicit connections)
      await device.connect(autoConnect: false);
      
      print("⏳ (Native) Discovering Services...");
      final services = await device.discoverServices();
      
      // 2. Find and Print Service UUID
      // Note: Native uses 'Guid' objects for UUIDs, so we convert our string to match.
      final targetService = services.firstWhere(
        (s) => s.uuid == Guid(_serviceUuid),
        orElse: () => throw Exception("Service not found"),
      );

      print("------------------------------------------------");
      print("✅ FOUND SERVICE");
      print("   Expected: $_serviceUuid"); 
      print("   Actual:   ${targetService.uuid}"); 
      print("");

      // 3. Find and Print Characteristic UUID
      _commandChar = targetService.characteristics.firstWhere(
        (c) => c.uuid == Guid(_commandUuid),
        orElse: () => throw Exception("Characteristic not found"),
      );

      print("✅ FOUND Write CHARACTERISTIC");
      print("   Expected: $_commandUuid");
      print("   Actual:   ${_commandChar!.uuid}");
      print("------------------------------------------------");

      _connectedDevice = device;
      _connectionStateController.add(true);
      print("✅ (Native) Connection & Setup Complete!");

    } catch (e) {
      print("❌ (Native) Connection Failed: $e");
      disconnect(); // Clean up
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    // If already disconnected, stop
    if (_connectedDevice == null) return;

    // Update local state
    _connectionStateController.add(false);

    // Cancel the listener so it doesn't keep firing
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    final device = _connectedDevice;
    _connectedDevice = null;
    _commandChar = null;

    // Actually disconnect from the OS
    try {
      await device?.disconnect();
      print("○ (Native) Disconnected.");
    } catch (e) {
      print("Error during disconnect: $e");
    }
  }

  @override
  Future<void> writeToCharacteristic(List<int> data) async {
    if (_commandChar == null) {
      print("⚠️ Cannot write: Not connected.");
      return;
    }
    try {
      // Native write
      await _commandChar!.write(data, withoutResponse: true);
    } catch (e) {
      print("Write Error: $e");
    }
  }
}