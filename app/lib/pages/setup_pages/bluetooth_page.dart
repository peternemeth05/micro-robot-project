import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:robot_app/services/ble_connection/ble_interface.dart';
import '../../widgets/ble_connect_button.dart';
import '../../services/robot_profiles.dart';


class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothState();
}

class _BluetoothState extends State<BluetoothPage> {
  final Set<String> _selectedRobotIds = {};

  void _toggleRobot(String id) {
    setState(() {
      if (_selectedRobotIds.contains(id)) {
        _selectedRobotIds.remove(id);
      } else {
        _selectedRobotIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read the shared BLE service from Provider (created once in main)
    final bleDriver = context.read<BleInterface>();

    final targetRobots =
        knownRobots.where((r) => _selectedRobotIds.contains(r.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Setup Wizard")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Select Target Robots',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: knownRobots.length,
                itemBuilder: (context, index) {
                  final robot = knownRobots[index];
                  final isChecked = _selectedRobotIds.contains(robot.id);

                  return Card(
                    color: isChecked ? Colors.red : Colors.grey.shade200,
                    child: CheckboxListTile(
                      title: Text(robot.name),
                      subtitle: Text("ID: ${robot.id}"),
                      value: isChecked,
                      onChanged: (_) => _toggleRobot(robot.id),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            BleConnectButton(
              bleDriver: bleDriver,
              targetRobots: targetRobots,
            ),

            const SizedBox(height: 20),

            OutlinedButton(
              onPressed: () async {
                try {
                  await bleDriver.writeToCharacteristic('T'.codeUnits);
                  debugPrint("✅ 'T' Sent!");
                } catch (e) {
                  debugPrint("❌ $e");
                }
              },
              child: const Text("Test: Send 'T'"),
            ),
          ],
        ),
      ),
    );
  }
}
