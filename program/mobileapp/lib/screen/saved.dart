import 'dart:async';
import 'package:flutter/material.dart';
import '../config/colorscheme.dart';

class SavedScreen extends StatefulWidget {
  static const String id = "saved_screen";

  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  Timer _timer;

  _removeScreen() {
    return _timer = Timer(Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    _removeScreen();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Pengaturan\nTersimpan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTitleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 34.0,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Image(
                width: 300,
                image: AssetImage(
                  "assets/img/save.png",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
