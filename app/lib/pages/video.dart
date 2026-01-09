import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';


enum Video { start, stop, download }


class VideoLogPage extends StatefulWidget {
  const VideoLogPage({super.key});

  @override
  State<VideoLogPage> createState() => _VideoLogPageState();
}

class _VideoLogPageState extends State<VideoLogPage> {
  String? _recordedVideoPath;
  Video _currentStatus = Video.stop;

  void _startRecordingLogic() async {
    try {
      // Filename: 'robot_log'. Note: Chrome will prompt you to select the tab.
      bool started = await FlutterScreenRecording.startRecordScreen('robot_log');
      
      if (started) {
        setState(() => _currentStatus = Video.start);
        debugPrint("Recording Started - Select this tab in the Chrome popup!");
      }
    } catch (e) {
      debugPrint("Error starting recording: $e");
    }
  }

  void _stopRecordingLogic() async {
    try {
      String path = await FlutterScreenRecording.stopRecordScreen;
      setState(() {
        _recordedVideoPath = path;
        _currentStatus = Video.stop;
      });
      debugPrint("Recording Stopped. Path: $path");
    } catch (e) {
      debugPrint("Error stopping recording: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Robot MJPEG Recorder")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: MJPEGStreamScreen(
                streamUrl: "http://yasmines-iphone.local:8081/video",
                showLiveIcon: true,
                width: 900.0,
                height: 600.0,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<Video>(
              segments: const <ButtonSegment<Video>>[
                ButtonSegment(value: Video.start, icon: Icon(CupertinoIcons.play), label: Text("Start")),
                ButtonSegment(value: Video.stop, icon: Icon(CupertinoIcons.pause), label: Text("Stop")),
              ],
              selected: <Video>{_currentStatus},
              onSelectionChanged: (Set<Video> newSelection) {
                final selected = newSelection.first;
                if (selected == Video.start) _startRecordingLogic();
                if (selected == Video.stop) _stopRecordingLogic();
              },
            ),
          ),
        ],
      ),
    );
  }
}