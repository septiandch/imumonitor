import 'package:flutter/material.dart';
import '../widget/linechart.dart';
import '../widget/owaslevel.dart';
import '../widget/imucontainer.dart';
import '../config/colorscheme.dart';

class OwasTab extends StatefulWidget {
  @override
  _OwasTabState createState() => _OwasTabState();
}

class _OwasTabState extends State<OwasTab> {
  User user;
  List<MultiSeriesData> imuData;

  @override
  Widget build(BuildContext context) {
    final inheritContainer = ImuContainer.of(context);
    user = inheritContainer.user;
    imuData = inheritContainer.imuDataBase;

    return Container(
      child: Center(
        child: Column(
          // center the children
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            OwasLevel(),
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
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 5), // changes position of shadow
                  )
                ],
              ),
              child: lineChart("", imuData[0]),
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
