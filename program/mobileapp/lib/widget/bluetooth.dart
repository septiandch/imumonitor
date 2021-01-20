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

class BluetoothScreen extends StatefulWidget {
  static const String id = "bluetooth_screen";

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  BluetoothScreen({Key key}) : super(key: key);

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final _writeController = TextEditingController();
  List<BluetoothService> _services;
  List<DeviceSelection> deviceList = new List();
  DeviceSelection selectedDevice;
  BluetoothDevice _connectedDevice;
  bool _isDeviceSelected = false;

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);

        deviceList.add(
          DeviceSelection(
            device: device,
            title: (device.name == '') ? '(unknown device)' : device.name,
            isSelected: false,
            options: deviceList.length.toString(),
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
      itemCount: deviceList.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            for (int i = 0; i < deviceList.length; i++) {
              if (i == index) {
                setState(() {
                  deviceList[i].isSelected = true;
                });
              } else {
                setState(() {
                  deviceList[i].isSelected = false;
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
                      color: (deviceList[index].isSelected)
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
                        deviceList[index].title,
                        style: TextStyle(
                          color: (deviceList[index].isSelected)
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

  List<ButtonTheme> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = new List<ButtonTheme>();

    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              color: Colors.blue,
              child: Text('READ', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  setState(() {
                    widget.readValues[characteristic.uuid] = value;
                  });
                });
                await characteristic.read();
                sub.cancel();
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              child: Text('WRITE', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Write"),
                        content: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _writeController,
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Send"),
                            onPressed: () {
                              characteristic.write(
                                  utf8.encode(_writeController.value.text));
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              child: Text('NOTIFY', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                characteristic.value.listen((value) {
                  widget.readValues[characteristic.uuid] = value;
                });
                await characteristic.setNotifyValue(true);
              },
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  String _valuesToString(List<int> values) {
    //List<int> integer) {
    String str = "";

    if (values != null) {
      for (var i = 0; i < values.length; i++) {
        str = str + String.fromCharCode(values[i]);
      }
    }

    return str;
  }

  ListView _buildConnectDeviceView() {
    List<Container> containers = new List<Container>();

    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = new List<Widget>();

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(characteristic.uuid.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ..._buildReadWriteNotifyButton(characteristic),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Value: ' +
                          _valuesToString(
                              widget.readValues[characteristic.uuid]),
                    ),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
        );
      }
      containers.add(
        Container(
          child: ExpansionTile(
              title: Text(service.uuid.toString()),
              children: characteristicsWidget),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    } else {
      return _listViewOfDevices();
    }
  }

  void _connectToDevice() async {
    widget.flutterBlue.stopScan();

    for (DeviceSelection selectedDevice in deviceList) {
      if (selectedDevice.isSelected) {
        try {
          await selectedDevice.device.connect();
        } catch (e) {
          if (e.code != 'already_connected') {
            throw e;
          }
        } finally {
          _services = await selectedDevice.device.discoverServices();
        }
        setState(() {
          _connectedDevice = selectedDevice.device;
        });

        break;
      }
    }

    Navigator.pop(context, _connectedDevice);
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
