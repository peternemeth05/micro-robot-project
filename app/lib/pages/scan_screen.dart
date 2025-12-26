import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:robot_app/services/ble_connection/ble_interface.dart';
import '../constants.dart';

class ScanScreen extends StatefulWidget {
  final BleInterface bleDriver;
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
    // Don't just call _startScan(); call a new safe method
    _waitForBluetoothAndScan();
  }

  Future<void> _waitForBluetoothAndScan() async {
    // 1. Wait for the Bluetooth Adapter to turn ON
    try {
      // If it's not already on, wait for it (with a timeout so we don't hang forever)
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        await FlutterBluePlus.adapterState
            .firstWhere((state) => state == BluetoothAdapterState.on)
            .timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      // If it takes too long or fails, just print error and return
      print("Error waiting for Bluetooth: $e");
      return;
    }

    // 2. Now that it is ON, we can safely scan
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);

    // Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          // The OS only gives us devices with the right Service UUID.
          _scanResults = results;
        });
      }
    });

    // START SCANNING WITH FILTER
    try {
      await FlutterBluePlus.startScan(
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
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, 
                      backgroundColor: Colors.white, 
                    ),
                    onPressed: () async {
                      // 1. Stop scanning before connecting
                      FlutterBluePlus.stopScan();

                      // 2. Show the "Pop Up" (Loading Dialog)
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            content: Row(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 20),
                                Text("Connecting..."),
                              ],
                            ),
                          );
                        },
                      );

                      try {
                        // 3. Call the connect method in our Driver
                        await widget.bleDriver.connect(id);

                        // 4. Close the Loading Dialog
                        if (context.mounted) Navigator.pop(context);

                        // 5. Back out to the Setup Screen
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        // If failed, close the dialog but stay on Scan Screen
                        if (context.mounted) Navigator.pop(context);
                        
                        // Show error message
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Connection failed: $e")),
                          );
                        }
                      }
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