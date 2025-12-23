import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_state.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  String? selectedInput;

  final List<String> inputOptions = [
    "Virtual Controller",
    "Physical Controller",
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: false);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Input Type:",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),

            DropdownButton<String>(
              isExpanded: true,
              hint: const Text("Choose"),
              value: selectedInput,
              items: inputOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedInput = value;
                });

                // Update AppState
                if (value == "Virtual Controller") {
                  appState.setVirtualController(true);
                  appState.setPhysicalController(false);
                } else if (value == "Physical Controller") {
                  appState.setVirtualController(false);
                  appState.setPhysicalController(true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
