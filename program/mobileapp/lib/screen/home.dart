import 'package:flutter/material.dart';
import 'package:imumonitor/tabs/owas.dart';
import 'package:imumonitor/tabs/sensor.dart';
import 'package:imumonitor/tabs/setting.dart';
import 'package:imumonitor/config/colorscheme.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "home_screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<String> pageList = ["OWAS Level", "Sensor Monitor", "Setting"];
  TabController controller;
  String pageName;

  @override
  void initState() {
    super.initState();

    // Initialize the Tab Controller
    controller = TabController(length: 3, vsync: this);
    pageName = pageList[0];
    controller.addListener(_handleSelected);
  }

  void _handleSelected() {
    setState(() {
      pageName = pageList[controller.index];
    });
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar
      appBar: AppBar(
        // Title
        title: Text(
          pageName,
          style: TextStyle(
            color: kTitleColor,
          ),
        ),
        // Set the background color of the App Bar
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      // Set the TabBar view as the body of the Scaffold
      body: TabBarView(
        // Add tabs as widgets
        children: <Widget>[OwasTab(), SensorTab(), SettingTab()],
        // set the controller
        controller: controller,
      ),
      // Set the bottom navigation bar
      bottomNavigationBar: Material(
        //borderRadius: BorderRadius.only(
        //  topRight: Radius.circular(15),
        //  topLeft: Radius.circular(15),
        //),
        // set the color of the bottom navigation bar
        color: kPrimaryColor,
        // set the tab bar as the child of bottom navigation bar
        child: TabBar(
          indicatorColor: kTitleColor,
          labelColor: kTitleColor,
          tabs: <Tab>[
            Tab(
                // set icon to the tab
                icon: Icon(Icons.accessibility_new),
                text: pageList[0]),
            Tab(
              icon: Icon(Icons.screen_rotation),
              text: pageList[1],
            ),
            Tab(
              icon: Icon(Icons.settings),
              text: pageList[2],
            ),
          ],
          // setup the controller
          controller: controller,
        ),
      ),
    );
  }
}
