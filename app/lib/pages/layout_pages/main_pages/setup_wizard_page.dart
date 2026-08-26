import 'package:flutter/material.dart';
import '../../setup_pages/bluetooth_page.dart';
import '../../setup_pages/wifi_page.dart';

class SetupWizardPage extends StatefulWidget { // serves as robot set-up base - creates layout and links to relevant classes for content
  const SetupWizardPage({super.key});

  @override
  State<SetupWizardPage> createState() => _SetupWizardPageState(); // local state to swap tabs
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
                ],
              ),

              const Divider(height: 1),

              const Expanded(
                child: TabBarView(children: [BluetoothPage()]), // classes contain page content 
              ),
            ],
          ),
        ),
      ),
    );
  }
}