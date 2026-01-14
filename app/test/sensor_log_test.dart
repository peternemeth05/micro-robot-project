import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_states/main_app_state.dart';
import 'package:robot_app/pages/control_pages/sensor_plots.dart';
import 'fake_ble_interface.dart'; 


void main() {
  testWidgets('SensorLogPage selection updates UI', (WidgetTester tester) async {
    final state = MainAppState(FakeBleInterface());

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<MainAppState>.value(
          value: state,
          child: const SensorLogPage(),
        ),
      ),
    );

    // Verify Initial Plot
    expect(find.text("Plot of voltage against time"), findsOneWidget);

    // Tap 'Frequency' button
    await tester.tap(find.text('Frequency'));
    await tester.pumpAndSettle();

    // Verify Updated Plot
    expect(find.text("Plot of frequency against time"), findsOneWidget);

    // Tap 'Velocity'
    await tester.tap(find.text('Velocity'));
    await tester.pumpAndSettle();
    expect(find.text("Plot of speed against time"), findsOneWidget);
  });
}