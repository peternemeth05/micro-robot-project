import 'package:flutter/material.dart';
import 'package:robot_app/pages/sensor_pages/misc_plot.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    switch (data) {
      case datas.data1:
        inputList = List.generate(3, (int index) => index * index, growable: true);
        plotText = "Plot of voltage against time";
        xLabel = "Time (ms)";
        yLabel = "Voltage (mV)";
      case datas.data2:
        inputList = List.generate(3, (int index) => index + index, growable: true);
        plotText = "Plot of frequency against time";
        xLabel = "Time (ms)";
        yLabel = "Frequency (Hz)";
      case datas.data3:
        inputList = List.generate(5, (int index) => index * 4, growable: true);
        plotText = "Plot of distance from surface against time";
        xLabel = "Time (ms)";
        yLabel = "Distance from nearest surface (cm)";
      case datas.data4:
        inputList = List.generate(4, (int index) => index * index * index, growable: true);
        plotText = "Plot of speed against time";
        xLabel = "Time (ms)";
        yLabel = "Velocity (m/s)";
    }

    final bool compact = MediaQuery.of(context).size.width < 600;

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
                        label: Text("Voltage")),
                      ButtonSegment(
                        value: datas.data2,
                        label: Text("Frequency")),
                      ButtonSegment(
                        value: datas.data3,
                        label: Text("Ultrasound Distance")),
                      ButtonSegment(
                        value: datas.data4,
                        label: Text("Velocity")),
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
                    label: const Text("View Logged Sensor Data"),
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

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Map>('sensor_log');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Logged Sensor Data"),
        actions: [
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
