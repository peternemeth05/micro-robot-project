import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Needed for kIsWeb
import 'package:robot_app/ble_files/services/ble_connection/ble_interface.dart';
import '../../pages/layout_pages/scan_screen.dart'; 
import '../services/robot_profiles.dart';

class BleConnectButton extends StatelessWidget {
  final BleInterface bleDriver;
  final List<RobotProfile> targetRobots;
  
  const BleConnectButton({super.key, required this.bleDriver, required this.targetRobots});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: bleDriver.connectionStateStream,
      initialData: bleDriver.isConnected,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;

        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isConnected ? Colors.blue : Colors.red,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18),
          ),
          icon: Icon(isConnected ? Icons.bluetooth_connected : Icons.bluetooth),
          // showing the label how many robots are slected
          label: Text(
            isConnected 
              ? "Disconnect" 
              : targetRobots.isEmpty 
                  ? "Select a Robot" 
                  : "Scan for ${targetRobots.length} Robot(s)"
          ),
          
          onPressed: () => _handlePress(context, isConnected),
        );
      },
    );
  }

  void _handlePress(BuildContext context, bool isConnected) async {
    // to disconnect
    if (isConnected) {
      await bleDriver.disconnect();
      return;
    }

    // to ensure there is one robot connected
    if (targetRobots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one robot first!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }


    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanScreen(bleDriver: bleDriver, targetRobots: targetRobots), 
      ),
    );
    


  }
}