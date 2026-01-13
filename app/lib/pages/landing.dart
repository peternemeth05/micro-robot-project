import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app-state2.dart';

<<<<<<< HEAD

=======
>>>>>>> origin/main
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState1>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Animal Inspired Movement and Robotics"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Wrapped text
            Row(
              children: const [
                Expanded(
                  child: Text(
                    "Welcome to Dr Jayaram’s Robotic Setup tool!\n"
                    "To get started, please press the setup wizard to configure "
                    "the micro-robots and control inputs.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            ElevatedButton(
              onPressed: () => appState.changeIndex(1),
              child: const Text("Set-Up Wizard"),
            ),

            //Wrapped RichText
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: const [
                        TextSpan(
                          text: "Guide on how to use the website:\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "The Setup Wizard will allow you to connect to the robots "
                              "and input controllers.\n"
                              "The Robot Controls Tab includes inbuilt walking patterns "
                              "and a virtual joystick to control the robot directly.\n"
                              "The Sensor Log will allow you to log real-time data from "
                              "the micro-robots.\n"
                              "The Video Log will allow you to visualise the real-time "
                              "recording from the robot’s camera.",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
