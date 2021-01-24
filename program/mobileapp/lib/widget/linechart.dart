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

Widget lineChart(String title, MultiSeriesData chartData) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      if (title != "")
        Text(
          title,
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
        height: 250,
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
            for (var i = 0; i < chartData.multiSeriesData.length; i++)
              SplineSeries<SingleData, String>(
                name: chartData.multiSeriesData[i].seriesName,
                // Bind data source
                dataSource: chartData.multiSeriesData[i].seriesData,
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
            for (var i = 0; i < chartData.multiSeriesData.length; i++)
              Row(
                children: <Widget>[
                  Icon(Icons.stop, color: kSeriesColors[i]),
                  Text(
                    chartData.multiSeriesData[i].seriesName,
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
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      padding: EdgeInsets.all(20),
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
      child: Column(
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
            height: 250,
            child: SfCartesianChart(
              tooltipBehavior: TooltipBehavior(
                enable: true,
              ),
              zoomPanBehavior: ZoomPanBehavior(
                // Enables pinch zooming
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
                majorGridLines: MajorGridLines(width: 1),
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
        ],
      ),
    );
  }
}
*/
