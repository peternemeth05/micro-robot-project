import 'package:flutter/material.dart';
import 'setup_pages/bluetooth_page.dart';
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Bluetooth'),
                  Tab(text: 'WiFi'),
                ],
              ),

              const Divider(height: 1),

              const Expanded(
                child: TabBarView(children: [BluetoothPage(), WifiPage()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}