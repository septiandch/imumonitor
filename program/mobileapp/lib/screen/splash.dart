import 'dart:async';
import 'package:flutter/material.dart';
import 'package:imumonitor/screen/home.dart';
import 'package:imumonitor/config/colorscheme.dart';

class SplashScreen extends StatefulWidget {
  static const String id = "splash_screen";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer _timer;

  removeScreen() {
    return _timer = Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed(HomeScreen.id);
    });
  }

  @override
  void initState() {
    super.initState();
    removeScreen();
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
        child: Image(
          width: 300,
          image: AssetImage(
            "assets/img/logo.png",
          ),
        ),
      ),
    );
  }
}
