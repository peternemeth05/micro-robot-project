import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:robot_app/services/ble_connection/ble_interface.dart';
import 'widgets/ble_status_button.dart';
import 'widgets/wifi_status_button.dart';

import 'pages/landing.dart';
import 'pages/setup.dart';
import 'pages/controls.dart';
import 'pages/sensor.dart';
import 'pages/video.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    final pages = [
      const LandingPage(),
      SetupWizardPage(),
      RobotControlsPage(),
      SensorLogPage(),
      const VideoLogPage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Robot Controller'),
            actions: [
              BleStatusButton(),
              WifiStatusButton(),
            ],
          ),
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
                      icon: Icon(Icons.gamepad),
                      label: Text('Robot Controls'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.list_alt),
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
