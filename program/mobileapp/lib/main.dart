import 'package:flutter/material.dart';
import './screen/home.dart';
import './screen/splash.dart';
import './screen/saved.dart';
import './screen/registration.dart';
import './screen/devices.dart';
import './widget/imucontainer.dart';

void main() {
  runApp(
    ImuContainer(
      child: MaterialApp(
        // Title
        title: "IMU Monitor App",
        theme: ThemeData(fontFamily: 'Roboto'),
        initialRoute: SplashScreen.id,
        routes: {
          SplashScreen.id: (context) => SplashScreen(),
          RegistrationScreen.id: (context) => RegistrationScreen(),
          HomeScreen.id: (context) => HomeScreen(),
          SavedScreen.id: (context) => SavedScreen(),
          DeviceScreen.id: (context) => DeviceScreen(),
        },
      ),
    ),
  );
}
