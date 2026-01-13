import 'package:flutter/material.dart';
import 'package:robot_app/pages/misc_plot.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SensorLogPage extends StatefulWidget {
  const SensorLogPage({super.key});

  @override
  State<SensorLogPage> createState() => _SensorLogPageState();
}

<<<<<<< HEAD
enum Datas {data1, data2, data3, data4}

class _SensorLogPageState extends State<SensorLogPage> {
  Datas data = Datas.data1;
  List<int> inputList = List.empty();
=======
enum datas { data1, data2, data3, data4 }

class _SensorLogPageState extends State<SensorLogPage> {
  datas data = datas.data1;
  List<int> inputList = const [];
>>>>>>> origin/main
  String plotText = "";

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD

    switch (data){
      case Datas.data1:
        inputList = List.generate(3, (int index) => index * index, growable: true);
        plotText = "Plot of data set 1";
      case Datas.data2:
        inputList = List.generate(3, (int index) => index + index, growable: true);
        plotText = "Plot of data set 2";
      case Datas.data3:
        inputList = List.generate(5, (int index) => index * 4, growable: true);
        plotText = "Plot of data set 3";
      case Datas.data4:
        inputList = List.generate(4, (int index) => index * index * index, growable: true);
=======
    switch (data) {
      case datas.data1:
        inputList = List.generate(3, (i) => i * i, growable: true);
        plotText = "Plot of data set 1";
        break;

      case datas.data2:
        inputList = List.generate(3, (i) => i + i, growable: true);
        plotText = "Plot of data set 2";
        break;

      case datas.data3:
        inputList = List.generate(5, (i) => i * 4, growable: true);
        plotText = "Plot of data set 3";
        break;

      case datas.data4:
        inputList = List.generate(4, (i) => i * i * i, growable: true);
>>>>>>> origin/main
        plotText = "Plot of data set 4";
        break;
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
                  );
                },
              ),
<<<<<<< HEAD
            bottomNavigationBar: BottomAppBar(
              height: 56,
              child: SegmentedButton<Datas>(
                segments: const <ButtonSegment<Datas>>[
                  ButtonSegment(
                    value: Datas.data1,
                    label: Text("Data Set 1")),
                  ButtonSegment(
                    value: Datas.data2,
                    label: Text("Data Set 2")),
                  ButtonSegment(
                    value: Datas.data3,
                    label: Text("Data Set 3")),
                  ButtonSegment(
                    value: Datas.data4,
                    label: Text("Data Set 4")),
                ], 
                selected: <Datas>{data},
                onSelectionChanged: (Set<Datas> newSelection){
                  setState(() {
                    data = newSelection.first;
                  });
                },),
=======
>>>>>>> origin/main
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
                        label: Text(compact ? "1" : "Data Set 1"),
                      ),
                      ButtonSegment(
                        value: datas.data2,
                        label: Text(compact ? "2" : "Data Set 2"),
                      ),
                      ButtonSegment(
                        value: datas.data3,
                        label: Text(compact ? "3" : "Data Set 3"),
                      ),
                      ButtonSegment(
                        value: datas.data4,
                        label: Text(compact ? "4" : "Data Set 4"),
                      ),
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
