import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_state.dart';


class PrederterminedPaths extends StatefulWidget {
  const PrederterminedPaths({super.key});

  @override
  State<PrederterminedPaths> createState() => _PrederterminedPathsState();
}

class _PrederterminedPathsState extends State<PrederterminedPaths> {
  int timer = 0;

  int spiralTimer = 10*1000;
  int randomTimer = 4*1000;
  int gridTimer = 3*1000;
  int lineTimer = 2*1000;

  @override
  Widget build(BuildContext context){
    final appState = Provider.of<MyAppState1>(context, listen: true);

    switch(appState.path){
      case paths.spiral:
        timer = spiralTimer;
      case paths.random:
        timer = randomTimer;
      case paths.grid:
        timer = gridTimer;
      case paths.line:
        timer = lineTimer;
      case paths.manual:
        timer = 0;
    } 

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SegmentedButton<paths>(
            segments: const <ButtonSegment<paths>>[
              ButtonSegment(
                value: paths.spiral,
                icon: Icon(CupertinoIcons.arrow_2_squarepath),
                label: Text("Spiral Path")),
              ButtonSegment(
                value: paths.grid,
                icon: Icon(CupertinoIcons.arrow_swap),
                label: Text("Grid Path")),
              ButtonSegment(
                value: paths.line,
                icon: Icon(CupertinoIcons.arrow_up),
                label: Text("Straight Line")),
              ButtonSegment(
                value: paths.random,
                icon: Icon(CupertinoIcons.shuffle),
                label: Text("Random Path")),
            ], 
            selected: <paths>{appState.path},
            onSelectionChanged: (Set<paths> newSelection){
              if(appState.pathOngoing){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content:Text("Previous path ongoing, please wait"), duration: Duration(milliseconds:1200),behavior: SnackBarBehavior.floating,));
              }
              else{
                setState(() {
                  appState.path = newSelection.first;
                });
                appState.togglePath(timer);
              }
            },),
        ],
        );
  }
}