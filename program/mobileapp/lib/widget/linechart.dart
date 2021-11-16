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
  final MultiSeriesData chartData;
  final double height;

  LineChart(this.title, this.chartData) : height = 250;

  LineChart.withHeight(this.title, this.chartData, this.height);

  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.title != "")
          Text(
            widget.title,
            style: TextStyle(
              color: kTextColor,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        SizedBox(
          height: 15,
        ),
        Container(
          height: widget.height,
          child: SfCartesianChart(
            tooltipBehavior: TooltipBehavior(
              enable: true,
            ),
            zoomPanBehavior: ZoomPanBehavior(
              // Enables pinch zooming
              enableDoubleTapZooming: true,
              zoomMode: ZoomMode.x,
              enablePinching: true,
              enablePanning: true,
            ),
            trackballBehavior: TrackballBehavior(
              // Enables the trackball
              enable: true,
              lineColor: Colors.blueGrey[100],
              tooltipSettings: InteractiveTooltip(
                enable: true,
                borderColor: Colors.blue[900],
                color: Colors.blue[300],
                textStyle: TextStyle(color: Colors.white),
              ),
            ),
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
              for (var i = 0; i < widget.chartData.multiSeriesData.length; i++)
                if (widget.chartData.multiSeriesData[i].seriesName != "Batt")
                  SplineSeries<SingleData, String>(
                    name: widget.chartData.multiSeriesData[i].seriesName,
                    // Bind data source
                    dataSource: widget.chartData.multiSeriesData[i].seriesData,
                    xValueMapper: (SingleData value, _) => value.time,
                    yValueMapper: (SingleData value, _) => value.value,
                    color: kSeriesColors[i],
                    /*
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [kSeriesColors[i], kSeriesColors2[i]],
                    ),
                    */
                  ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              for (var i = 0; i < widget.chartData.multiSeriesData.length; i++)
                if (widget.chartData.multiSeriesData[i].seriesName != "Batt")
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
      ],
    );
  }
}
