import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_layout.dart';
import 'package:robot_app/app-state2.dart';
import 'package:robot_app/app_state.dart';
import 'package:robot_app/pages/controls_classes/controls.dart';
import 'package:robot_app/pages/landing.dart';
import 'package:robot_app/pages/sensor.dart';
import 'package:robot_app/pages/setup.dart';
import 'package:robot_app/pages/video.dart';
import 'package:robot_app/services/ble_connection/ble_interface.dart';
import 'fake_ble_interface.dart';

void main() {
  final state = MyAppState1(FakeBleInterface()); 
  final mockBle = FakeBleInterface(); 
  final bluetoothState = AppState();

  testWidgets('Does the widget tab bar allow to switch from widget to widget properly',(WidgetTester tester)async{
   tester.view.physicalSize = const Size(1200, 800);
   tester.view.devicePixelRatio = 1.0;

   final Map<String, Type> navigationItems = {
      'Home': LandingPage,
      'Set-up Wizard': SetupWizardPage,
      'Robot Controls': RobotControlsPage,
      'Sensor Log': SensorLogPage,
      'Video Log': VideoLogPage,
    };
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider( // Use MultiProvider to provide BOTH the state and the interface
        providers: [
          Provider<BleInterface>.value(value: mockBle), 
          ChangeNotifierProvider<MyAppState1>.value(value: state),
          ChangeNotifierProvider<AppState>.value(value: bluetoothState),
          ],
          child: const Scaffold(
            body: AppLayout(), 
          ),   
        ), 
      ),
    );

    expect(find.byType(LandingPage), findsOneWidget, reason: 'Landing Widget did not appear');

    for (var entry in navigationItems.entries){
        String buttonName = entry.key;
        final Type widgetType = entry.value;

        final button = find.text(buttonName);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.byType(widgetType), findsOneWidget, reason: '$buttonName failed after timer elapsed');
    }
  });
 }
 

 