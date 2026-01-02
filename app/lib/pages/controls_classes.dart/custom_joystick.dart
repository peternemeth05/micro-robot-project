import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'JoystickState.dart';



class CustomJoystick extends StatelessWidget {
  const CustomJoystick({super.key});

  @override
  Widget build(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 600,  
          height: 400, 
          child: Card.outlined(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color.fromARGB(255, 69, 68, 68), width: 1),
              ),
            
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Joystick(
                    mode: JoystickMode.horizontalAndVertical,
                    listener: (details) {
                                context.read<JoystickState>().updateJoystick(details.x, details.y);
                              },       
                    base: Container(
                      width: 150,
                      height: 150,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 223, 167, 168),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        children: const [
                          Align(alignment: Alignment.topCenter, child: Icon(Icons.arrow_drop_up)),
                          Align(alignment: Alignment.bottomCenter, child: Icon(Icons.arrow_drop_down)),
                          Align(alignment: Alignment.centerLeft, child: Icon(Icons.arrow_left)),
                          Align(alignment: Alignment.centerRight, child: Icon(Icons.arrow_right)),
                        ],
                      ),
                    ),
                    stick: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 217, 217, 217),
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
              ),
          ),
        ),
      ],
    );
  }
}
