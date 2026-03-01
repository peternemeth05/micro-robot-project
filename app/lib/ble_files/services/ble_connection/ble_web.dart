import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'ble_interface.dart';
import '../../constants.dart';

class BleWeb implements BleInterface {
  static const String _serviceUuid = BleConstants.serviceUuid;
  static const String _writeUuid = BleConstants.charUuidTX; // TX - write
  static const String _notifyUuid = BleConstants.charUuidRX; // RX - notify

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeChar;  // for sending commands
  BluetoothCharacteristic? _notifyChar; // for receiving data

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
          [RequestFilterBuilder(services: [_serviceUuid])],
          optionalServices: [_serviceUuid],
        ),
      );

      await device.connect();
      print("(Web) Connection established...");

      // 2. CONFIRM UUIDS
      final services = await device.discoverServices();

      final targetService = services.firstWhere(
        (s) => s.uuid == _serviceUuid,
        orElse: () => throw Exception("Service not found"),
      );

      print("------------------------------------------------");
      print("FOUND SERVICE");
      print("   Expected: $_serviceUuid");
      print("   Actual:   ${targetService.uuid}");
      print("");

      final characteristics = await targetService.getCharacteristics();

      // DEBUG: print all characteristics and their properties
      print("=== ALL CHARACTERISTICS ===");
      for (final c in characteristics) {
        final p = c.properties;
        print("UUID: ${c.uuid}");
        print("  broadcast:        ${p.broadcast}");
        print("  read:             ${p.read}");
        print("  writeWithoutResponse: ${p.writeWithoutResponse}");
        print("  write:            ${p.write}");
        print("  notify:           ${p.notify}");
        print("  indicate:         ${p.indicate}");
        print("");
      }
      print("===========================");

      // Find write characteristic (ffe2)
      _writeChar = characteristics.firstWhere(
        (c) => c.uuid == _writeUuid,
        orElse: () => throw Exception("Write characteristic not found"),
      );

      // Find notify characteristic (ffe1)
      _notifyChar = characteristics.firstWhere(
        (c) => c.uuid == _notifyUuid,
        orElse: () => throw Exception("Notify characteristic not found"),
      );

      print("FOUND WRITE CHARACTERISTIC: ${_writeChar!.uuid}");
      print("FOUND NOTIFY CHARACTERISTIC: ${_notifyChar!.uuid}");
      print("------------------------------------------------");

      _connectedDevice = device;
      _isInternalConnected = true;
      _connectionStateController.add(true);
      print("(Web) Connected!");

      // 3. LISTEN TO ROBOT via notify characteristic (ffe1)
      await _notifyChar!.startNotifications();

      _notifyChar!.value.listen((ByteData? data) {
        if (data == null || data.lengthInBytes == 0) return;
        final list = data.buffer.asUint8List();
        try {
          String decoded = utf8.decode(list);
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
    if (!_isInternalConnected) return;

    _isInternalConnected = false;
    _connectionStateController.add(false);

    if (_connectedDevice != null) {
      try {
        _connectedDevice!.disconnect();
      } catch (e) {
        // Ignore errors during disconnect
      }
      _connectedDevice = null;
      _writeChar = null;
      _notifyChar = null;
    }
  }

  // SENDING BYTES TO THE ROBOT via write characteristic (ffe2)
  @override
  Future<void> writeToCharacteristic(List<int> data) async {
    if (_writeChar == null) return;
    try {
      await _writeChar!.writeValueWithoutResponse(Uint8List.fromList(data));
    } catch (e) {
      print("Web Write Error: $e");
    }
  }
}