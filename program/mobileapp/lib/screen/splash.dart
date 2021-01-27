import 'dart:async';
import 'package:flutter/material.dart';
import '../widget/imucontainer.dart';
import '../screen/registration.dart';
import '../screen/home.dart';
import '../config/colorscheme.dart';

class SplashScreen extends StatefulWidget {
  static const String id = "splash_screen";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer _timer;

  removeScreen(BuildContext context) async {
    return _timer = Timer(Duration(seconds: 2), () async {
      if (ImuContainer.of(context).user.name == '')
        await Navigator.of(context).pushNamed(RegistrationScreen.id);

      Navigator.of(context).pushReplacementNamed(HomeScreen.id);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImuContainer.of(context).getUserData();
    ImuContainer.of(context).getSettingValue();

    removeScreen(context);

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
