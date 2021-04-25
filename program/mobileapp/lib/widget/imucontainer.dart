import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../tabs/setting.dart';
import '../widget/linechart.dart';

const List<String> owasTitle = ["Back", "Arms", "Legs", "Load"];
const List<String> imuTitle = ["Roll", "Pitch", "Yaw", "Battery"];

class User {
  String name;
  int age;
  int height;
  int weight;

  User({this.name, this.age, this.height, this.weight});
}

class ImuContainer extends StatefulWidget {
  final Widget child;
  final User user;
  final List<MultiSeriesData> imuDataBase;
  final List<int> owasDataBase;
  final List<int> settingValue;
  final List<String> currentData;

  ImuContainer({
    @required this.child,
    this.user,
    this.imuDataBase,
    this.owasDataBase,
    this.settingValue,
    this.currentData,
  });

  static _ImuContainerState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedStateContainer>()
        .data;
  }

  @override
  _ImuContainerState createState() => _ImuContainerState();
}

class _ImuContainerState extends State<ImuContainer> {
  User user = User();
  List<int> owasDataBase = List<int>();
  List<int> settingValue = List<int>.generate(
      settingList.length,
      (index) => (index == settingList.length - 1)
          ? settingList[index].initval
          : (settingList[index].max / 2).ceil());
  List<String> currentData = List<String>(8);

  List<MultiSeriesData> imuDataBase = List<MultiSeriesData>.generate(
    8,
    (index) => (index == 0)
        ? MultiSeriesData(
            <SeriesData>[
              SeriesData("Back", List<SingleData>()),
              SeriesData("Arms", List<SingleData>()),
              SeriesData("Legs", List<SingleData>()),
              SeriesData("Load", List<SingleData>()),
            ],
          )
        : MultiSeriesData(
            <SeriesData>[
              SeriesData("Roll", List<SingleData>()),
              SeriesData("Pitch", List<SingleData>()),
              SeriesData("Yaw", List<SingleData>()),
              SeriesData("Batt", List<SingleData>()),
            ],
          ),
  );

  @override
  void initState() {
    owasDataBase.add(0);

    super.initState();
  }

  clearData() {
    owasDataBase = List<int>();
    currentData = List<String>(8);
    imuDataBase = List<MultiSeriesData>.generate(
      8,
      (index) => (index == 0)
          ? MultiSeriesData(
              <SeriesData>[
                SeriesData("Back", List<SingleData>()),
                SeriesData("Arms", List<SingleData>()),
                SeriesData("Legs", List<SingleData>()),
                SeriesData("Load", List<SingleData>()),
              ],
            )
          : MultiSeriesData(
              <SeriesData>[
                SeriesData("Roll", List<SingleData>()),
                SeriesData("Pitch", List<SingleData>()),
                SeriesData("Yaw", List<SingleData>()),
                SeriesData("Batt", List<SingleData>()),
              ],
            ),
    );
  }

  updateUserData(User _user) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'user_data';

    setState(() {
      user = _user;
      prefs.setString(
        key,
        user.name +
            ',' +
            user.age.toString() +
            ',' +
            user.height.toString() +
            ',' +
            user.weight.toString(),
      );
    });
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'user_data';

    String value = prefs.getString(key) ?? '';

    if (value != '') {
      List<String> values = value.split(',');

      user = User(
        name: values[0],
        age: int.parse(values[1]),
        height: int.parse(values[2]),
        weight: int.parse(values[3]),
      );
    } else {
      user = User(
        name: '',
        age: 0,
        weight: 0,
        height: 0,
      );
    }
  }

  getSettingValue() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'current_setting';
    String value = prefs.getString(key) ?? '';

    //print('read: $value');

    if (value != '') {
      List<String> values =
          value.replaceAll('[', '').replaceAll(']', '').split(',');

      settingValue = List<int>.generate(
          values.length, (index) => int.parse(values[index]));
    }
  }

  updateSettingValue(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'current_setting';
    prefs.setString(key, text);

    debugPrint('saved $text');
  }

  void updateCurrentData(int index, String data) {
    currentData[index - 1] = data;
  }

  String getCurrentData(int index) {
    return currentData[index];
  }

  void updateSeriesData(int index, String time, List<int> value) {
    for (var i = 0; i < value.length; i++) {
      (i == 4)
          ? owasDataBase.add(value[i])
          : imuDataBase[index - 1]
              .multiSeriesData[i]
              .seriesData
              .add(SingleData(time, value[i].toDouble()));
    }

    debugPrint(
        index.toString() + " - " + time.toString() + " - " + value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class InheritedStateContainer extends InheritedWidget {
  final _ImuContainerState data;

  InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
