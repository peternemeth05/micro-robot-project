import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';

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
