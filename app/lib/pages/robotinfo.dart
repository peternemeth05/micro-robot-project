import 'package:flutter/material.dart';
import 'package:robot_app/pages/sensor_pages/geninfopage.dart';
import 'sensor_pages/sensor.dart';

class RobotInfoPage extends StatefulWidget {
  const RobotInfoPage({super.key});

  @override
  State<RobotInfoPage> createState() => _RobotInfoPageState();
}

class _RobotInfoPageState extends State<RobotInfoPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTab('General Information', 0),
                _buildTab('Graphing', 1),
              ],
            ),

            const Divider(height: 1),

            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: const [
                  GeneralInfoPage(),
                  SensorLogPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Text(
        text,
      ),
    );
  }
}
