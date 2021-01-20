import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../config/colorscheme.dart';

class DeviceSelection {
  bool isSelected;
  String title;
  String options;
  BluetoothDevice device;
  List<BluetoothService> services;

  DeviceSelection({this.device, this.title, this.isSelected, this.options});
}

typedef ListIntCallback = void Function(List<int>);

Future deviceRead(BluetoothCharacteristic characteristic) async {
  if (characteristic.properties.read) {
    var sub = characteristic.value.listen((value) {
      if (value != null) {
        print(intToString(value));
      }
    });
    await characteristic.read();
    sub.cancel();
  }
}

void deviceListen(
    BluetoothCharacteristic characteristic, ListIntCallback func) async {
  if (characteristic.properties.notify) {
    characteristic.value.listen((value) {
      func(value);
    });
    await characteristic.setNotifyValue(true);
  }
}

void deviceWrite(BluetoothCharacteristic characteristic, String text) {
  if (characteristic.properties.write) {
    characteristic.write(utf8.encode(text));
  }
}

void disconnectFromDevice(BluetoothDevice device) {
  if (device != null) {
    device.disconnect();
  }
}

String intToString(List<int> values) {
  //List<int> integer) {
  String str = "";

  if (values != null) {
    for (var i = 0; i < values.length; i++) {
      str = str + String.fromCharCode(values[i]);
    }
  }

  return str;
}

class DeviceScreen extends StatefulWidget {
  static const String id = "bluetooth_screen";

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  DeviceScreen({Key key}) : super(key: key);

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<DeviceSelection> _deviceList = new List();
  DeviceSelection _selectedDevice;
  bool _isDeviceSelected = false;

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);

        _deviceList.add(
          DeviceSelection(
            device: device,
            title: (device.name == '') ? '(unknown device)' : device.name,
            isSelected: false,
            options: _deviceList.length.toString(),
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // do something...
  }

  ListView _listViewOfDevices() {
    return ListView.builder(
      itemCount: _deviceList.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            for (int i = 0; i < _deviceList.length; i++) {
              if (i == index) {
                setState(() {
                  _deviceList[i].isSelected = true;
                  _selectedDevice = _deviceList[i];
                });
              } else {
                setState(() {
                  _deviceList[i].isSelected = false;
                });
              }
            }
            _isDeviceSelected = true;
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: (_deviceList[index].isSelected)
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          //                    <--- bottom side
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        _deviceList[index].title,
                        style: TextStyle(
                          color: (_deviceList[index].isSelected)
                              ? kTextColor
                              : Colors.grey[400],
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _connectToDevice() async {
    widget.flutterBlue.stopScan();

    if (_selectedDevice.device != null) {
      try {
        await _selectedDevice.device.connect();
      } catch (e) {
        if (e.code != 'already_connected') {
          throw e;
        }
      } finally {
        _selectedDevice.services =
            await _selectedDevice.device.discoverServices();
      }
    }

    Navigator.pop(context, _selectedDevice);
  }

  Widget button(String title, IconData icon, VoidCallback func) {
    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width * 0.8,
      child: FlatButton(
        onPressed: func,
        color: (_isDeviceSelected) ? kButtonColor : Color(0x882195D7),
        padding: const EdgeInsets.all(18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: kTitleColor,
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              width: 120,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTitleColor,
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text("Test"),
        // ),
        // body: _buildListViewOfDevices(),
        body: SafeArea(
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Perangkat\nTerdeteksi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kTextColor,
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  height: 500,
                  //child: _buildView(),
                  child: _listViewOfDevices(),
                ),
                SizedBox(
                  height: 50,
                ),
                button("Sambungkan", Icons.bluetooth_audio, _connectToDevice),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        if (widget.flutterBlue.isScanning.isBroadcast) {
          widget.flutterBlue.stopScan();
        }

        return true;
      },
    );
  }
}
