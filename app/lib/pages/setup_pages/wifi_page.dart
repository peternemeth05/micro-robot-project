import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_states/ble_app_state.dart';

// Wifi has not been implemented, this page just contains a button that toggles wifi state and has no real backend

class WifiPage extends StatelessWidget {
  const WifiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 180,
        height: 60,
        child: ElevatedButton(
          onPressed: () {
            context.read<AppState>().toggleWifi();
          },
          child: const Text('Toggle WiFi', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}