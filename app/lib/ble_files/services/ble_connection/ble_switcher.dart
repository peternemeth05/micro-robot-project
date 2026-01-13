import 'package:flutter/foundation.dart' show kIsWeb;
import 'ble_interface.dart';
import 'ble_native.dart';
import 'ble_web.dart';

// This function acts as the "Traffic Cop"
BleInterface getBleDriver() {
  if (kIsWeb) {
    print("Running on Web - Loading Web Driver");
    return BleWeb();
  } else {
    print("Running on Desktop/Mobile - Loading Native Driver");
    return BleNative();
  }
}