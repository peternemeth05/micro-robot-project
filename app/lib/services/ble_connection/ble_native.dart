import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_interface.dart';
import '../../constants.dart';

class BleDriver implements BleInterface {
  // CONFIGURATION (Must match your C Code)
  static const String _serviceUuid = BleConstants.serviceUuid;
  static const String _commandUuid = BleConstants.commandUuid;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _commandChar;
  
  final _connectionStateController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  @override
  bool get isConnected => _connectedDevice != null;

  @override
  Future<void> connect(String deviceId) async {
    try {
      final device = BluetoothDevice.fromId(deviceId);
      
      // Android/iOS Native connection logic
      await device.connect(autoConnect: false);
      
      final services = await device.discoverServices();
      final targetService = services.firstWhere(
        (s) => s.uuid.toString() == _serviceUuid,
        orElse: () => throw Exception("Service not found"),
      );

      _commandChar = targetService.characteristics.firstWhere(
        (c) => c.uuid.toString() == _commandUuid,
        orElse: () => throw Exception("Characteristic not found"),
      );

      _connectedDevice = device;
      _connectionStateController.add(true);
      print("✅ (Native) Connected to $deviceId");

    } catch (e) {
      print("❌ (Native) Connection Failed: $e");
      disconnect();
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _commandChar = null;
      _connectionStateController.add(false);
      print("○ (Native) Disconnected.");
    }
  }

  @override
  Future<void> writeToCharacteristic(List<int> data) async {
    if (_commandChar == null) return;
    try {
      await _commandChar!.write(data, withoutResponse: true);
    } catch (e) {
      print("Write Error: $e");
    }
  }
}