import 'package:flutter/material.dart';
import 'package:robot_app/pages/misc_plot.dart';

class SensorLogPage extends StatefulWidget {
  const SensorLogPage({super.key});

  @override
  State<SensorLogPage> createState() => _SensorLogPageState();
}

enum Datas {data1, data2, data3, data4}

class _SensorLogPageState extends State<SensorLogPage> {
  Datas data = Datas.data1;
  List<int> inputList = List.empty();
  String plotText = "";

  @override
  Widget build(BuildContext context) {

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
        plotText = "Plot of data set 4";
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) { 
        return SizedBox(height: constraints.maxHeight,width:constraints.maxWidth, child:
          Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: 
              [Text(plotText),
              GeneralPlot(width: constraints.maxWidth, height: constraints.maxHeight/1.2, vals: inputList)
              ],
              ),
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
            ),
          )
        );
       },
    );
  }
}
