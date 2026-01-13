import 'dart:async';
import 'package:robot_app/services/ble_connection/ble_interface.dart';



class FakeBleInterface implements BleInterface { 
  List<int>?lastDataSent;//AI
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