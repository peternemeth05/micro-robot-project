import 'dart:async';
import 'dart:typed_data'; // Needed for Uint8List
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'ble_interface.dart';
import '../../constants.dart';

class BleWeb implements BleInterface {
  // CONFIGURATION (Must match your C Code)
  static const String _serviceUuid = BleConstants.serviceUuid;
  static const String _commandUuid = BleConstants.commandUuid;


  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _commandChar;
  
  // 1. WE TRACK STATE LOCALLY (This fixes the 'getter not found' errors)
  bool _isInternalConnected = false;

  final _connectionStateController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  @override
  // 2. The getter just reads our local variable. Simple and crash-proof.
  bool get isConnected => _isInternalConnected;

  @override
  Future<void> connect(String deviceId) async {
    try {
      final device = await FlutterWebBluetooth.instance.requestDevice(
        RequestOptionsBuilder.acceptAllDevices(
          optionalServices: [_serviceUuid], 
        ),
      );

      await device.connect();
      
      final services = await device.discoverServices();
      
      final targetService = services.firstWhere(
        (s) => s.uuid == _serviceUuid,
        orElse: () => throw Exception("Service not found"),
      );

      final characteristics = await targetService.getCharacteristics();
      _commandChar = characteristics.firstWhere(
        (c) => c.uuid == _commandUuid,
        orElse: () => throw Exception("Characteristic not found"),
      );

      _connectedDevice = device;
      
      // 3. Update our local state to TRUE
      _isInternalConnected = true;
      _connectionStateController.add(true);
      print("✅ (Web) Connected!");

    } catch (e) {
      print("❌ (Web) Connection Failed: $e");
      disconnect();
    }
  }

  @override
  Future<void> disconnect() async {
    // 4. Update our local state to FALSE
    _isInternalConnected = false;
    _connectionStateController.add(false);

    if (_connectedDevice != null) {
      try {
        _connectedDevice!.disconnect();
      } catch (e) {
        // Ignore errors during disconnect (it might already be disconnected)
      }
      _connectedDevice = null;
      _commandChar = null;
    }
  }

  @override
  Future<void> writeToCharacteristic(List<int> data) async {
    if (_commandChar == null) return;
    try {
      // 5. Use writeValueWithoutResponse (Standard for commands)
      await _commandChar!.writeValueWithoutResponse(Uint8List.fromList(data)); 
    } catch (e) {
      print("Web Write Error: $e");
    }
  }
}