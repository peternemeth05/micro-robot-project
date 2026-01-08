import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:robot_app/app_state.dart';



class CustomJoystick extends StatelessWidget {
  const CustomJoystick({super.key});

  @override
  Widget build(BuildContext context){
    final appState = Provider.of<MyAppState1>(context, listen: true);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Joystick(
          mode: JoystickMode.all,
          listener: (details) {
            appState.updateJoystick(details.x, details.y);
          },       
          base: Container(
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: const [
                Align(alignment: Alignment.topCenter, child: Icon(Icons.arrow_drop_up, color: Colors.white)),
                Align(alignment: Alignment.bottomCenter, child: Icon(Icons.arrow_drop_down, color: Colors.white)),
                Align(alignment: Alignment.centerLeft, child: Icon(Icons.arrow_left, color: Colors.white)),
                Align(alignment: Alignment.centerRight, child: Icon(Icons.arrow_right, color: Colors.white)),
              ],
            ),
          ),
          stick: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
                shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(96, 65, 65, 65),
                  blurRadius: 2,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
