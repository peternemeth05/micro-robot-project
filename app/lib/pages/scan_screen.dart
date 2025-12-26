// lib/pages/scan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/ble_connection/ble_driver.dart';
import '../constants.dart';

class ScanScreen extends StatefulWidget {
  final BleDriver bleDriver;
  const ScanScreen({super.key, required this.bleDriver});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  // We use the FlutterBluePlus singleton for scanning
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);

    // Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          // No need to filter by name anymore!
          // The OS only gives us devices with the right Service UUID.
          _scanResults = results;
        });
      }
    });

    // START SCANNING WITH FILTER
    try {
      await FlutterBluePlus.startScan(
        // This is the magic line:
        withServices: [Guid(BleConstants.serviceUuid)],
        timeout: const Duration(seconds: 10),
      );
    } catch (e) {
      print("Scan Error: $e");
    }

    if (mounted) {
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find Your Robot")),
      body: Column(
        children: [
          if (_isScanning) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _scanResults.length,
              itemBuilder: (context, index) {
                final result = _scanResults[index];
                final name = result.device.platformName;
                final id = result.device.remoteId.str;

                return ListTile(
                  title: Text(name.isEmpty ? "Unknown Device" : name),
                  subtitle: Text(id),
                  trailing: ElevatedButton(
                    child: const Text("Connect"),
                    onPressed: () async {
                      // Stop scanning before connecting
                      FlutterBluePlus.stopScan();

                      // Call the connect method in our Driver
                      await widget.bleDriver.connect(id);

                      // Go back to previous screen
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isScanning ? null : _startScan,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
