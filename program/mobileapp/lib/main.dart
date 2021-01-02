import 'package:flutter/material.dart';
import 'package:imumonitor/screen/home.dart';
import 'package:imumonitor/screen/splash.dart';

void main() {
  runApp(
    MaterialApp(
      // Title
      title: "IMU Monitor App",
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        HomeScreen.id: (context) => HomeScreen(),
      },
    ),
  );
}
