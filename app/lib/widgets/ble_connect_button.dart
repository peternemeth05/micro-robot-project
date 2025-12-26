import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Needed for kIsWeb
import 'package:robot_app/services/ble_connection/ble_interface.dart';
import '../services/ble_connection/ble_driver.dart';
import '../pages/scan_screen.dart'; 

class BleConnectButton extends StatelessWidget {
  final BleInterface bleDriver;
  
  const BleConnectButton({super.key, required this.bleDriver});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: bleDriver.connectionStateStream,
      initialData: bleDriver.isConnected,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;

        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isConnected ? Colors.red : Colors.blue,
            foregroundColor: Colors.white,
          ),
          icon: Icon(isConnected ? Icons.bluetooth_connected : Icons.bluetooth),
          label: Text(isConnected ? "Disconnect" : "Connect Robot"),
          
          onPressed: () => _handlePress(context, isConnected),
        );
      },
    );
  }

  void _handlePress(BuildContext context, bool isConnected) async {
    // 1. DISCONNECT
    if (isConnected) {
      await bleDriver.disconnect();
      return;
    }


      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanScreen(bleDriver: bleDriver), 
        ),
      );
    
  }
}