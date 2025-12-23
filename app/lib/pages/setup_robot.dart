import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_state.dart';

class RobotPage extends StatefulWidget {
  const RobotPage({super.key});

  @override
  State<RobotPage> createState() => _RobotPageState();
}

class _RobotPageState extends State<RobotPage> {
  String? selectedRobot;

  final List<String> robotOptions = [
    "Robot Alpha",
    "Robot Beta",
    "Robot Gamma",
    "Robot Delta",
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 350,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Select Robot:",
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("Choose"),
                    value: selectedRobot,
                    items: robotOptions.map((robot) {
                      return DropdownMenuItem(
                        value: robot,
                        child: Text(robot),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRobot = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            TextButton(
              onPressed: () {},
              child: const Text("Scan Bluetooth"),
            ),
            TextButton(
              onPressed: () {appState.toggleWifi();},
              child: const Text("Enable Wifi"),
            ),
          ],
        ),
      ),
    );
  }
}
