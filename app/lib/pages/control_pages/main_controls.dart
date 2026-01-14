import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_states/main_app_state.dart';
import 'package:robot_app/pages/custom_widgets/custom_joystick.dart';
import 'package:robot_app/ble_files/services/ble_connection/ble_interface.dart';

class MainControlsPage extends StatefulWidget { // main page visible when controlling robot
  const MainControlsPage({super.key});

  @override
  State<MainControlsPage> createState() => _MainControlsPageState(); //  enables buttons for the page
}

class _MainControlsPageState extends State<MainControlsPage> {
  StreamSubscription? distanceSubscription;
  String speed = "N/A";

  @override
  void initState() {
    super.initState();
    setupDataListener();
  }

  void setupDataListener() { // listens to the robot via bluetooth for ultrasound sensor data
    final bleDriver = context.read<BleInterface>();
    final appState = context.read<MainAppState>();

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
    final appState1 = Provider.of<MainAppState>(context, listen: true);
    final bleDriver = context.read<BleInterface>();

    if (appState1.path!=Paths.manual){ // determines speed displayed (medium for auto, dependent on distance from joystick center for manual)
      if(appState1.pathOngoing==false){speed="N/A";} else{speed = "medium";}
    } else if(appState1.speed ==0){
      speed = "N/A";
    } else if (appState1.speed<4){
      speed = "low";
    } else if (appState1.speed<7){
      speed = "medium";
    } else{speed = "high";}
    
    return LayoutBuilder(
      builder: (context, constraints) { // constraints allow for responsive layout with fraction of page
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(children: [
                  SizedBox(height: constraints.maxHeight/4,width:constraints.maxWidth/3, // responsive from constraints
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Current Movement Type: "+appState1.path.name.toString()), // displays path control type
                    Text("Automatic Path Active: "+appState1.pathOngoing.toString() ) // shows if automatic path currently ongoing
                  ],
                )
                ),
                SizedBox(height: constraints.maxHeight/4,width:constraints.maxWidth/3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Distance to nearest surface: "+(appState1.distanceValue)+" cm") // reads from ultrasound sensor
                  ],
                )
                ),
                SizedBox(height: constraints.maxHeight/4,width:constraints.maxWidth/3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Current Speed: "+speed), // shows speed as low, medium, high
                    Text("Current Heading: "+appState1.heading), // shows heading from -180 to 180 (north is 90, east is 0, south -90, west +-180)
                  ],
                )
                ),
                ],),
                Column(children: [
                  SizedBox(height: constraints.maxHeight*3/4,width:constraints.maxWidth*2/3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomJoystick(), // puts in custom joystick
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
                      onPressed: () async { // attempts bluetooth communication
                        try {
                          await bleDriver.writeToCharacteristic('A'.codeUnits); // 'A' is configured in back-end to correspond to action
                          debugPrint("'A' Sent!");
                        } catch (e) {
                          debugPrint("$e");
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
                          debugPrint("'Z' Sent!");
                        } catch (e) {
                          debugPrint(" $e");
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
                          debugPrint("'D' Sent!");
                        } catch (e) {
                          debugPrint("$e");
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