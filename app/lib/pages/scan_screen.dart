import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:robot_app/services/ble_connection/ble_interface.dart';
import '../constants.dart';
import '../services/robot_profiles.dart';

class ScanScreen extends StatefulWidget {
  final BleInterface bleDriver;
  final List<RobotProfile> targetRobots;


  const ScanScreen({super.key, required this.bleDriver, required this.targetRobots});

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
    _waitForBluetoothAndScan();
  }

  Future<void> _waitForBluetoothAndScan() async {
    // we need ot wait for the Bluetooth Adapter to turn 
    try {
      
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        await FlutterBluePlus.adapterState
            .firstWhere((state) => state == BluetoothAdapterState.on)
            .timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      // if BT connect takes too long just print error and return
      print("Error waiting for Bluetooth: $e");
      return;
    }

    // Now that it is ON we can safely scan with no issue
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);

    // preparing filters
    final Set<Guid> serviceUuids = widget.targetRobots
      .map((r)=> Guid(r.serviceUuid))
      .toSet();

    // creating a set of names for easier lookup
    final Set<String> targetNames = widget.targetRobots
      .map((r)=> r.name)
      .toSet();

    
    // now scanning for robotts
    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          
          // BUT we only keep the device if
          // 1. it has a name
          // 2. Its name matches one of the robots the user selected
          _scanResults = results.where((r) {
             final deviceName = r.device.platformName; // or r.advertisementData.localName
             print(deviceName);
             return deviceName.isNotEmpty && targetNames.contains(deviceName);
          }).toList();
        });
      }
    });

    // START SCANNING WITH FILTER
    try {
      await FlutterBluePlus.startScan(
        withServices: serviceUuids.toList(),
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

          if (!_isScanning && _scanResults.isEmpty)
             const Padding(
               padding: EdgeInsets.all(20.0),
               child: Text("No matching robots found.\nMake sure they are turned on!"),
             ),

          Expanded(
            child: ListView.builder(
              itemCount: _scanResults.length,
              itemBuilder: (context, index) {
                final result = _scanResults[index];
                final name = result.device.platformName;
                final id = result.device.remoteId.str;

                return ListTile(
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("ID: $id"),
                  

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