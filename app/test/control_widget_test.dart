import 'package:flutter_test/flutter_test.dart';
import 'package:robot_app/app_states/main_app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/pages/control_pages/predetermined_paths.dart';
import 'package:robot_app/ble_files/services/ble_connection/ble_interface.dart';
import 'fake_ble_interface.dart';
import 'package:robot_app/pages/control_pages/general_info_page.dart';
import 'package:robot_app/pages/custom_widgets/custom_joystick.dart';

void main() {


   // Check JoyStick updates properly
  test('Is MyAppState updating correctly',(){
    final state = MainAppState(FakeBleInterface()); 

    for (double i=-10; i<10; i++){
    state.updateJoystick(i, i);
    expect(state.x, i);
    expect(state.y, i);
    }
  });

  testWidgets('Is the AppState preventing a timer reset in predetermined paths when a button is repeatedly pressed', (WidgetTester tester) async{
  final state = MainAppState(FakeBleInterface());
  final mockBle = FakeBleInterface(); 


  List<String> pathLabels = ['Spiral Path', 'Grid Path', 'Straight Line', 'Random Path'];
  List<int> timerValues = [PredeterminedPathsPage.spiralTimer, PredeterminedPathsPage.gridTimer, PredeterminedPathsPage.lineTimer, PredeterminedPathsPage.randomTimer];
 
  await tester.pumpWidget(MaterialApp(
        home: MultiProvider( 
        providers: [
          Provider<BleInterface>.value(value: mockBle), 
          ChangeNotifierProvider<MainAppState>.value(value: state),
        ],
          child: const Scaffold(
            body: PredeterminedPathsPage(), 
          ),
        ),
      ),
    );

  // For loop goes iterates through every button to make the timer doesn't reset on any of them
  for (var entry in pathLabels.asMap().entries){ 
     int i = entry.key;
     String pathName = entry.value;
     final button = find.text(pathName);


    //Taps button
     await tester.tap(button);
     //Tests whether button tap changed the state of the path
     expect(state.pathOngoing, true, reason: '$pathName failed on start');
     await tester.pump(Duration(milliseconds: (timerValues[i])~/2));
     //Taps button again
     await tester.tap(button);
     await tester.pump(Duration(milliseconds: timerValues[i]~/2));
     //checks that the second tap did not affect the timer
     expect(state.pathOngoing, false, reason: '$pathName failed after timer elapsed');
    
  }
 });

  testWidgets('Is the snackbar appearing in predetermined paths correctly', (WidgetTester test) async {
    final state = MainAppState(FakeBleInterface());
    final mockBle = FakeBleInterface(); 
    List<String> pathLabels = ['Spiral Path', 'Grid Path', 'Straight Line', 'Random Path'];
    
  
    await test.pumpWidget(MaterialApp(
            home: MultiProvider( 
            providers: [
              Provider<BleInterface>.value(value: mockBle), 
              ChangeNotifierProvider<MainAppState>.value(value: state),
            ],
          child: const Scaffold(
            body: PredeterminedPathsPage(), 
          ),
        ),
      ),
    );

    for (int i = 0; i < pathLabels.length; i++){
      final foundButton = find.text(pathLabels[i]);

      //Establishes whether snackbar initial appear
      expect(find.text('Previous path ongoing, please wait'), findsNothing, reason: ' $foundButton Before pressing the first button');
      await test.tap(foundButton);
      await test.pump();
      // Checks that snackbar does not appear after first tap
      expect(find.text('Previous path ongoing, please wait'), findsNothing, reason: 'After pressing the first button');
      final foundNextButton = find.text(pathLabels[(i+1)% pathLabels.length]);
      await test.tap(foundNextButton);
      await test.pump();
      // Checks that snackbar does appear after second tap
      expect(find.text('Previous path ongoing, please wait'), findsOneWidget, reason: 'After pressing second button');
      await test.pump(const Duration(milliseconds: 1200)); 
      await test.pump(const Duration(milliseconds: 200));
      // Checks that snackbar disappears after a set amount of time
      expect(find.text('Previous path ongoing, please wait'), findsNothing, reason: 'After snackbar timer');
      }
  });

   testWidgets('Is MyAppState updating correctly after the Buttons pressed', (WidgetTester tester) async {
    final state = MainAppState(FakeBleInterface());
    final mockBle = FakeBleInterface(); 
    List<String> pathLabels = ['Spiral Path', 'Grid Path', 'Straight Line', 'Random Path'];
    List<int> timerValues = [PredeterminedPathsPage.spiralTimer, PredeterminedPathsPage.gridTimer, PredeterminedPathsPage.lineTimer, PredeterminedPathsPage.randomTimer];
    List<List> bluetoothMessage = [[80, 83], [80, 71], [80, 76], [80, 82]];
   
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider( 
        providers: [
          Provider<BleInterface>.value(value: mockBle), 
          ChangeNotifierProvider<MainAppState>.value(value: state),
        ],
          child: const Scaffold(
            body: PredeterminedPathsPage(), 
          ),
        ),
      ),
    );
    
    for (var entry in pathLabels.asMap().entries){
      int i = entry.key;
      String pathName = entry.value;

      final foundButton = find.text(pathName);

      await tester.pumpAndSettle();
      //taps button
      await tester.tap(foundButton);
      await tester.pump();
      //tests whether appstate is updated after the button tap
      expect(state.pathOngoing, true, reason: '$pathName failed on start');
      await tester.pump(Duration(milliseconds: timerValues[i]-1));
      //test whether appstate is still set to true right before the path timer runs out
      expect(state.pathOngoing, true, reason: '$pathName failed before finish');
      //tests to see that button has sent the Bluetooth Data
      expect(mockBle.lastDataSent, equals(bluetoothMessage[i]), reason: 'The BLE driver did not receive the correct byte for T');
      await tester.pump(Duration(milliseconds: 1));
      //tests whether the appstate is set back to false after the timer elapsed
      expect(state.pathOngoing, false, reason: '$pathName failed after finish');
    }
  });
 
  testWidgets('Initial UI state displays default values from MainAppState and updates with Joystick Motion', (WidgetTester tester) async {
    final state = MainAppState(FakeBleInterface());
    final mockBle = FakeBleInterface();

    await tester.pumpWidget(MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<BleInterface>.value(value: mockBle),
          ChangeNotifierProvider<MainAppState>.value(value: state),
        ],
        child: const Scaffold(body: MainControlsPage()),
      ),
    ));

    //Verifies that the required widgets are present at
    expect(find.byType(CustomJoystick), findsOneWidget);
    expect(find.textContaining('Current Movement Type:'), findsOneWidget);
    //duration pumps deal with timer related to joystick package
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('Distance to nearest surface:'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text("Current Speed: N/A"), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    //inputs a distance into the sensor data
    mockBle.feedSensorData("DIST: 45");
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    //checks to see if the distance updates properly on the widget 
    expect(find.textContaining("45 cm"), findsOneWidget, reason: '45 cm not updating');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.runAsync(() => Future.delayed(Duration(milliseconds: 200)));
  });


  
}

