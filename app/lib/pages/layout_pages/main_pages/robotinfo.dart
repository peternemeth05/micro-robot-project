import 'package:flutter/material.dart';
import 'package:robot_app/pages/control_pages/general_info_page.dart';
import '../../control_pages/sensor_plots.dart';
import '../../control_pages/predetermined_paths.dart';

class RobotControlsPage extends StatefulWidget { // serves as robot controls base - creates layout and links to relevant classes for content
  const RobotControlsPage({super.key});

  @override
  State<RobotControlsPage> createState() => _RobotControlsPageState(); // creates state in widget to swap tabs
}

class _RobotControlsPageState extends State<RobotControlsPage> { 
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

              const Expanded( // these contain the content of the pages
                child: TabBarView(children: [MainControlsPage(), PredeterminedPathsPage(), SensorLogPage()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
