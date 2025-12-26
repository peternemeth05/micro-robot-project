import 'package:flutter/material.dart';

import 'pages/landing.dart';
import 'pages/setup.dart';
import 'pages/controls.dart';
import 'pages/sensor.dart';
import 'pages/video.dart';
import 'services/ble_connection/ble_driver.dart';

class AppLayout extends StatefulWidget {
  
  const AppLayout({super.key});



  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final BleDriver _bleDriver = BleDriver();
  int selectedIndex = 0;

   

  @override
  Widget build(BuildContext context) {
    
    final pages =  [
    LandingPage(),
    SetupWizardPage(bleDriver: _bleDriver),
    RobotControlsPage(),
    SensorLogPage(),
    VideoLogPage(),
  ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(title: const Text('Robot Controller')),
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: isWide,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (i) =>
                      setState(() => selectedIndex = i),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Set-up Wizard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.route),
                      label: Text('Robot Controls'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.polyline),
                      label: Text('Sensor Log'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.camera),
                      label: Text('Video Log'),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: pages[selectedIndex]),
            ],
          ),
        );
      },
    );
  }
}
