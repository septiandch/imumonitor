import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'devices.dart';
import '../tabs/owas.dart';
import '../tabs/sensor.dart';
import '../tabs/setting.dart';
import '../widget/imucontainer.dart';
import '../method/post.dart';
import '../config/colorscheme.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "home_screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  final List<String> pageList = ["OWAS Level", "Sensor Monitor", "Setting"];

  DeviceSelection _selectedDevice;
  TabController _controller;
  String _pageName;
  bool _btState;
  bool _updateFlag;
  Timer _timer;
  DateTime _now;

  @override
  void initState() {
    super.initState();

    // Initialize the Tab Controller
    _controller = TabController(length: 3, vsync: this);
    _pageName = pageList[0];
    _controller.addListener(_handleSelected);
    _btState = false;
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _getDeviceData() {
    if (_selectedDevice != null) {
      for (BluetoothService service in _selectedDevice.services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid ==
              Guid('6E400003-B5A3-F393-E0A9-E50E24DCCA9E')) {
            deviceListen(characteristic, _deviceListen);
          }
        }
      }
    }
  }

  void _handleSelected() {
    setState(() {
      _pageName = pageList[_controller.index];
    });
  }

  _showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1),
    );
    _scaffoldState.currentState.showSnackBar(snackBar);
  }

  _submitData() async {
    _now = DateTime.now();
    PostForm postForm = PostForm(
      '${_now.year.toString()}-${_now.month.toString()}-${_now.day.toString()}',
      '${_now.hour.toString()}:${_now.minute.toString()}:${_now.second.toString()}',
      ImuContainer.of(context).user,
      ImuContainer.of(context).currentData,
    );

    PostController postController = PostController();

    _showSnackbar("Submitting Feedback");

    await postController.submitForm(postForm, (String response) {
      print("Response: $response");
      if (response == PostController.STATUS_SUCCESS) {
        // Feedback is saved succesfully in Google Sheets.
        _showSnackbar("Feedback Submitted");
      } else {
        // Error Occurred while saving data in Google Sheets.
        _showSnackbar("Error Occurred!");
      }
    });
  }

  void _deviceListen(List<int> rawValue) {
    _now = DateTime.now();
    List<String> value = intToString(rawValue).split(',');

    ImuContainer.of(context).updateCurrentData(
        int.parse(value[0]),
        (value[0] == '1')
            ? "${value[1]},${value[2]},${value[3]},${value[4]},${value[5]}"
            : "${value[1]},${value[2]},${value[3]}");

    setState(() {
      ImuContainer.of(context).updateSeriesData(
        int.parse(value[0]),
        _now.hour.toString() +
            ":" +
            _now.minute.toString() +
            ":" +
            _now.second.toString(),
        <int>[
          int.parse(value[1]),
          int.parse(value[2]),
          int.parse(value[3]),
          if (value[0] == '1') int.parse(value[4]),
          if (value[0] == '1') int.parse(value[5]),
        ],
      );
    });

    // do post request after data receiving is completed
    if (_updateFlag && (value[0] == '8')) {
      _submitData();

      _updateFlag = false;
    }

    // Wait for all data received
    if (ImuContainer.of(context)
        .currentData
        .every((element) => element != null)) {
      _updateFlag = true;
    }
  }

  IconData _bluetoothStatus(bool state) {
    if (state == true) {
      return Icons.bluetooth_connected;
    } else {
      return Icons.bluetooth_disabled;
    }
  }

  void _openConnection(BuildContext context) async {
    if (_selectedDevice == null) {
      _selectedDevice = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DeviceScreen()),
      );
    }

    _startConnection();
  }

  void _startConnection() async {
    if (_selectedDevice != null) {
      for (BluetoothService service in _selectedDevice.services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid ==
              Guid('6E400002-B5A3-F393-E0A9-E50E24DCCA9E')) {
            User user = ImuContainer.of(context).user;
            List<int> setting = ImuContainer.of(context).settingValue;

            await deviceWrite(
              characteristic,
              'user:' +
                  user.name +
                  ',' +
                  user.age.toString() +
                  ',' +
                  user.height.toString() +
                  ',' +
                  user.weight.toString(),
            );

            await deviceWrite(
              characteristic,
              'setting:' +
                  setting
                      .toString()
                      .replaceAll(' ', '')
                      .replaceAll('[', '')
                      .replaceAll(']', ''),
            );
          }
        }
      }

      _timer = Timer(Duration(seconds: 5), () {
        _getDeviceData();
      });

      setState(() {
        _updateFlag = false;
        _btState = true;
      });
    }
  }

  void _endConnection() {
    if (_timer != null) _timer.cancel();
    disconnectFromDevice(_selectedDevice.device);

    setState(() {
      _updateFlag = false;
      _btState = false;
      _selectedDevice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldState,
        backgroundColor: kBackgroundColor,
        // Appbar
        appBar: AppBar(
          // Title
          title: Text(
            _pageName,
            style: TextStyle(
              color: kTitleColor,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                _bluetoothStatus(_btState),
                color: (_btState) ? Colors.white : Color(0x55FFFFFF),
              ),
              onPressed: () {
                if (_btState) {
                  _endConnection();
                } else {
                  _openConnection(context);
                }
              },
            )
          ],
          // Set the background color of the App Bar
          backgroundColor: kPrimaryColor,
          elevation: 0,
        ),
        // Set the TabBar view as the body of the Scaffold
        body: TabBarView(
          // Add tabs as widgets
          children: <Widget>[
            OwasTab(),
            SensorTab(),
            SettingTab(_startConnection)
          ],
          // set the controller
          controller: _controller,
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
            controller: _controller,
          ),
        ),
      ),
      onWillPop: () async {
        _endConnection();

        return true;
      },
    );
  }
}
