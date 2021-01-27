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

MultiSeriesData dummyData = MultiSeriesData(<SeriesData>[
  SeriesData('Roll', <SingleData>[SingleData('', 0)]),
  SeriesData('Pitch', <SingleData>[SingleData('', 0)]),
  SeriesData('Yaw', <SingleData>[SingleData('', 0)]),
]);

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
    imuData = ImuContainer.of(context).imuDataBase;

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
                  (imuData[i + 1].multiSeriesData[0].seriesData.isNotEmpty)
                      ? Monitor(
                          sensorList[i],
                          imuData[i + 1],
                        )
                      : Monitor(
                          sensorList[i],
                          dummyData,
                        )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
