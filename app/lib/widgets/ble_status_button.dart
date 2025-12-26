import 'package:flutter/material.dart';
import '../services/ble_connection/ble_interface.dart';

class BleStatusButton extends StatelessWidget {
  final BleInterface bleDriver;

  // The {} inside the constructor makes 'bleDriver' a NAMED parameter
  const BleStatusButton({super.key, required this.bleDriver});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: bleDriver.connectionStateStream,
      initialData: bleDriver.isConnected,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;
        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Chip(
            avatar: Icon(
              isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
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
      },
    );
  }
}