import 'package:flutter/material.dart';
import '../widget/linechart.dart';
import 'package:imumonitor/config/colorscheme.dart';

class RotationValue {
  final double roll;
  final double pitch;
  final double yaw;

  RotationValue(
    this.roll,
    this.pitch,
    this.yaw,
  );
}

class Monitor extends StatefulWidget {
  final String title;
  final MultiSeriesData data;

  Monitor(
    this.title,
    this.data,
  );

  @override
  _MonitorState createState() => _MonitorState();
}

class _MonitorState extends State<Monitor> {
  Widget _valueContainer(String title, double value, Color decorationColor) {
    return Container(
      width: 65.0,
      padding: EdgeInsets.fromLTRB(8, 1, 5, 1),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            //                    <--- bottom side
            color: decorationColor,
            width: 3.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: kTextColor,
                  fontSize: 9.0,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: kTextColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }

  void _settingModalBottomSheet(context, String title, MultiSeriesData value) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            height: 380,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
              ),
            ),
            width: MediaQuery.of(context).size.width * 0.75,
            padding: EdgeInsets.all(20),
            child: lineChart(
              title,
              value,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: EdgeInsets.only(bottom: 20.0),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0.5,
            blurRadius: 10,
            offset: Offset(0, 2), // changes position of shadow
          )
        ],
      ),
      child: GestureDetector(
        onTap: () {
          _settingModalBottomSheet(context, widget.title, widget.data);
        },
        child: Row(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (widget.title != "")
                  Container(
                    width: 90,
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: kTextColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _valueContainer(
                        "Roll",
                        widget.data.multiSeriesData[0].seriesData.last.value,
                        kSeriesColors[0],
                      ),
                      _valueContainer(
                        "Pitch",
                        widget.data.multiSeriesData[1].seriesData.last.value,
                        kSeriesColors[1],
                      ),
                      _valueContainer(
                        "Yaw",
                        widget.data.multiSeriesData[2].seriesData.last.value,
                        kSeriesColors[2],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*
class LineChart extends StatefulWidget {
  final String title;
  final MultiSeriesData chartData;

  LineChart(
    this.title,
    this.chartData,
  );

  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  @override
  Widget build(BuildContext context) {
    
  }
}
*/
