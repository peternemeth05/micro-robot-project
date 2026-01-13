import 'package:flutter_test/flutter_test.dart';
import 'package:robot_app/app-state2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/services/ble_connection/ble_interface.dart';
import 'fake_ble_interface.dart';
import 'package:robot_app/pages/landing.dart';
import 'package:robot_app/pages/setup.dart';



void main() { 
  testWidgets('Is the landing page appearing properly', (WidgetTester tester)async {
    final state = MyAppState1(FakeBleInterface());
    final mockBle = FakeBleInterface();
    final button = find.text('Set-Up Wizard');

    await tester.pumpWidget(MaterialApp(
          home: MultiProvider(
          providers: [
            ChangeNotifierProvider<MyAppState1>.value(value: state),
            Provider<BleInterface>.value(value: mockBle),
          ],
            child: const Scaffold(
            body: LandingPage(), 
          ),
        )
    )
    );

    expect(find.byType(LandingPage), findsOneWidget, reason: 'Landing Page did not load');
    expect(find.byType(ElevatedButton), findsOneWidget, reason: 'Could not find set up wizard button');
    await tester.tap(button);
    expect(find.byType(SetupWizardPage), findsOneWidget, reason: 'Input Page did not load after set wizard button was pressed');

   });
}


 