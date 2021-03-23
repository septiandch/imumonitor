import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import '../widget/imucontainer.dart';
import '../screen/saved.dart';
import '../screen/registration.dart';
import '../config/colorscheme.dart';

class SettingParam {
  final String name;
  final int initval;
  final int range;
  final int min;
  final int max;

  SettingParam(
    this.name,
    this.initval,
    this.range,
  )   : min = initval - range,
        max = initval + range;
}

List<SettingParam> settingList = [
  SettingParam("Back Bent", 30, 15),
  SettingParam("Back Twist", 30, 15),
  SettingParam("Shoulder Level", 90, 20),
  SettingParam("Sit Range", 90, 20),
  SettingParam("Standing Range", 0, 15),
  SettingParam("Squatting Range", 110, 30),
  SettingParam("Kneeling Range", 90, 30),
  SettingParam("Walking Range", 20, 15),
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
    int index = settingList.indexWhere((element) => element.name == title);

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
                    fontSize: 18.0,
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
                  initialValue: _currentValue[index],
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
                    () => _currentValue[index] = value,
                  ),
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
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: SizedBox(
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
          _currentValue = List<int>.generate(
              settingList.length, (index) => settingList[index].initval);
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

  void _settingModalBottomSheet(context, String title) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            height: 380,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
              ),
            ),
            width: MediaQuery.of(context).size.width * 0.75,
            padding: EdgeInsets.all(20),
            child: Text("Test"),
          );
        });
  }

  void _openBottomSheet() {
    _settingModalBottomSheet(context, "title");
  }

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
                for (SettingParam element in settingList)
                  _valuePicker(element.name, element.min, element.max, context),
              SizedBox(
                height: 10,
              ),
              // _button("Test", Icons.add, _openBottomSheet),
              _button("Simpan", Icons.save, _toSavedScreen),
              _button("Ganti User", Icons.person, _toRegistrationScreen),
            ],
          ),
        ),
      ),
    );
  }
}
