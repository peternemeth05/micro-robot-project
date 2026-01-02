import 'package:flutter/material.dart';
import'custom_joystick.dart';
import 'predetermined_paths';


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
