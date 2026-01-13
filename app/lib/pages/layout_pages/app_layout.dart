import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:robot_app/app_states/main_app_state.dart';
import 'package:robot_app/pages/layout_pages/main_pages/robotinfo.dart';

import '../../ble_files/widgets/ble_status_button.dart';
import '../../ble_files/widgets/wifi_status_button.dart';

import 'main_pages/landing.dart';
import 'main_pages/setup.dart';
import 'main_pages/video.dart';


class AppLayout extends StatefulWidget {
  const AppLayout({super.key});
  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  @override
  Widget build(BuildContext context) {
    final pages = [
      LandingPage(),
      SetupWizardPage(),
      RobotInfoPage(),
      VideoLogPage(),
    ];
    final appState = Provider.of<MyAppState1>(context, listen: true);
    int selectedIndex = appState.pageIndex;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Robot Controller'),
            actions: [BleStatusButton(), WifiStatusButton()],
          ),
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: isWide,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (i) => appState.changeIndex(i),
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
