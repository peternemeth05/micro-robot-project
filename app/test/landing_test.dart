import 'package:flutter_test/flutter_test.dart';
import 'package:robot_app/app_states/main_app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/ble_files/services/ble_connection/ble_interface.dart';
import 'fake_ble_interface.dart';
import 'package:robot_app/pages/layout_pages/main_pages/landing.dart';
import 'package:robot_app/pages/layout_pages/main_pages/setup.dart';
import 'package:robot_app/app_states/ble_app_state.dart';

import 'package:robot_app/pages/layout_pages/app_layout.dart';


void main() { 
  testWidgets('Is the landing page appearing properly', (WidgetTester tester)async {
    final state = MainAppState(FakeBleInterface());
    final mockBle = FakeBleInterface();
    final button = find.text('Set-Up Wizard');
    final bluetoothState = AppState();

    await tester.pumpWidget(MaterialApp(
          home: MultiProvider(
          providers: [
          Provider<BleInterface>.value(value: mockBle), 
          ChangeNotifierProvider<MainAppState>.value(value: state),
          ChangeNotifierProvider<AppState>.value(value: bluetoothState),
          ],
            child: const Scaffold(
            body: AppLayout(), 
          ),
        )
    )
    );

    //Checks that the elements required are visible
    expect(find.byType(LandingPage), findsOneWidget, reason: 'Landing Page did not load');
    expect(find.byType(SetupWizardPage), findsNothing, reason: 'Input Page loaded before button pressed');
    expect(find.byType(ElevatedButton), findsOneWidget, reason: 'Could not find set up wizard button');
    //Presses the Setup Wizard button
    await tester.tap(button);
    await tester.pumpAndSettle();
    //Checks the setup wizard button brings you to the right place
    expect(find.byType(SetupWizardPage), findsOneWidget, reason: 'Input Page did not load after set wizard button was pressed');

   });
}


 