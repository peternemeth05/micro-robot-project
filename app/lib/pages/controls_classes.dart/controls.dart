import 'package:flutter/material.dart';
import'custom_joystick.dart';
import 'predetermined_paths';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState1(),
      child: MaterialApp(
        title: 'Joystick Control',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const RobotControlsPage(),
      ),
    );
  }
}

class MyAppState1 extends ChangeNotifier {
  // Joystick coordinates
  double x = 0;
  double y = 0;

  void updateJoystick(double newX, double newY) {
    x = newX;
    y = newY;
    notifyListeners(); 
    print("X:  $newX Y:  newY");
  }

  void getNext() {
    notifyListeners();
  }
}

class RobotControlsPage extends StatelessWidget {
  const RobotControlsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: const TabBar(
              labelColor:  Colors.black,
              tabs: [
                Tab(text: "Predetermined Paths"),
                Tab(text: "Virtual Joystick"),
              ],
          ), 
        ),
    
      
      body: TabBarView(
          children: [
            const Center(
              child: 
              PrederterminedPaths()
              ),
            const Center (
              child: 
              CustomJoystick(),
            )
          ],
        ),
      ),
    );
  }
  
}
