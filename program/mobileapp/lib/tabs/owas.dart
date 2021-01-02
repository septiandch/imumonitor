import 'package:flutter/material.dart';
import 'package:imumonitor/widget/linechart.dart';
import 'package:imumonitor/widget/owaslevel.dart';
import 'package:imumonitor/temp/data.dart';
import 'package:imumonitor/config/colorscheme.dart';

class OwasTab extends StatefulWidget {
  @override
  _OwasTabState createState() => _OwasTabState();
}

class _OwasTabState extends State<OwasTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBackgroundColor,
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
            LineChart(
              "",
              owasData,
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
          ],
        ),
      ),
    );
  }
}
