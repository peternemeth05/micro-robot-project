import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_interface.dart';
import '../../constants.dart';

class BleNative implements BleInterface {
  // CONFIGURATION
  static const String _serviceUuid = BleConstants.serviceUuid;
  static const String _charUuid = BleConstants.charUuid;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _sharedChar;
  
  // Native uses BluetoothConnectionState instead of a boolean for the listener
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  final _connectionStateController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get connectionStateStream => _connectionStateController.stream;


  final _sensorDataController = StreamController<String>.broadcast();

  @override
  Stream<String> get sensorDataStream => _sensorDataController.stream;

  

  @override
  bool get isConnected => _connectedDevice != null;

  @override
  Future<void> connect(String deviceId) async {
    print("(Native) Connecting to $deviceId...");
    try {

      // 1. CONNECT TO ROBOT


      final device = BluetoothDevice.fromId(deviceId);

      // Listens to the device connection state 
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
           print("(Native) Device reported disconnection!");
           // We only trigger cleanup if we thought we were connected
           if (_connectedDevice != null) {
             disconnect();
           }
        }
      });


      
      // Connect 
      await device.connect(autoConnect: false);

      // 2. CONFIRM UUIDS
      print("(Native) Discovering Services...");
      final services = await device.discoverServices();
      
      // Find and Print Service UUID
      final targetService = services.firstWhere(
        (s) => s.uuid == Guid(_serviceUuid),
        orElse: () => throw Exception("Service not found"),
      );

      print("------------------------------------------------");
      print("FOUND SERVICE");
      print("   Expected: $_serviceUuid"); 
      print("   Actual:   ${targetService.uuid}"); 
      print("");

      // Find and print Characteristic UUID
      _sharedChar = targetService.characteristics.firstWhere(
        (c) => c.uuid == Guid(_charUuid),
        orElse: () => throw Exception("Characteristic not found"),
      );

      print("FOUND Write CHARACTERISTIC");
      print("   Expected: $_charUuid");
      print("   Actual:   ${_sharedChar!.uuid}");
      print("------------------------------------------------");

      _connectedDevice = device;
      _connectionStateController.add(true);
      print("(Native) Connection & Setup Complete!");


      // listening to robot
      await _sharedChar!.setNotifyValue(true);

      _sharedChar!.lastValueStream.listen((List<int> rawData) {
        if (rawData.isEmpty) return;
        try {
          // Decode bytes to text 
          String decoded = utf8.decode(rawData);
          _sensorDataController.add(decoded); 
          print("(Native) RX: $decoded");
        } catch (e) {
          print("Error decoding: $e");
        }
      });

      



    } catch (e) {
      print("(Native) Connection Failed: $e");
      disconnect(); // Ensure disconnect if doesnt work
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    
    if (_connectedDevice == null) return;

    // Update local state
    _connectionStateController.add(false);

    // Cancel the listener so it doesnt keep firing
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    final device = _connectedDevice;
    _connectedDevice = null;
    _sharedChar = null;

    // Actually disconnect
    try {
      await device?.disconnect();
      print("○ (Native) Disconnected.");
    } catch (e) {
      print("Error during disconnect: $e");
    }
  }

  @override
  Future<void> writeToCharacteristic(List<int> data) async {
    if (_sharedChar == null) {
      print("Cannot write: Not connected.");
      return;
    }
    try {
      // Native write to robot
      await _sharedChar!.write(data, withoutResponse: true);
    } catch (e) {
      print("Write Error: $e");
    }
  }
}