import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
//import 'dart:math' as math;

//////////////////////////////////////// กราฟ /////////////////////////////
class Mylinecharts extends StatefulWidget {
  //Mylinecharts({Key? key, required this.title}) : super(key: key);
  int valueos = 0;

  Mylinecharts({required this.valueos});
  //final String title;

  @override
  _MyHomePagelinecharts createState() => _MyHomePagelinecharts();
}

class _MyHomePagelinecharts extends State<Mylinecharts> {
  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;

  @override
  void initState() {
    chartData = getChartData();
    Timer.periodic(const Duration(seconds: 1), updateDataSource);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SfCartesianChart(
            series: <LineSeries<LiveData, int>>[
              LineSeries<LiveData, int>(
                onRendererCreated: (ChartSeriesController controller) {
                  _chartSeriesController = controller;
                },
                dataSource: chartData,
                color: const Color.fromRGBO(192, 108, 132, 1),
                xValueMapper: (LiveData sales, _) => sales.time,
                yValueMapper: (LiveData sales, _) => sales.speed,
              )
            ],
            primaryXAxis: NumericAxis(
                majorGridLines: const MajorGridLines(width: 0),
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                interval: 3,
                title: AxisTitle(text: 'Time (seconds)')),
            primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                title: AxisTitle(text: 'OS%'))));
  }

  int time = 60;
  void updateDataSource(Timer timer) {
    chartData.add(LiveData(
        time++,
        widget.valueos)); // มาการสุ่มค่าให้กับ chart โดยใช้ function math.Random().nextInt(60) + 30
    chartData.removeAt(0);
    _chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
  }

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 0),
      LiveData(1, 0),
      LiveData(2, 0),
      LiveData(3, 0),
      LiveData(4, 0),
      LiveData(5, 0),
      LiveData(6, 0),
      LiveData(7, 0),
      LiveData(8, 0),
      LiveData(9, 0),
      LiveData(10, 0),
      LiveData(11, 0),
      LiveData(12, 0),
      LiveData(13, 0),
      LiveData(14, 0),
      LiveData(15, 0),
      LiveData(16, 0),
      LiveData(17, 0),
      LiveData(18, 0),
      LiveData(19, 0),
      LiveData(20, 0),
      LiveData(21, 0),
      LiveData(22, 0),
      LiveData(23, 0),
      LiveData(24, 0),
      LiveData(25, 0),
      LiveData(26, 0),
      LiveData(27, 0),
      LiveData(28, 0),
      LiveData(29, 0),
      LiveData(30, 0),
      LiveData(31, 0),
      LiveData(32, 0),
      LiveData(33, 0),
      LiveData(34, 0),
      LiveData(35, 0),
      LiveData(36, 0),
      LiveData(37, 0),
      LiveData(38, 0),
      LiveData(39, 0),
      LiveData(40, 0),
      LiveData(41, 0),
      LiveData(42, 0),
      LiveData(43, 0),
      LiveData(44, 0),
      LiveData(45, 0),
      LiveData(46, 0),
      LiveData(47, 0),
      LiveData(48, 0),
      LiveData(49, 0),
      LiveData(50, 0),
      LiveData(51, 0),
      LiveData(52, 0),
      LiveData(53, 0),
      LiveData(54, 0),
      LiveData(55, 0),
      LiveData(56, 0),
      LiveData(57, 0),
      LiveData(58, 0),
      LiveData(59, 0),
    ];
  }
}

class LiveData {
  LiveData(this.time, this.speed);
  final int time;
  final num speed;
}
