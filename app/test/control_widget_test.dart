import 'package:flutter_test/flutter_test.dart';
import 'package:robot_app/app_states/main_app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/pages/control_pages/predetermined_paths.dart';
import 'package:robot_app/ble_files/services/ble_connection/ble_interface.dart';
import 'fake_ble_interface.dart';


void main() {
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
  for (var entry in pathLabels.asMap().entries){
     int i = entry.key;
     String pathName = entry.value;
     final button = find.text(pathName);

     await tester.tap(button);
     expect(state.pathOngoing, true, reason: '$pathName failed on start');
     await tester.pump(Duration(milliseconds: (timerValues[i])~/2));
     await tester.tap(button);
     await tester.pump(Duration(milliseconds: timerValues[i]~/2));
     expect(state.pathOngoing, false, reason: '$pathName failed after timer elapsed');
    
  }
 });

  testWidgets('Is the snackbar appearing in predetermined paths correctly', (WidgetTester test) async {
    final state = MainAppState(FakeBleInterface());
    final mockBle = FakeBleInterface(); 
    List<String> pathLabels = ['Spiral Path', 'Grid Path', 'Straight Line', 'Random Path'];
    
  
    await test.pumpWidget(MaterialApp(
            home: MultiProvider( // Use MultiProvider to provide BOTH the state and the interface
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
      expect(find.text('Previous path ongoing, please wait'), findsNothing, reason: ' $foundButton Before pressing the first button');
      await test.tap(foundButton);
      await test.pump();
      expect(find.text('Previous path ongoing, please wait'), findsNothing, reason: 'After pressing the first button');
      final foundNextButton = find.text(pathLabels[(i+1)% pathLabels.length]);
      await test.tap(foundNextButton);
      await test.pump();
      expect(find.text('Previous path ongoing, please wait'), findsOneWidget, reason: 'After pressing second button');
      await test.pumpAndSettle(const Duration(milliseconds: 11000));
      }
  });
   

   testWidgets('Is MyAppState updating correctly after the Buttons pressed', (WidgetTester tester) async {
    final state = MainAppState(FakeBleInterface());
    final mockBle = FakeBleInterface(); 
    List<String> pathLabels = ['Spiral Path', 'Grid Path', 'Straight Line', 'Random Path'];
    List<int> timerValues = [PredeterminedPathsPage.spiralTimer, PredeterminedPathsPage.gridTimer, PredeterminedPathsPage.lineTimer, PredeterminedPathsPage.randomTimer];
   
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider( // Use MultiProvider to provide BOTH the state and the interface
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
      await tester.tap(foundButton);
      await tester.pump();
      expect(state.pathOngoing, true, reason: '$pathName failed on start');
      await tester.pump(Duration(milliseconds: timerValues[i]-1));
      expect(state.pathOngoing, true, reason: '$pathName failed before finish');
      await tester.pump(Duration(milliseconds: 1));
      expect(state.pathOngoing, false, reason: '$pathName failed after finish');
    }
  });
}

