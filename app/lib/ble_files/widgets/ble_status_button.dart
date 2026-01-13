import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_states/ble_app_state.dart';

class BleStatusButton extends StatelessWidget {
  const BleStatusButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Reads state from AppState
    final isConnected = context.watch<AppState>().bleConnected;

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Chip(
        avatar: Icon(
          isConnected
              ? Icons.bluetooth_connected
              : Icons.bluetooth_disabled,
          color: Colors.white,
          size: 18,
        ),
        label: Text(
          isConnected ? "Connected" : "Not Connected",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isConnected ? Colors.green : Colors.grey,
        side: BorderSide.none,
      ),
    );
  }
}
