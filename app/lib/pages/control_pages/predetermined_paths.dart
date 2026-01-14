import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_states/main_app_state.dart';
import 'package:robot_app/ble_files/services/ble_connection/ble_interface.dart';

class PredeterminedPathsPage extends StatefulWidget {
  const PredeterminedPathsPage({super.key});
  //Establishes the timers that determine how long each path will take, these numbers are arbitrary
  static const int spiralTimer = 10*1000; 
  static const int randomTimer = 4*1000;
  static const int gridTimer = 3*1000;
  static const int lineTimer = 1*1000;

  @override
  State<PredeterminedPathsPage> createState() => _PredeterminedPathsPageState(); // enables the use of segmented button
}

class _PredeterminedPathsPageState extends State<PredeterminedPathsPage>{


  @override
  Widget build(BuildContext context){
    //Establishes the app states so that the app can communicate to robot and the logic rules are able to run
    final appState = Provider.of<MainAppState>(context, listen: true);
    final bleDriver = context.read<BleInterface>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //Creates the segmented button for each path
        SegmentedButton<Paths>(
            segments: const <ButtonSegment<Paths>>[ // main button
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
            //Write How the appstate should change and what bluetooth command should be sent depednding on the button selected
            onSelectionChanged: (Set<Paths> newSelection)async{
              if(appState.pathOngoing){
                ScaffoldMessenger.of(context).showSnackBar( // informs users if current path still ongoing and does not change selection
                  SnackBar(content:Text("Previous path ongoing, please wait"), duration: Duration(milliseconds:1200), behavior: SnackBarBehavior.floating,));
              }
              else{ // changes selection only if previous path not still ongoing
                  final selectedPath = newSelection.first;
                  int timeToUse;

                  switch (selectedPath) { // updates robot
                    case Paths.spiral: timeToUse = PredeterminedPathsPage.spiralTimer; 
                        ()async {
                          try {
                            await bleDriver.writeToCharacteristic('PS'.codeUnits);
                            debugPrint("'PS' Sent!");
                          } catch (e) {
                            debugPrint("PS");
                          }
                        }();  
                        break;
                    case Paths.grid:   timeToUse = PredeterminedPathsPage.gridTimer; 
                       ()async {
                          try {
                            await bleDriver.writeToCharacteristic('PG'.codeUnits);
                            debugPrint("'PG' Sent!");
                          } catch (e) {
                            debugPrint("PG");
                          }
                        }();
                        break;
                    case Paths.line:   timeToUse = PredeterminedPathsPage.lineTimer;
                       ()async {
                          try {
                            await bleDriver.writeToCharacteristic('PL'.codeUnits);
                            debugPrint("'PL' Sent!");
                          } catch (e) {
                            debugPrint("PL");
                          }
                        }();
                        break;
                    case Paths.random: timeToUse = PredeterminedPathsPage.randomTimer;
                        ()async {
                          try {
                            await bleDriver.writeToCharacteristic('PR'.codeUnits);
                            debugPrint("'PR' Sent!");
                          } catch (e) {
                            debugPrint("PR");
                          }
                        }(); 
                        break;         
                    default:  timeToUse = 0;
                  }
                  setState(() {
                    appState.path = selectedPath; // changes app state path
                  });
                appState.togglePath(timeToUse); // toggles delay for path
              }
            },),
        ],
    );
  }
}