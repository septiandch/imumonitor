import 'package:flutter/material.dart';
import '../widget/linechart.dart';

const List<String> owasTitle = ["Back", "Arms", "Legs", "Load"];
const List<String> imuTitle = ["Roll", "Pitch", "Yaw"];

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

  ImuContainer({
    @required this.child,
    this.user,
    this.imuDataBase,
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
  User user;

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
            ],
          ),
  );

  @override
  void initState() {
    super.initState();
  }

  void updateUser(User _user) {
    setState(() {
      user = _user;
    });
  }

  void updateSeriesData(int index, String time, List<double> value) {
    setState(() {
      for (var i = 0; i < value.length; i++) {
        imuDataBase[index - 1]
            .multiSeriesData[i]
            .seriesData
            .add(SingleData(time, value[i]));
      }
    });
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
