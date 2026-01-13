import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/pages/layout_pages/app_layout.dart';
import 'package:robot_app/app_states/main_app_state.dart';
import 'package:robot_app/app_states/ble_app_state.dart';
import 'package:robot_app/pages/layout_pages/main_pages/landing.dart';
import 'package:robot_app/pages/control_pages/sensor_plots.dart';
import 'package:robot_app/pages/layout_pages/main_pages/robotinfo.dart';
import 'package:robot_app/pages/layout_pages/main_pages/setup.dart';
import 'package:robot_app/pages/layout_pages/main_pages/video.dart';
import 'package:robot_app/ble_files/services/ble_connection/ble_interface.dart';
import 'fake_ble_interface.dart';

void main() {
  final state = MainAppState(FakeBleInterface()); 
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
        home: MultiProvider( 
        providers: [
          Provider<BleInterface>.value(value: mockBle), 
          ChangeNotifierProvider<MainAppState>.value(value: state),
          ChangeNotifierProvider<AppState>.value(value: bluetoothState),
          ],
          child: const Scaffold(
            body: AppLayout(), 
          ),   
        ), 
      ),
    );

    expect(find.byType(LandingPage), findsOneWidget, reason: 'Landing Widget did not appear');

    // for loop interates between each button in the side tab bar to make sure the correct widget appears upon selection
    for (var entry in navigationItems.entries){
        String buttonName = entry.key;
        final Type widgetType = entry.value;

        final button = find.text(buttonName);
        await tester.tap(button);
        await tester.pump();
        expect(find.byType(widgetType), findsOneWidget, reason: '$buttonName failed after timer elapsed');
    }
  });
 }
 

 