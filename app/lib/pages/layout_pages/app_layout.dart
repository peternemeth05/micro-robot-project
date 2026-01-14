import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:robot_app/app_states/main_app_state.dart';
import 'package:robot_app/pages/layout_pages/main_pages/robot_controls_page.dart';

import '../../ble_files/widgets/ble_status_button.dart';
import '../../ble_files/widgets/wifi_status_button.dart';

import 'main_pages/landing_page.dart';
import 'main_pages/setup_wizard_page.dart';
import 'main_pages/video_log_page.dart';


class AppLayout extends StatefulWidget { // creates framework for entire app, visible in whole page
  const AppLayout({super.key});
  @override
  State<AppLayout> createState() => _AppLayoutState(); // local state to enable navigation changes
}

class _AppLayoutState extends State<AppLayout> {
  @override
  Widget build(BuildContext context) {
    final pages = [ // the pages selected for each index
      LandingPage(),
      SetupWizardPage(),
      RobotControlsPage(),
      VideoLogPage(),
    ];
    final appState = Provider.of<MainAppState>(context, listen: true);
    int selectedIndex = appState.pageIndex; // page index can be altered from other sources (landing page button)
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800; // adds responsiveness
        return Scaffold(
          appBar: AppBar(
            title: const Text('Robot Controller'),
            actions: [BleStatusButton(), WifiStatusButton()],
          ),
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail( // makes main navigation on LHS of screen
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
