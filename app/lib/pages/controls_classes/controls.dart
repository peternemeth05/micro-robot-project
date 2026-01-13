import 'package:flutter/material.dart';
import'custom_joystick.dart';
import 'predetermined_paths.dart';


class RobotControlsPage extends StatelessWidget {
  const RobotControlsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            elevation: 0,
            bottom: const TabBar(
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
              PredeterminedPaths()
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
