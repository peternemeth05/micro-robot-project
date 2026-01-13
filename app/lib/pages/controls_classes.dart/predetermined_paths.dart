import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app-state2.dart';


class PrederterminedPaths extends StatefulWidget {
  const PrederterminedPaths({super.key});

  @override
  State<PrederterminedPaths> createState() => _PrederterminedPathsState();
}

class _PrederterminedPathsState extends State<PrederterminedPaths> {
  int timer = 0;

  final int spiralTimer = 10 * 1000;
  final int randomTimer = 4 * 1000;
  final int gridTimer = 3 * 1000;
  final int lineTimer = 2 * 1000;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState1>(context, listen: true);

    switch (appState.path) {
      case paths.spiral:
        timer = spiralTimer;
        break;
      case paths.random:
        timer = randomTimer;
        break;
      case paths.grid:
        timer = gridTimer;
        break;
      case paths.line:
        timer = lineTimer;
        break;
      case paths.manual:
        timer = 0;
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        //Collapses into just icon if window is too small
        final bool compact = constraints.maxWidth < 570;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SegmentedButton<paths>(
              segments: <ButtonSegment<paths>>[
                ButtonSegment(
                  value: paths.spiral,
                  icon: const Icon(CupertinoIcons.arrow_2_squarepath),
                  label: compact ? null : const Text("Spiral Path"),
                ),
                ButtonSegment(
                  value: paths.grid,
                  icon: const Icon(CupertinoIcons.arrow_swap),
                  label: compact ? null : const Text("Grid Path"),
                ),
                ButtonSegment(
                  value: paths.line,
                  icon: const Icon(CupertinoIcons.arrow_up),
                  label: compact ? null : const Text("Straight Line"),
                ),
                ButtonSegment(
                  value: paths.random,
                  icon: const Icon(CupertinoIcons.shuffle),
                  label: compact ? null : const Text("Random Path"),
                ),
              ],
              selected: <paths>{appState.path},
              onSelectionChanged: (Set<paths> newSelection) {
                if (appState.pathOngoing) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Previous path ongoing, please wait"),
                      duration: Duration(milliseconds: 1200),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  setState(() {
                    appState.path = newSelection.first;
                  });
                  appState.togglePath(timer);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
