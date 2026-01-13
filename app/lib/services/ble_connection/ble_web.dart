import 'dart:async';
import 'dart:typed_data'; // Needed for Uint8List
import 'dart:convert';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'ble_interface.dart';
import '../../constants.dart';

class BleWeb implements BleInterface {
  // CONFIGURATION (Must match your C Code)
  static const String _serviceUuid = BleConstants.serviceUuid;
  static const String _charUuid = BleConstants.charUuid;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _sharedChar;
  
  // We need to keep track of the stream subscription so we can cancel it cleanly
  StreamSubscription<bool>? _connectionSubscription;

  bool _isInternalConnected = false;

  final _connectionStateController = StreamController<bool>.broadcast();
  final _sensorDataController = StreamController<String>.broadcast();

  @override
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  @override
  bool get isConnected => _isInternalConnected;

  @override
  Stream<String> get sensorDataStream => _sensorDataController.stream;

  @override
  Future<void> connect(String deviceId) async {
    try {
      final device = await FlutterWebBluetooth.instance.requestDevice(
      RequestOptionsBuilder(
        [
          RequestFilterBuilder(services: [_serviceUuid]), 
        ],
        optionalServices: [_serviceUuid],
      ),
    );

      await device.connect();
      
      // 1. NEW: Listen to the device's connection stream immediately!
      // If the browser reports a disconnect, we update our app state automatically.
      _connectionSubscription = device.connected.listen((connected) {
        if (!connected) {
          print("⚠️ (Web) Browser reported Bluetooth disconnection!");
          disconnect(); 
        }
      });

      
      final services = await device.discoverServices();
      
      final targetService = services.firstWhere(
        (s) => s.uuid == _serviceUuid,
        orElse: () => throw Exception("Service not found"),
      );

      print("------------------------------------------------");
      print("✅ FOUND SERVICE");
      print("   Expected: $_serviceUuid"); 
      print("   Actual:   ${targetService.uuid}"); 
      print("");

      final characteristics = await targetService.getCharacteristics();
      _sharedChar = characteristics.firstWhere(
        (c) => c.uuid == _charUuid,
        orElse: () => throw Exception("Characteristic not found"),
      ); 

      print("✅ FOUND write/read CHARACTERISTIC");
      print("   Expected: $_charUuid");
      print("   Actual:   ${_sharedChar!.uuid}");
      print("------------------------------------------------");

      _connectedDevice = device;
      
      _isInternalConnected = true;
      _connectionStateController.add(true);
      print("✅ (Web) Connected!");



      // 1. Enable Notifications
      await _sharedChar!.startNotifications();

      // 2. Listen for Data
      _sharedChar!.value.listen((ByteData? data) {
        if (data == null || data.lengthInBytes == 0) return;
        final list = data.buffer.asUint8List();
        try {
          String decoded = utf8.decode(list);
          _sensorDataController.add(decoded);
          print("(Web) RX: $decoded");
        } catch (e) {
          print("Web Decode Error: $e");
        }
      });



    } catch (e) {
      print("❌ (Web) Connection Failed: $e");
      disconnect();
    }
  }

  @override
  Future<void> disconnect() async {
    // 2. Prevent infinite loops (if already disconnected, stop)
    if (!_isInternalConnected) return;

    _isInternalConnected = false;
    _connectionStateController.add(false);

    // Cancel the listener so it doesn't fire again for this specific session
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    if (_connectedDevice != null) {
      try {
        _connectedDevice!.disconnect();
      } catch (e) {
        // Ignore errors during disconnect
      }
      _connectedDevice = null;
      _sharedChar = null;
    }
  }

  @override
  Future<void> writeToCharacteristic(List<int> data) async {
    if (_sharedChar == null) return;
    try {
      await _sharedChar!.writeValueWithoutResponse(Uint8List.fromList(data)); 
    } catch (e) {
      print("Web Write Error: $e");
    }
  }
}