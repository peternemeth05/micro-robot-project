import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app-state2.dart';
import 'package:robot_app/app_state.dart';


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
    //final driver = context.read<AppState>().driver;

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

<<<<<<< HEAD
<<<<<<< HEAD
            onSelectionChanged: (Set<paths> newSelection)async{
=======
            onSelectionChanged: (Set<Paths> newSelection){
>>>>>>> 4ceae73f (Added 2 unit tests: timer reset after multiple button presses & snackbar appearance)
=======
            onSelectionChanged: (Set<Paths> newSelection)async{
>>>>>>> 4200ab99 (added buttons for video and added bluetooth message on predetermined paths)
              if(appState.pathOngoing){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content:Text("Previous path ongoing, please wait"), duration: Duration(milliseconds:1200), behavior: SnackBarBehavior.floating,));
              }
              else{
                  final selectedPath = newSelection.first;
                  int timeToUse;
                  List<int> bluetoothCommand;

                  switch (selectedPath) {
<<<<<<< HEAD
<<<<<<< HEAD
                    case paths.spiral: timeToUse = PredeterminedPaths.spiralTimer;
                                       bluetoothCommand = [0x50, 0x53];
                                       break;
                    case paths.grid:   timeToUse = PredeterminedPaths.gridTimer; 
                                       bluetoothCommand = [0x50, 0x47];
                                       break;
                    case paths.line:   timeToUse = PredeterminedPaths.lineTimer;
                                       bluetoothCommand = [0x50, 0x4C]; 
                                       break;
                    case paths.random: timeToUse = PredeterminedPaths.randomTimer;
                                       bluetoothCommand = [0x50, 0x52]; 
                                       break;
=======
                    case Paths.spiral: timeToUse = PredeterminedPaths.spiralTimer; break;
                    case Paths.grid:   timeToUse = PredeterminedPaths.gridTimer; break;
                    case Paths.line:   timeToUse = PredeterminedPaths.lineTimer; break;
                    case Paths.random: timeToUse = PredeterminedPaths.randomTimer; break;
>>>>>>> 4ceae73f (Added 2 unit tests: timer reset after multiple button presses & snackbar appearance)
=======
                    case Paths.spiral: timeToUse = PredeterminedPaths.spiralTimer;
                                       bluetoothCommand = [0x50, 0x53];
                                       break;
                    case Paths.grid:   timeToUse = PredeterminedPaths.gridTimer; 
                                       bluetoothCommand = [0x50, 0x47];
                                       break;
                    case Paths.line:   timeToUse = PredeterminedPaths.lineTimer;
                                       bluetoothCommand = [0x50, 0x4C]; 
                                       break;
                    case Paths.random: timeToUse = PredeterminedPaths.randomTimer;
                                       bluetoothCommand = [0x50, 0x52]; 
                                       break;
>>>>>>> 4200ab99 (added buttons for video and added bluetooth message on predetermined paths)
                    default:           timeToUse = 0;
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