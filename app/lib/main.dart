import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_states/main_app_state.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:robot_app/app_states/ble_app_state.dart';
import 'pages/layout_pages/app_layout.dart';


import 'ble_files/services/ble_connection/ble_interface.dart';
import 'ble_files/services/ble_connection/ble_switcher.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open Hive box for timestamped sensor data
  // Each entry: { 'timestamp': String, 'value': String }
  await Hive.openBox<Map>('sensor_log');

  // Select correct BLE implementation
  final BleInterface bleDriver = getBleDriver();

  runApp(
    MultiProvider(
      providers: [
        // Provide BLE implementation
        Provider<BleInterface>.value(value: bleDriver),

        // Centralized app state
        ChangeNotifierProvider<AppState>(
          create: (context) {
            final appState = AppState();
            appState.bindBle(context.read<BleInterface>());
            return appState;
          },
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
    // Wraps app with ChangeNotifierProvider so App State can be updated anywhere in the app
    return ChangeNotifierProvider(
      create: (_) => MainAppState(context.read<BleInterface>()),
      child: MaterialApp(
        title: 'Robot App',

        // Theme data containing stlying for light and dark mode
        theme: ThemeData(
          brightness: Brightness.light,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
          colorScheme: const ColorScheme.light(
            primary: Colors.red,
            secondary: Colors.blueGrey,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(Colors.black),
              backgroundColor: WidgetStateProperty.all(Colors.red),
              textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 18),),
              visualDensity: const VisualDensity(
                horizontal: 3.0,
                vertical: 3.0,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(Colors.blueGrey),
              backgroundColor: WidgetStateProperty.all(Colors.white),
              visualDensity: VisualDensity(horizontal: 3.0,vertical: 3.0),
              textStyle: WidgetStateProperty.all(
                const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          tabBarTheme: TabBarThemeData(
            indicatorColor: Colors.red,
            labelStyle: TextStyle(color: Colors.black)
          )
        ),

        darkTheme: ThemeData(
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(Colors.white),
              backgroundColor: WidgetStateProperty.all(Colors.red),
              textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 18),),
              visualDensity: const VisualDensity(
                horizontal: 3.0,
                vertical: 3.0,
              ),
            ),
          ),

          tabBarTheme: TabBarThemeData(
            indicatorColor: Colors.red,
            labelStyle: TextStyle(color: Colors.white)
          ),
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Colors.black,
            secondary: Colors.red,
          ),
        ),

        themeMode: ThemeMode.system,
        home: const AppLayout(),
      ),
    );
  }
}
