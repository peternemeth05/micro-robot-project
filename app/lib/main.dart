import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_state.dart';
import 'app_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
 return ChangeNotifierProvider(
      create: (_) => MyAppState(),
      child: MaterialApp(
        title: 'Robot App',

        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: const ColorScheme.light(
            primary: Colors.grey,
            secondary: Colors.red,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Colors.black),
            backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(158, 158, 158, 0.3)),
            visualDensity: VisualDensity(horizontal: 3.0,vertical: 3.0))
            ),
        ),

        darkTheme: ThemeData(
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.red),
            visualDensity: VisualDensity(horizontal: 3.0,vertical: 3.0))
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
