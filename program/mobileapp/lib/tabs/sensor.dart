import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:imumonitor/widget/linechart.dart';
import 'package:imumonitor/temp/data.dart';
import 'package:imumonitor/config/colorscheme.dart';

class SensorTab extends StatefulWidget {
  @override
  _SensorTabState createState() => _SensorTabState();
}

class _SensorTabState extends State<SensorTab> {
  String stime = DateFormat('kk:mm').format(DateTime.now()).toString();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                LineChart(
                  "Lower Back",
                  sensorData_1,
                ),
                LineChart(
                  "Upper Hand Right",
                  sensorData_2,
                ),
                LineChart(
                  "Upper Hand Left",
                  sensorData_3,
                ),
                LineChart(
                  "Lower Hand Right",
                  sensorData_4,
                ),
                LineChart(
                  "Lower Hand Left",
                  sensorData_5,
                ),
                LineChart(
                  "Leg Right",
                  sensorData_6,
                ),
                LineChart(
                  "Leg Left",
                  sensorData_7,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
