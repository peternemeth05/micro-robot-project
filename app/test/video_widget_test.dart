import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';
import 'package:robot_app/pages/layout_pages/main_pages/video.dart';

void main() {
  group('VideoLogPage UI Tests', () {
    
    testWidgets('Verify all UI components appear', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: VideoLogPage()));
      expect(find.text("Robot MJPEG Recorder"), findsOneWidget, reason:'title');
      expect(find.byType(MJPEGStreamScreen), findsOneWidget);
      expect(find.byType(SegmentedButton<Video>), findsOneWidget, reason:'segmentedButton');
      expect(find.text("Start"), findsOneWidget, reason:'start button');
      expect(find.text("Stop"), findsOneWidget, reason:'stop button');
    });

    testWidgets('MJPEGStreamScreen is configured with correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: VideoLogPage()));
      final streamWidget = tester.widget<MJPEGStreamScreen>(find.byType(MJPEGStreamScreen));
      expect(streamWidget.streamUrl, "http://yasmines-iphone.local:8081/video");
      expect(streamWidget.width, 900.0);
      expect(streamWidget.height, 600.0);
      expect(streamWidget.fit, BoxFit.contain);
    });

    testWidgets('SegmentedButton initial selection is Video.stop', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: VideoLogPage()));

      final segmentedButton = tester.widget<SegmentedButton<Video>>(
        find.byType(SegmentedButton<Video>)
      );
      expect(segmentedButton.selected, contains(Video.stop), reason: 'stop not default');
      expect(segmentedButton.selected, isNot(contains(Video.start)));
    });
  });
}