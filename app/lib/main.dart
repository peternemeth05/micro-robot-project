import 'package:flutter/material.dart';
import 'package:robot_app/services/ble_connection/ble_interface.dart';
import 'services/ble_connection/ble_driver.dart';
import 'services/ble_connection/ble_switcher.dart';
import 'app_layout.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final BleInterface bleDriver = getBleDriver();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robot App',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.grey,
        colorScheme: const ColorScheme.light(
          primary: Colors.grey,
          secondary: Colors.red,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey,
        colorScheme: const ColorScheme.dark(
          primary: Colors.black,
          secondary: Colors.red,
        ),
      ),
      themeMode: ThemeMode.system,
      home: AppLayout(bleDriver: bleDriver),
    );
  }
}
