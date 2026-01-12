import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_layout.dart';
import 'package:robot_app/app_state.dart';
import 'package:robot_app/pages/controls_classes/controls.dart';
import 'package:robot_app/pages/landing.dart';
import 'package:robot_app/pages/sensor.dart';
import 'package:robot_app/pages/setup_pages/input_page.dart';
import 'package:robot_app/pages/video.dart';

void main() {
  final state = AppState();

  testWidgets('Does the widget tab bar work properly',(WidgetTester tester)async{
   final Map<String, Type> navigationItems = {
      'Home': LandingPage,
      'Set-up Wizard': InputPage,
      'Robot Controls': RobotControlsPage,
      'Sensor Log': SensorLogPage,
      'Video Log': VideoLogPage,
    };
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: state,
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
   


