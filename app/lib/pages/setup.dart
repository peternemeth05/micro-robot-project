import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_state.dart';
import 'setup_robot.dart';
import 'setup_input.dart';

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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTab('Robot', 0),
              const SizedBox(width: 24),
              _buildTab('Input', 1),
            ],
          ),

          const Divider(height: 1),

          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: const [
                RobotPage(),
                InputPage(),
              ],
            ),
          ),

          const Divider(height: 1),

          _buildStatusPanel(),
        ],
      ),
    );
  }

  // Tabs
  Widget _buildTab(String text, int index) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
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

  // ----------- Status Dashboard --------------
  Widget _buildStatusIndicator(String label, bool isOn) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isOn ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPanel() {
    final appState = Provider.of<MyAppState>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Dashboard',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildStatusIndicator('Robot Connected', appState.isConnected),
          const SizedBox(height: 8),

          _buildStatusIndicator('Wifi Enabled', appState.enableWifi),
          const SizedBox(height: 8),

          _buildStatusIndicator(
            'Controller Connected',
            appState.physicalControllerEnabled,
          ),
          const SizedBox(height: 8),

          _buildStatusIndicator(
            'Virtual Controller Enabled',
            appState.virtualControllerEnabled,
          ),
        ],
      ),
    );
  }
}
