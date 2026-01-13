import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app-state2.dart';
import 'package:robot_app/services/ble_connection/ble_interface.dart';

class PredeterminedPaths extends StatefulWidget {
  const PredeterminedPaths({super.key});
  static const int spiralTimer = 10*1000;
  static const int randomTimer = 4*1000;
  static const int gridTimer = 3*1000;
  static const int lineTimer = 1*1000;

  @override
  State<PredeterminedPaths> createState() => _PredeterminedPathsState();
}

class _PredeterminedPathsState extends State<PredeterminedPaths>{


  @override
  Widget build(BuildContext context){
    final appState = Provider.of<MyAppState1>(context, listen: true);
    final bleDriver = context.read<BleInterface>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SegmentedButton<Paths>(
            segments: const <ButtonSegment<Paths>>[
              ButtonSegment(
                value: Paths.spiral,
                icon: Icon(CupertinoIcons.arrow_2_squarepath),
                label: Text("Spiral Path")),
              ButtonSegment(
                value: Paths.grid,
                icon: Icon(CupertinoIcons.arrow_swap),
                label: Text("Grid Path")),
              ButtonSegment(
                value: Paths.line,
                icon: Icon(CupertinoIcons.arrow_up),
                label: Text("Straight Line")),
              ButtonSegment(
                value: Paths.random,
                icon: Icon(CupertinoIcons.shuffle),
                label: Text("Random Path")),
            ], 

            selected: <Paths>{appState.path},

            onSelectionChanged: (Set<Paths> newSelection)async{
              if(appState.pathOngoing){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content:Text("Previous path ongoing, please wait"), duration: Duration(milliseconds:1200), behavior: SnackBarBehavior.floating,));
              }
              else{
                  final selectedPath = newSelection.first;
                  int timeToUse;

                  switch (selectedPath) {
                    case Paths.spiral: timeToUse = PredeterminedPaths.spiralTimer; 
                        ()async {
                          try {
                            await bleDriver.writeToCharacteristic('PS'.codeUnits);
                            debugPrint("✅ 'PS' Sent!");
                          } catch (e) {
                            debugPrint("❌ PS");
                          }
                        }();  
                        break;
                    case Paths.grid:   timeToUse = PredeterminedPaths.gridTimer; 
                       ()async {
                          try {
                            await bleDriver.writeToCharacteristic('PG'.codeUnits);
                            debugPrint("✅ 'PG' Sent!");
                          } catch (e) {
                            debugPrint("❌ PG");
                          }
                        }();
                        break;
                    case Paths.line:   timeToUse = PredeterminedPaths.lineTimer;
                       ()async {
                          try {
                            await bleDriver.writeToCharacteristic('PL'.codeUnits);
                            debugPrint("✅ 'PL' Sent!");
                          } catch (e) {
                            debugPrint("❌ PL");
                          }
                        }();
                        break;
                    case Paths.random: timeToUse = PredeterminedPaths.randomTimer;
                        ()async {
                          try {
                            await bleDriver.writeToCharacteristic('PR'.codeUnits);
                            debugPrint("✅ 'PR' Sent!");
                          } catch (e) {
                            debugPrint("❌ PR");
                          }
                        }(); 
                        break;         
                    default:  timeToUse = 0;
                  }
                  setState(() {
                    appState.path = selectedPath;
                  });
                appState.togglePath(timeToUse);
              }
            },),
        ],
    );
  }
}