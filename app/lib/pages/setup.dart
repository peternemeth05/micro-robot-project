import 'package:flutter/material.dart';
import 'setup_pages/bluetooth_page.dart';
import 'setup_pages/input_page.dart';
import 'setup_pages/wifi_page.dart';

class SetupWizardPage extends StatefulWidget {
  const SetupWizardPage({super.key});

  @override
  State<SetupWizardPage> createState() => _SetupWizardPageState();
}

class _SetupWizardPageState extends State<SetupWizardPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTab('Bluetooth', 0),
                _buildTab('WiFi', 1),
                //_buildTab('Input', 2),
              ],
            ),

            const Divider(height: 1),

            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: const [
                  BluetoothPage(),
                  WifiPage(),
                  InputPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }
}
