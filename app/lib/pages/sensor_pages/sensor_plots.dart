import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_states/main_app_state.dart';
import 'package:robot_app/pages/sensor_pages/widgets/misc_plot.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;


class SensorLogPage extends StatefulWidget {
  const SensorLogPage({super.key});

  @override
  State<SensorLogPage> createState() => _SensorLogPageState();
}


enum datas { data1, data2, data3, data4 }

class _SensorLogPageState extends State<SensorLogPage> {
  datas data = datas.data1;
  List<int> inputList = const [];
  String plotText = "";
  String xLabel = "";
  String yLabel = "";
  int interval = 200;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState1>(context, listen: true);
    
    switch (data) {
      case datas.data1:
        inputList = List.generate(3, (int index) => index * index, growable: true);
        plotText = "Plot of voltage against time";
        xLabel = "Time (ms)";
        yLabel = "Voltage (mV)";
        interval = 200;
      case datas.data2:
        inputList = List.generate(3, (int index) => index + index, growable: true);
        plotText = "Plot of frequency against time";
        xLabel = "Time (ms)";
        yLabel = "Frequency (Hz)";
        interval = 200;
      case datas.data3:
        inputList = List.generate(5, (int index) => index * 4, growable: true);
        plotText = "Plot of distance from surface against time";
        xLabel = "Time (ms)";
        yLabel = "Distance from nearest surface (cm)";
        interval = 200;
      case datas.data4:
        inputList = appState.speedhist.sublist(appState.speedhist.length-11,appState.speedhist.length-1);
        plotText = "Plot of speed against time";
        xLabel = "Time (AU)";
        yLabel = "Speed (AU)";
        interval = 1;
    }

    final bool compact = MediaQuery.of(context).size.width < 850;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(plotText),
            const SizedBox(height: 8),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GeneralPlot(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    vals: inputList,
                    xlabel: xLabel,
                    ylabel: yLabel,
                    timeint: interval,
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Material(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<datas>(
                    segments: <ButtonSegment<datas>>[
                      ButtonSegment(
                        value: datas.data1,
                        label: compact? Text("V"): Text("Voltage")),
                      ButtonSegment(
                        value: datas.data2,
                        label: compact? Text("Hz"): Text("Frequency")),
                      ButtonSegment(
                        value: datas.data3,
                        label: compact? Text("m"): Text("Ultrasound Distance")),
                      ButtonSegment(
                        value: datas.data4,
                        label: compact? Text("m/s"): Text("Velocity")),
                    ],
                    selected: <datas>{data},
                    onSelectionChanged: (newSelection) {
                      setState(() => data = newSelection.first);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 280,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.list),
                    label: const Text("View Logged Ultrasound Data"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoggedDataPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoggedDataPage extends StatelessWidget {
  const LoggedDataPage({super.key});

  // Escape a value for CSV (handles commas, quotes, newlines)
  String _csvEscape(String value) {
    final needsQuotes =
        value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r');
    if (!needsQuotes) return value;
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _buildSensorLogCsv() {
    final box = Hive.box<Map>('sensor_log');

    final rows = <List<String>>[
      ['timestamp', 'value'],
    ];

    for (int i = 0; i < box.length; i++) {
      final entry = box.getAt(i);
      if (entry == null) continue;

      final ts = entry['timestamp']?.toString() ?? '';
      final value = entry['value']?.toString() ?? '';
      rows.add([ts, value]);
    }

    return rows.map((r) => r.map(_csvEscape).join(',')).join('\n');
  }

  void _downloadCsvWeb() {
    final csv = _buildSensorLogCsv();
    final bytes = utf8.encode(csv);

    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'text/csv'),
    );

    final url = web.URL.createObjectURL(blob);

    final filename = 'sensor_log_${DateTime.now().millisecondsSinceEpoch}.csv';
    final a = web.HTMLAnchorElement()
      ..href = url
      ..download = filename;

    a.click();
    web.URL.revokeObjectURL(url);
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Map>('sensor_log');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Logged Sensor Data"),
        actions: [
          IconButton(
            tooltip: "Export CSV",
            icon: const Icon(Icons.download),
            onPressed: _downloadCsvWeb,
          ),
          IconButton(
            tooltip: "Clear log",
            icon: const Icon(Icons.delete),
            onPressed: () => box.clear(),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Map> b, _) {
          if (b.isEmpty) {
            return const Center(child: Text("No sensor data logged yet."));
          }

          return ListView.builder(
            itemCount: b.length,
            itemBuilder: (context, i) {
              final idx = b.length - 1 - i; // newest first
              final entry = (b.getAt(idx) as Map?) ?? {};

              final value = entry['value']?.toString() ?? '';
              final tsStr = entry['timestamp']?.toString() ?? '';

              DateTime? ts;
              try {
                ts = DateTime.parse(tsStr).toLocal();
              } catch (_) {}

              return ListTile(
                title: Text(value),
                subtitle: Text(ts != null ? ts.toString() : tsStr),
              );
            },
          );
        },
      ),
    );
  }
}