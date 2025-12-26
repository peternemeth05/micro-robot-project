import 'package:flutter/material.dart';
import 'package:robot_app/services/ble_connection/ble_driver.dart';
import 'package:robot_app/services/ble_connection/ble_interface.dart';

import 'pages/landing.dart';
import 'pages/setup.dart';
import 'pages/controls.dart';
import 'pages/sensor.dart';
import 'pages/video.dart';
// Note: You no longer need to import ble_driver.dart or ble_switcher.dart here
// because the specific implementation is already passed in.

class AppLayout extends StatefulWidget {
  // This is where the choice from the Switcher arrives
  final BleInterface bleDriver; 
  
  const AppLayout({super.key, required this.bleDriver});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // We define 'pages' inside build() so we can access 'widget.bleDriver'
    final pages = [
      const LandingPage(),
      // PASS THE DRIVER DOWN: Use widget.bleDriver here
      SetupWizardPage(bleDriver: widget.bleDriver),
      RobotControlsPage(), // Assuming this page needs it too
      SensorLogPage(),     // Assuming this page needs it too
      const VideoLogPage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Simple responsive check: Wide screen = extended rail
        final isWide = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(title: const Text('Robot Controller')),
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: isWide,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (i) => setState(() => selectedIndex = i),
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
                      icon: Icon(Icons.gamepad), // Changed icon to gamepad for controls
                      label: Text('Robot Controls'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.list_alt), // Changed icon to list for logs
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
              // This displays the selected page from the list above
              Expanded(child: pages[selectedIndex]),
            ],
          ),
        );
      },
    );
  }
}