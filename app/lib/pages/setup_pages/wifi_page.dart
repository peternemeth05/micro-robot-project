import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_states/ble_app_state.dart';
import 'dart:convert';

import 'package:robot_app/ble_files/services/ble_connection/ble_interface.dart';
import '../../ble_files/widgets/ble_connect_button.dart';
import '../../ble_files/services/robot_profiles.dart';



// Wifi has not been implemented, this page just contains a button that toggles wifi state and has no real backend
class WifiPage extends StatelessWidget {
  const WifiPage({super.key});

  @override
  Widget build(BuildContext context) {
    // You need to grab the bleDriver from the provider to use it inside the button
    final bleDriver = context.read<BleInterface>();
    final TextEditingController _ssidController = TextEditingController();
    final TextEditingController _passController = TextEditingController();

    return Center(
      child: Column( // Use a Column so buttons don't overlap in the SizedBox
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(//Text field where you input the ssid of the wifi
            controller: _ssidController,
            decoration: InputDecoration(labelText: 'Wi-Fi Name (SSID)'),
          ),
          TextField(//Text where you input the wifi password
            controller: _passController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
          ),
          SizedBox(
            width: 250,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                context.read<AppState>().toggleWifi();
              },
              child: const Text('Toggle App State WiFi', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 250,
            height: 60,
            child: ElevatedButton(
              onPressed: () async { // Fixed the syntax: onPressed: () async { ... }
                try {
                  // This command tells the robot to start a Wi-Fi Scan
                  await bleDriver.writeToCharacteristic(utf8.encode('N#1#${_ssidController.text}#${_passController.text}#'));
                  debugPrint("Wi-Fi Scan Command Sent!");
                } catch (e) {
                  debugPrint("BLE Write Error: $e");
                }
              },
              child: const Text('Send Wifi info to Robot'),
            ),
          ),
        ],
      ),
    );
  }
}