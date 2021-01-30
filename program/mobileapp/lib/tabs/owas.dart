import 'package:flutter/material.dart';
import '../widget/linechart.dart';
import '../widget/imucontainer.dart';
import '../config/colorscheme.dart';

class OwasTab extends StatefulWidget {
  @override
  _OwasTabState createState() => _OwasTabState();
}

class _OwasTabState extends State<OwasTab> {
  User user;
  List<MultiSeriesData> imuData;
  List<int> owasData;

  Widget _owasLevel(int value) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: kOwasColors[value],
      ),
      width: MediaQuery.of(context).size.width * 0.75,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(),
          Text(
            "OWAS\nCategory",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          SizedBox(),
          Container(
            height: 45,
            width: 3,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          SizedBox(),
          Text(
            '0' + value.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 45.0,
            ),
          ),
          SizedBox(),
        ],
      ),
    );
  }

  Widget _valueContainer(
      String title, List<SingleData> seriesData, Color decorationColor) {
    int value = (seriesData.isNotEmpty) ? seriesData.last.value.toInt() : 0;

    return Container(
      width: 50.0,
      padding: EdgeInsets.all(3),
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            //                    <--- bottom side
            color: decorationColor,
            width: 3.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.center,
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
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kTextColor,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inheritContainer = ImuContainer.of(context);
    user = inheritContainer.user;
    imuData = inheritContainer.imuDataBase;
    owasData = inheritContainer.owasDataBase;

    return Container(
      child: Center(
        child: Column(
          // center the children
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0.5,
                    blurRadius: 10,
                    offset: Offset(0, 1), // changes position of shadow
                  )
                ],
              ),
              child: Column(
                children: <Widget>[
                  _owasLevel(owasData.last),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _valueContainer(
                          "Back",
                          imuData[0].multiSeriesData[0].seriesData,
                          kSeriesColors[0],
                        ),
                        _valueContainer(
                          "Arms",
                          imuData[0].multiSeriesData[1].seriesData,
                          kSeriesColors[1],
                        ),
                        _valueContainer(
                          "Legs",
                          imuData[0].multiSeriesData[2].seriesData,
                          kSeriesColors[2],
                        ),
                        _valueContainer(
                          "Load",
                          imuData[0].multiSeriesData[3].seriesData,
                          kSeriesColors[3],
                        ),
                      ],
                    ),
                  ),
                  lineChart("", imuData[0]),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(
                    Icons.navigate_before,
                    color: kTextColor,
                    size: 50,
                  ),
                  SizedBox(),
                  Text(
                    "Hari Ini",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                    ),
                  ),
                  SizedBox(),
                  Icon(
                    Icons.navigate_next,
                    color: kTextColor,
                    size: 50,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 55,
            ),
            /*
            SizedBox(
              height: 55,
              child: RaisedButton(
                onPressed: () {
                  /*
                  DateTime _now = DateTime.now();

                  inheritContainer.updateSeriesData(
                    1,
                    _now.hour.toString() +
                        ":" +
                        _now.minute.toString() +
                        ":" +
                        _now.second.toString(),
                    <double>[
                      Random().nextInt(360).toDouble(),
                      Random().nextInt(360).toDouble(),
                      Random().nextInt(360).toDouble(),
                      Random().nextInt(360).toDouble(),
                    ],
                  );

                  setState(() {});
                  */
                },
                color: kButtonColor,
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  "Submit",
                  style: TextStyle(
                    color: kTitleColor,
                  ),
                ),
              ),
            ),
            */
          ],
        ),
      ),
    );
  }
}
