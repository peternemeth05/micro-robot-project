import 'package:flutter/material.dart';
import 'app_layout.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/pages/controls_classes.dart/JoystickState.dart';

void main() {
  runApp(
    ChangeNotifierProvider(//AI
      create: (context) => JoystickState(),
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
