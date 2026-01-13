import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app-state2.dart';
import 'package:robot_app/app_state.dart';
import 'package:robot_app/pages/controls_classes.dart/custom_joystick.dart';
import 'package:robot_app/services/ble_connection/ble_interface.dart';

class GeneralInfoPage extends StatefulWidget {
  const GeneralInfoPage({super.key});

  @override
  State<GeneralInfoPage> createState() => _GeneralInfoPageState();
}

class _GeneralInfoPageState extends State<GeneralInfoPage> {
  StreamSubscription? distanceSubscription;

  @override
  void initState() {
    super.initState();
    setupDataListener();
  }

  void setupDataListener() {
    final bleDriver = context.read<BleInterface>();
    final appState = context.read<MyAppState1>();

    distanceSubscription = bleDriver.sensorDataStream.listen((receivedText) {
      debugPrint("Distance Data Received: $receivedText");

      try {
          
        if (receivedText.startsWith('DIST:')) {
        String distanceStr = receivedText.substring(5).trim();
        appState.updateDistance(distanceStr);
        debugPrint("Updated Distance: $distanceStr");
      } else if (receivedText.contains('Distance:')) {
        final match = RegExp(r'Distance:\s*(\d+)').firstMatch(receivedText);
        if (match != null) {
          String distanceStr = match.group(1)!;
          appState.updateDistance(distanceStr);
          debugPrint("Updated Distance: $distanceStr");
        }
      }
      } catch (e) {
        debugPrint("Error processing distance data: $e");
      }
      
    });
  }

  @override
  void dispose() {
    distanceSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState1 = Provider.of<MyAppState1>(context, listen: true);
    final bleDriver = context.read<BleInterface>();

    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(children: [
                  SizedBox(height: constraints.maxHeight/4,width:constraints.maxWidth/3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Current Movement Type: "+appState1.path.name.toString()),
                    Text("Current Joystick Position:  X:"+(appState1.x*10).toInt().toString()+"  Y:"+(appState1.y*10).toInt().toString())
                  ],
                )
                ),
                SizedBox(height: constraints.maxHeight/4,width:constraints.maxWidth/3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Distance to nearest surface: "+(appState.distanceValue)+" cm")
                  ],
                )
                ),
                SizedBox(height: constraints.maxHeight/4,width:constraints.maxWidth/3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Current Speed: "+appState1.speed.toString())
                  ],
                )
                ),
                ],),
                Column(children: [
                  SizedBox(height: constraints.maxHeight*3/4,width:constraints.maxWidth*2/3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomJoystick(),
                  ],
                )
                ),
                ],)
              ],
            ),
            Row(children: [
              SizedBox(height: constraints.maxHeight/4,width:constraints.maxWidth/3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await bleDriver.writeToCharacteristic('A'.codeUnits);
                          debugPrint("✅ 'A' Sent!");
                        } catch (e) {
                          debugPrint("❌ $e");
                        }
                        
                      },
                       child: Text("Begin Distance Recording"))
                  ],
                )
              ),
              SizedBox(height: constraints.maxHeight/4,width:constraints.maxWidth/3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await bleDriver.writeToCharacteristic('Z'.codeUnits);
                          debugPrint("✅ 'Z' Sent!");
                        } catch (e) {
                          debugPrint("❌ $e");
                        }
                      },
                       
                       child: Text("End Distance Recording"))
                  ],
                )
              ),
              SizedBox(height: constraints.maxHeight/4,width:constraints.maxWidth/3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await bleDriver.writeToCharacteristic('D'.codeUnits);
                          debugPrint("✅ 'D' Sent!");
                        } catch (e) {
                          debugPrint("❌ $e");
                        }
                      },
                      child: Text("Get Current Distance"))
                  ],
                )
              )
            ],)
          ],
        );
      },
    );
  }
}