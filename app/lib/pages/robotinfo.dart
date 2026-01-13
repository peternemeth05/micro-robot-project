import 'package:flutter/material.dart';
import 'package:robot_app/pages/sensor_pages/geninfopage.dart';
import 'sensor_pages/sensor.dart';
import 'controls_classes/predetermined_paths.dart';

class RobotInfoPage extends StatefulWidget {
  const RobotInfoPage({super.key});

  @override
  State<RobotInfoPage> createState() => _RobotInfoPageState();
}

class _RobotInfoPageState extends State<RobotInfoPage> {
  int selectedIndex = 0;

@override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Main Controls'),
                  Tab(text: "Automatic Paths"),
                  Tab(text: 'Plotted Data'),
                ],
              ),

              const Divider(height: 1),

              const Expanded(
                child: TabBarView(children: [GeneralInfoPage(), PredeterminedPaths(), SensorLogPage()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
