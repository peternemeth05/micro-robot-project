import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/pages/setup_pages/bluetooth_page.dart'; 
import 'package:robot_app/services/ble_connection/ble_interface.dart';


class MockBleInterface extends Mock implements BleInterface {}

void main() {
  late MockBleInterface mockBleInterface;//AI
  setUp(() {
    mockBleInterface = MockBleInterface();
    when(() => mockBleInterface.writeToCharacteristic(any()))
        .thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Provider<BleInterface>.value(
        value: mockBleInterface,
        child: const BluetoothPage(),
      ),
    );
  }

  group('Test Setup Input Widget', (){
    testWidgets('buttons and titles appear', (WidgetTester tester)async{
      expect(find.text('Select Target Robots'), findsOneWidget, reason: 'Target Robots button did not appear');
      expect(find.byType(CheckboxListTile), findsWidgets, reason: 'Robot list did not appear');
    });
  });
}