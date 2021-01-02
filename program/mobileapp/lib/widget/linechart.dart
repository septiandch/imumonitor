import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:imumonitor/config/colorscheme.dart';

class SingleData {
  final String time;
  final double value;

  SingleData(this.time, this.value);
}

class SeriesData {
  List<SingleData> seriesData;
  final String seriesName;

  SeriesData(this.seriesName, this.seriesData);
}

class MultiSeriesData {
  List<SeriesData> multiSeriesData;

  MultiSeriesData(this.multiSeriesData);
}

class LineChart extends StatefulWidget {
  final String title;
  MultiSeriesData chartData;

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
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.title != "")
            Text(
              widget.title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          SizedBox(
            height: 15,
          ),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 5), // changes position of shadow
                )
              ],
            ),
            child: SfCartesianChart(
              tooltipBehavior: TooltipBehavior(
                enable: true,
              ),
              margin: EdgeInsets.all(20),
              // Initialize category axis
              primaryXAxis: CategoryAxis(
                //title: AxisTitle(text: "Time"),
                labelRotation: 90,
              ),
              primaryYAxis: NumericAxis(
                //title: AxisTitle(text: "Rotation Degree"),
                anchorRangeToVisiblePoints: false,
              ),
              series: <CartesianSeries>[
                for (var i = 0;
                    i < widget.chartData.multiSeriesData.length;
                    i++)
                  SplineSeries<SingleData, String>(
                    name: widget.chartData.multiSeriesData[i].seriesName,
                    // Bind data source
                    dataSource: widget.chartData.multiSeriesData[i].seriesData,
                    xValueMapper: (SingleData value, _) => value.time,
                    yValueMapper: (SingleData value, _) => value.value,
                    color: kSeriesColors[i],
                    enableTooltip: true,
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                for (var i = 0;
                    i < widget.chartData.multiSeriesData.length;
                    i++)
                  Row(
                    children: <Widget>[
                      Icon(Icons.stop, color: kSeriesColors[i]),
                      Text(
                        widget.chartData.multiSeriesData[i].seriesName,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: kTextColor,
                          fontSize: 15.0,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (widget.title != "")
            SizedBox(
              height: 40,
            ),
        ],
      ),
    );
  }
}
