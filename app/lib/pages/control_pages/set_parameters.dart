import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_states/ble_app_state.dart';
import 'dart:convert';

import 'package:robot_app/ble_files/services/ble_connection/ble_interface.dart';
import '../../ble_files/widgets/ble_connect_button.dart';
import '../../ble_files/services/robot_profiles.dart';



// Wifi has not been implemented, this page just contains a button that toggles wifi state and has no real backend
class SetParametersPage extends StatefulWidget {
  const SetParametersPage({super.key});

  @override
  State<SetParametersPage> createState() => _SetParametersPageState();
}

class _SetParametersPageState extends State<SetParametersPage> {
  double _voltageInput = 0.0; // Default voltage value
  @override
  Widget build(BuildContext context) {
    // You need to grab the bleDriver from the provider to use it inside the button
    final bleDriver = context.read<BleInterface>();
    final TextEditingController _passController = TextEditingController();

    return Center(
      child: Column( // Use a Column so buttons don't overlap in the SizedBox
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Slider(
            value: _voltageInput,
            onChanged: (value) {
              setState(() {
                _voltageInput = value;
              });
            },
            label: _voltageInput.toStringAsFixed(2),
            min: -5,
            max: 5,
            divisions: 100,
      
          ),
          
          const SizedBox(height: 20),
          SizedBox(
            width: 250,
            height: 60,
            child: ElevatedButton(
              onPressed: () async { // Fixed the syntax: onPressed: () async { ... }
                try {
                  // This command tells the robot to start a Wi-Fi Scan
                  await bleDriver.writeToCharacteristic(utf8.encode('N#1#${_voltageInput}'));
                  debugPrint("Wi-Fi Scan Command Sent!");
                } catch (e) {
                  debugPrint("BLE Write Error: $e");
                }
              },
              child: const Text('Set Voltage Value'),
            ),
          ),
        ],
      ),
    );
  }
}