import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widget/linechart.dart';
import '../widget/imucontainer.dart';
import '../temp/data.dart';

class SensorTab extends StatefulWidget {
  @override
  _SensorTabState createState() => _SensorTabState();
}

class _SensorTabState extends State<SensorTab> {
  User user;
  List<MultiSeriesData> imuData;
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
    final inheritContainer = ImuContainer.of(context);
    user = inheritContainer.user;
    imuData = inheritContainer.imuDataBase;

    return Container(
      child: SingleChildScrollView(
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
                  imuData[1],
                ),
                LineChart(
                  "Upper Right Hand",
                  imuData[2],
                ),
                LineChart(
                  "Upper Left Hand",
                  imuData[3],
                ),
                LineChart(
                  "Lower Right Hand",
                  imuData[4],
                ),
                LineChart(
                  "Lower Left Hand",
                  imuData[5],
                ),
                LineChart(
                  "Right Leg",
                  imuData[6],
                ),
                LineChart(
                  "Left Leg",
                  imuData[7],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
