import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/pages/setup_pages/bluetooth_page.dart'; 
import 'package:robot_app/app_states/main_app_state.dart';
import 'package:robot_app/pages/setup_pages/wifi_page.dart';
import 'fake_ble_interface.dart';
import 'package:robot_app/app_states/ble_app_state.dart';
import 'package:robot_app/pages/layout_pages/main_pages/setup.dart';
import 'package:robot_app/ble_files/services/ble_connection/ble_interface.dart';

void main() {
    final state = MainAppState(FakeBleInterface());
    final mockBle = FakeBleInterface();
    final bluetoothState = AppState(); 
    final bluetoothButton = find.text('Bluetooth');
    final wifiButton = find.text('WiFi');
    final sendTButton= find.text("Test: Send 'T'");
    final firstCard = find.byType(Card).first;
  testWidgets('Check wether the Setup Wizard is appearing properly and wether the tabbar works', (WidgetTester tester) async{
    

    await tester.pumpWidget(MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<BleInterface>.value(value: mockBle), 
            ChangeNotifierProvider<MainAppState>.value(value: state),
            ChangeNotifierProvider<AppState>.value(value: bluetoothState),
            ],
          child: const Scaffold(
            body: SetupWizardPage()
          )
        ),
      )
    );

    //Verifies Widgets formed properly
    expect(find.byType(SetupWizardPage), findsOneWidget, reason: 'Setup Wizard Page not formed');
    expect(find.text('Bluetooth'), findsOneWidget, reason: 'Bluettoth button not formed');
    expect(find.text('WiFi'), findsOneWidget, reason: 'Wifi button not formed');
    expect(find.byType(BluetoothPage), findsOneWidget, reason: 'BluetoothPage is not visible on landing');
    expect(find.byType(WifiPage), findsNothing, reason: 'Wifi is visible on landing');
    await tester.tap(wifiButton);
    await tester.pumpAndSettle();
    expect(find.byType(WifiPage), findsOneWidget, reason: 'WifiPage is not visible after pressing the button');
    expect(find.byType(BluetoothPage), findsNothing, reason: 'BluetoothPage is visible after pressing Wifi button');
    await tester.tap(bluetoothButton);
    await tester.pumpAndSettle();
  });

  testWidgets('Check that the bluetooth Page is appearing, sending data and the card selection works properly', (WidgetTester tester) async{
    
    await tester.pumpWidget(MaterialApp(
          home: MultiProvider(
          providers: [
            Provider<BleInterface>.value(value: mockBle), 
            ChangeNotifierProvider<MainAppState>.value(value: state),
            ChangeNotifierProvider<AppState>.value(value: bluetoothState),
            ],
          child: const Scaffold(
            body: SetupWizardPage()
          )
        ),
     )
    );
    //Verifies All Widgets Expected appear
    expect(find.byType(BluetoothPage), findsOneWidget, reason: 'BluetoothPage did not build');
    expect(find.text("Test: Send 'T'"), findsOneWidget, reason: "can't find send t button");
    expect(find.byType(Card), findsAtLeastNWidgets(1), reason: 'No robot cards were rendered');
    //Taps send T bluetooth button
    await tester.tap(sendTButton);
    await tester.pumpAndSettle();
    //Checks that T is received by mock bluetooth interface
    expect(mockBle.lastDataSent, equals([84]), reason: 'The BLE driver did not receive the correct byte for T');

    //Checks that Cards respond to selectiion
    Card cardWidget = tester.widget<Card>(firstCard);
    expect(cardWidget.color, Color(0xFFE8E8E8), reason: 'Card should be grey initially');
    await tester.tap(find.descendant(of: firstCard, matching: find.byType(CheckboxListTile)));
    await tester.pumpAndSettle();
    cardWidget = tester.widget<Card>(firstCard);
    expect(cardWidget.color, Colors.red, reason: 'Card color should change to red when selected');
  });
}


