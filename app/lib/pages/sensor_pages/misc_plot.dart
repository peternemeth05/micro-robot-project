import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GeneralPlot extends StatelessWidget{
  final double height;
  final double width;
  final String ylabel;
  final String xlabel;
  final List vals;
  const GeneralPlot({Key? key, required this.width, required this.height, required this.vals, required this.ylabel, required this.xlabel}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: LineChart(LineChartData(
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(axisNameWidget: Text("")),
          rightTitles: AxisTitles(axisNameWidget: Text("")),
          bottomTitles: AxisTitles(axisNameWidget: Text(xlabel), sideTitles: SideTitles(showTitles: true), axisNameSize: 20.0),
          leftTitles: AxisTitles(axisNameWidget: Text(ylabel), sideTitles: SideTitles(showTitles: true), axisNameSize: 20.0)
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for(var (index, val) in vals.indexed)
                FlSpot(index.toDouble(), val.toDouble()),
            ],
            isCurved: true,
            barWidth: 4,
            color: Colors.red,
          ),
        ],
      )),
    );
  }
}