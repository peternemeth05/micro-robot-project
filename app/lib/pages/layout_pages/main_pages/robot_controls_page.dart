import 'package:flutter/material.dart';
import '../../control_pages/sensor_plots.dart';
import '../../control_pages/set_parameters.dart';

class PotentiostatControlsPage extends StatefulWidget { // serves as robot controls base - creates layout and links to relevant classes for content
  const PotentiostatControlsPage({super.key});

  @override
  State<PotentiostatControlsPage> createState() => _PotentiostatControlsPageState(); // creates state in widget to swap tabs
}

class _PotentiostatControlsPageState extends State<PotentiostatControlsPage> { 
  int selectedIndex = 0;

@override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const TabBar(
                tabs: [ 
                  Tab(text: 'Set Parameters'),
                  Tab(text: 'Plotted Data'),
                ],
              ),

              const Divider(height: 1),

                Expanded( // these contain the content of the pages
                child: TabBarView(
                  children: [SetParametersPage(), 
                  SensorLogPage(),],
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
