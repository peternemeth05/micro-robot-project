import 'package:flutter/material.dart';
import 'package:robot_app/pages/sensor_pages/misc_plot.dart';

class SensorLogPage extends StatefulWidget {
  const SensorLogPage({super.key});

  @override
  State<SensorLogPage> createState() => _SensorLogPageState();
}

enum datas {data1, data2, data3, data4}

class _SensorLogPageState extends State<SensorLogPage> {
  datas data = datas.data1;
  List<int> inputList = List.empty();
  String plotText = "";
  String xLabel = "";
  String yLabel = "";

  @override
  Widget build(BuildContext context) {

    switch (data){
      case datas.data1:
        inputList = List.generate(3, (int index) => index * index, growable: true);
        plotText = "Plot of voltage against time";
        xLabel = "Time (s)";
        yLabel = "Voltage (mV)";
      case datas.data2:
        inputList = List.generate(3, (int index) => index + index, growable: true);
        plotText = "Plot of frequency against time";
        xLabel = "Time (s)";
        yLabel = "Frequency (Hz)";
      case datas.data3:
        inputList = List.generate(5, (int index) => index * 4, growable: true);
        plotText = "Plot of distance from surface against time";
        xLabel = "Time (s)";
        yLabel = "Distance from nearest surface (cm)";
      case datas.data4:
        inputList = List.generate(4, (int index) => index * index * index, growable: true);
        plotText = "Plot of speed against time";
        xLabel = "Time (s)";
        yLabel = "Velocity (m/s)";
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) { 
        return SizedBox(height: constraints.maxHeight,width:constraints.maxWidth, child:
          Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: 
              [Text(plotText),
              GeneralPlot(width: constraints.maxWidth*0.95, height: constraints.maxHeight/1.2, vals: inputList, xlabel: xLabel, ylabel: yLabel)
              ],
              ),
            bottomNavigationBar: BottomAppBar(
              height: 56,
              child: SegmentedButton<datas>(
                segments: const <ButtonSegment<datas>>[
                  ButtonSegment(
                    value: datas.data1,
                    label: Text("Data Set 1")),
                  ButtonSegment(
                    value: datas.data2,
                    label: Text("Data Set 2")),
                  ButtonSegment(
                    value: datas.data3,
                    label: Text("Data Set 3")),
                  ButtonSegment(
                    value: datas.data4,
                    label: Text("Data Set 4")),
                ], 
                selected: <datas>{data},
                onSelectionChanged: (Set<datas> newSelection){
                  setState(() {
                    data = newSelection.first;
                  });
                },),
            ),
          )
        );
       },
    );
  }
}
