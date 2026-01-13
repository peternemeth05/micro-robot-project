import 'dart:async';
import 'package:robot_app/ble_files/services/ble_connection/ble_interface.dart';


//This class creates a fake bleinterface to simulate the actions of the real interface Class was suggested by AI
class FakeBleInterface implements BleInterface { 
  List<int>? lastDataSent;
  
  
  final StreamController<String> _sensorDataController = StreamController<String>.broadcast();

  @override
  Stream<String> get sensorDataStream => _sensorDataController.stream;
  void feedSensorData(String data) => _sensorDataController.add(data);

  @override
  Future<void> writeToCharacteristic(List<int> data) async {
    lastDataSent = data;
  }

  @override
  Future<void> connect(String deviceId) async {
    return;
  }

  @override
  Future<void> disconnect() async {
    return;
  }

  @override
  bool get isConnected => true;

  @override
  Stream<bool> get connectionStateStream => Stream<bool>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}