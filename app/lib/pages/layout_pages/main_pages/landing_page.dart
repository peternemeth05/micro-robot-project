import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_states/main_app_state.dart';

class LandingPage extends StatelessWidget { // this class is the main page that the user arrives on when opening the web app
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MainAppState>(context, listen: true);

    return Scaffold(
      appBar: AppBar( // provides a title
        title: const Text("Potentiostat Setup Page"),
      ),
      body: Padding( // contains main text and button
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Wrapped text
            Row(
              children: const [
                Expanded(
                  child: Text( // text is formatted for responsiveness
                    "Welcome to Zimmer Biomet's Potentiostat for Biomarker detection\n"
                    "To get started, please press the setup wizard to configure "
                    "the micro-robots and control inputs.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            ElevatedButton( // communicates with main_app_state to change index (go to set-up wizard)
              onPressed: () => appState.changeIndex(1),
              child: const Text("Set-Up Wizard"),
            ),

            //Wrapped RichText
            Row(
              children: [
                Expanded(
                  child: RichText( // use of rich text to change styling in one text block
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: const [
                        TextSpan(
                          text: "Guide on how to use the website:\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan( // also formatted for responsiveness
                          text:
                              "The Setup Wizard will allow you to connect to the Potentionstat "
                              "and input controllers.\n"
                              "The Potentiostat Controls Tab includes setting potentiostat"
                              "configuration, such as applied potential"
                              "alongside plotting of current sensor data. \n",
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
