import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_states/ble_app_state.dart';

class WifiStatusButton extends StatelessWidget {
  const WifiStatusButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Reads state from AppState
    final isConnected = context.watch<AppState>().wifiConnected;

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Chip(
        avatar: Icon(
          isConnected // will change icon if connected
              ? Icons.wifi_sharp
              : Icons.wifi_off,
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
        backgroundColor: isConnected ? Colors.green : Colors.grey, // will change color if connected
        side: BorderSide.none,
      ),
    );
  }
}
