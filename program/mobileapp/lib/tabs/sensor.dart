import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widget/linechart.dart';
import '../widget/monitoring.dart';
import '../widget/imucontainer.dart';

const List<String> sensorList = [
  "Lower Back",
  "Upper Right Hand",
  "Upper Left Hand",
  "Lower Right Hand",
  "Lower Left Hand",
  "Right Leg",
  "Left Leg",
];

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

  void _settingModalBottomSheet(
      context, String title, MultiSeriesData chartData) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.75,
            padding: EdgeInsets.all(20),
            child: lineChart(
              title,
              chartData,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final inheritContainer = ImuContainer.of(context);
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
                for (int i = 0; i < sensorList.length; i++)
                  Monitor(
                    sensorList[i],
                    imuData[i + 1],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
