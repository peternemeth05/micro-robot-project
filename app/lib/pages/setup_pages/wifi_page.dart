import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';

class WifiPage extends StatelessWidget {
  const WifiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<AppState>().toggleWifi();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white, // text + icon color
      ),
      child: const Text('Toggle WiFi'),
    );
  }
}
