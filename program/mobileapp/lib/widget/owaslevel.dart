import 'package:flutter/material.dart';
import 'package:imumonitor/config/colorscheme.dart';

class OwasLevel extends StatefulWidget {
  @override
  _OwasLevelState createState() => _OwasLevelState();
}

class _OwasLevelState extends State<OwasLevel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Color(0xFF188CF6),
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
              color: kTitleColor,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          SizedBox(),
          Container(
            height: 45,
            width: 3,
            decoration: BoxDecoration(
              color: kTitleColor,
            ),
          ),
          SizedBox(),
          Text(
            "02",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kTitleColor,
              fontWeight: FontWeight.bold,
              fontSize: 45.0,
            ),
          ),
          SizedBox(),
        ],
      ),
    );
  }
}
