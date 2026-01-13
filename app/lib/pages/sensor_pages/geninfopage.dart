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
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState1>(context, listen: true);
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
                    Text("Current Movement Type: "+appState.path.name.toString()),
                    Text("Current Joystick Position:  X:"+(appState.x*10).toInt().toString()+"  Y:"+(appState.y*10).toInt().toString())
                  ],
                )
                ),
                SizedBox(height: constraints.maxHeight/4,width:constraints.maxWidth/3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Distance to nearest surface:")
                  ],
                )
                ),
                SizedBox(height: constraints.maxHeight/4,width:constraints.maxWidth/3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Current Speed: "+appState.speed.toString())
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