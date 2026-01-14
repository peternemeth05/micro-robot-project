import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GeneralPlot extends StatelessWidget { // uses fl_chart package to plot data
  final double height;
  final double width;
  final int timeint;
  final String ylabel;
  final String xlabel;
  final List<num> vals;

  const GeneralPlot({ // required inputs to call the class
    Key? key,
    required this.width,
    required this.height,
    required this.vals,
    required this.ylabel,
    required this.xlabel,
    required this.timeint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (vals.isEmpty) { // ensures chart won't try to form with no data
      return SizedBox(
        width: width,
        height: height,
        child: const Center(child: Text('No data')),
      );
    }else{

    final spots = <FlSpot>[ // configures data points
      for (int i = 0; i < vals.length; i++)
        FlSpot(i * timeint.toDouble(), vals[i].toDouble()),
    ];

    // creates limits for x axis
    double minX = spots.first.x;
    double maxX = spots.last.x;
    if (minX == maxX) { 
      minX -= timeint;
      maxX += timeint;
    }

    // creates limits for y axis
    double minY = spots.first.y;
    double maxY = spots.first.y;
    for (final s in spots) {
      minY = min(minY, s.y);
      maxY = max(maxY, s.y);
    }

    // Add padding so points never touch edges
    final yPadding = (maxY - minY) == 0 ? 1.0 : (maxY - minY) * 0.15;
    minY -= yPadding;
    maxY += yPadding;

    return SizedBox( // sized box required for chart to compile
      width: width,
      height: height,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,

          // Prevent curves from escaping the chart
          clipData: const FlClipData.all(),

          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),

          titlesData: FlTitlesData( // configures axes ticks visibility and title
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              axisNameWidget: Text(xlabel),
              axisNameSize: 28,
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxX - minX) / 4,
                reservedSize: 32,
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text(ylabel),
              axisNameSize: 28,
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxY - minY) / 4,
                reservedSize: 40,
              ),
            ),
          ),

          lineBarsData: [ // plots the data
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Colors.red,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }}
}
