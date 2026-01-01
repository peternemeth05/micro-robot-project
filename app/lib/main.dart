import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_layout.dart';
import 'app_state.dart';

import 'package:robot_app/services/ble_connection/ble_interface.dart';
import 'services/ble_connection/ble_driver.dart';
import 'services/ble_connection/ble_switcher.dart';

void main() {
  final BleInterface bleDriver = getBleDriver();

  runApp(
    MultiProvider(
      providers: [
        // App-wide UI state
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(),
        ),

        // App-wide BLE service
        Provider<BleInterface>.value(
          value: bleDriver,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const AppLayout(),
    );
  }
}
