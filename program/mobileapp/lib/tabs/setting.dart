import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import '../widget/imucontainer.dart';
import '../screen/saved.dart';
import '../screen/registration.dart';
import '../config/colorscheme.dart';

const List<String> settingList = [
  "Back",
  "Upper Arms",
  "Lower Arms",
  "Upper Legs",
  "Lower Legs",
  "Update Interval",
];

class SettingTab extends StatefulWidget {
  final VoidCallback callBackFunc;

  SettingTab(this.callBackFunc);

  _SettingTabState createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  List<int> _currentValue = List<int>();

  @override
  void initState() {
    super.initState();
  }

  Widget _valuePicker(String title, int min, int max, BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        // _manualInputDialog(context, title);
      },
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                width: 160,
                height: 50,
                child: Text(
                  title,
                  style: TextStyle(
                    color: kTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.all(
                    const Radius.circular(5),
                  ),
                ),
                child: NumberPicker.horizontal(
                  initialValue: _currentValue[settingList.indexOf(title)],
                  minValue: min,
                  maxValue: max,
                  step: 1,
                  zeroPad: false,
                  selectedTextStyle: TextStyle(
                    color: kTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                  textStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12.0,
                  ),
                  onChanged: (value) => setState(
                      () => _currentValue[settingList.indexOf(title)] = value),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _button(String title, IconData icon, VoidCallback func) {
    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width * 0.8,
      child: RaisedButton(
        onPressed: func,
        color: kButtonColor,
        padding: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
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

  _loadSetting() {
    List<int> values = ImuContainer.of(context).settingValue;

    if (_currentValue.isEmpty) {
      setState(() {
        if (values.isNotEmpty)
          _currentValue = values;
        else
          _currentValue = List<int>.generate(settingList.length,
              (index) => (index == settingList.length - 1) ? 10 : 180);
      });
    }
  }

  void _toSavedScreen() async {
    ImuContainer.of(context).updateSettingValue(_currentValue.toString());
    await Navigator.of(context).pushNamed(SavedScreen.id);

    widget.callBackFunc();
  }

  void _toRegistrationScreen() async {
    await Navigator.of(context).pushNamed(RegistrationScreen.id);

    widget.callBackFunc();
  }

  /*
  _manualInputDialog(BuildContext context, String title) {
    TextEditingController controller = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Batas Sudut'),
            content: TextField(
              controller: controller,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(hintText: ""),
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text('OK'),
                onPressed: () {
                  setState(() {
                    _currentValue[settingList.indexOf(title)] =
                        int.parse(controller.text);
                  });

                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
  */

  @override
  Widget build(BuildContext context) {
    _loadSetting();

    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            // center the children
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              if (_currentValue.isNotEmpty)
                for (String element in settingList)
                  (settingList.indexOf(element) != settingList.length - 1)
                      ? _valuePicker(element, 0, 360, context)
                      : _valuePicker(element, 1, 60, context),
              SizedBox(
                height: 20,
              ),
              _button("Simpan", Icons.save, _toSavedScreen),
              SizedBox(
                height: 20,
              ),
              _button("Ganti User", Icons.person, _toRegistrationScreen),
            ],
          ),
        ),
      ),
    );
  }
}
