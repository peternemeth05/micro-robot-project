import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:robot_app/app_state.dart';

class LandingPage extends StatelessWidget {

  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    return Scaffold(
      appBar: AppBar(title: Text("Animal Inspired Movement and Robotics")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(children: [
            SizedBox(width:15),
            Text("Welcome to Dr Jayaram’s Robotic Setup tool! \nTo get started, please press the setup wizard to configure the micro-robots and control inputs.", style: TextStyle(fontWeight: FontWeight.bold)),
          ],),
        ElevatedButton(onPressed: ()=>appState.changeIndex(1),
          child: Text("Set-Up Wizard")),
        Row(children: [
          SizedBox(width:15),
          RichText(text: TextSpan(style:DefaultTextStyle.of(context).style,children: const <TextSpan>[
            TextSpan(text:"Guide on how to use the website:\n",style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text:"The Setup Wizard will allow you to connect to the robots and input controllers.\nThe Robot Controls Tab includes inbuilt walking patterns and a virtual joystick to control the robot directly.\nThe Sensor Log will allow you to log real-time data from the micro-robots.\nThe Video Log will allow you to visualise the real-time recording from the robot’s camera.")]))
          ],
        ),
      ],)
    );
  }
}
