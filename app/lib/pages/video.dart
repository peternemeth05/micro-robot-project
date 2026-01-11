import 'package:flutter/material.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';


class VideoLogPage extends StatelessWidget {
const VideoLogPage({super.key});

@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: MJPEGStreamScreen(
          streamUrl: "http://yasmines-iphone.local:8081/video",
          showLiveIcon: true,
          width: 900.0,
          height: 600.0,
          fit: BoxFit.cover,
        ),
      ),
    ),
   );
  }
}
