import 'dart:async';
import 'dart:typed_data'; // Needed for Uint8List
import 'dart:convert';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'ble_interface.dart';
import '../../constants.dart';

class BleWeb implements BleInterface {
  // configuration 
  static const String _serviceUuid = BleConstants.serviceUuid;
  static const String _charUuid = BleConstants.charUuidRX;

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

      // 1. CONNECT TO ROBOT
      final device = await FlutterWebBluetooth.instance.requestDevice(
      RequestOptionsBuilder(
        [
          RequestFilterBuilder(services: [_serviceUuid]), 
        ],
        optionalServices: [_serviceUuid],
      ),
    );

      await device.connect();
      
      // Listen to the devices connection stream immediately
      _connectionSubscription = device.connected.listen((connected) {
        if (!connected) {
          print("(Web) Browser reported Bluetooth disconnection!");
          disconnect(); 
        }
      });

      // 2. CONFIRM UUIDS
      
      final services = await device.discoverServices();
      
      final targetService = services.firstWhere(
        (s) => s.uuid == _serviceUuid,
        orElse: () => throw Exception("Service not found"),
      );

      // Find and print Service UUID
      print("------------------------------------------------");
      print("FOUND SERVICE");
      print("   Expected: $_serviceUuid"); 
      print("   Actual:   ${targetService.uuid}"); 
      print("");

      final characteristics = await targetService.getCharacteristics();
      _sharedChar = characteristics.firstWhere(
        (c) => c.uuid == _charUuid,
        orElse: () => throw Exception("Characteristic not found"),
      ); 

      // Find and print Characteristic UUID
      print("FOUND write/read CHARACTERISTIC");
      print("   Expected: $_charUuid");
      print("   Actual:   ${_sharedChar!.uuid}");
      print("------------------------------------------------");

      _connectedDevice = device;
      
      _isInternalConnected = true;
      _connectionStateController.add(true);
      print("(Web) Connected!");


      // 3. LISTENING TO ROBOT

      // Enable Notifications
      await _sharedChar!.startNotifications();

      // Listen for Data
      _sharedChar!.value.listen((ByteData? data) {
        if (data == null || data.lengthInBytes == 0) return;
        final list = data.buffer.asUint8List();
        try {
          String decoded = utf8.decode(list);
          // Adding to the stream if it has the expected prefix 'DIST'
          if (decoded.startsWith('DIST') || decoded.contains('Distance:')) {
            _sensorDataController.add(decoded);
            print("(Web) RX: $decoded");
          }

        } catch (e) {
          print("Web Decode Error: $e");
        }
      });
      
    } catch (e) {
      print("(Web) Connection Failed: $e");
      disconnect();
    }
  }

  // DISCONNECTING FROM THE ROBOT
  @override
  Future<void> disconnect() async {
    // Prevent infinite loops 
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

  // SENDING BYTES TO THE ROBOT
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