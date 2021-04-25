import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widget/linechart.dart';
import '../widget/imucontainer.dart';
import '../method/post.dart';
import '../config/colorscheme.dart';

class OwasTab extends StatefulWidget {
  @override
  _OwasTabState createState() => _OwasTabState();
}

class _OwasTabState extends State<OwasTab> {
  List<MultiSeriesData> _imuData;
  List<int> _owasData;
  List<String> _availableDate = List<String>();
  String _selectedDateTitle;
  int _selectedDateIndex;

  Widget _owasLevel(int value) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: kOwasColors[value],
      ),
      width: MediaQuery.of(context).size.width * 0.75,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(),
          Text(
            "OWAS\nCategory",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          SizedBox(),
          Container(
            height: 45,
            width: 3,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          SizedBox(),
          Text(
            '0' + value.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 45.0,
            ),
          ),
          SizedBox(),
        ],
      ),
    );
  }

  Widget _valueContainer(
      String title, List<SingleData> seriesData, Color decorationColor) {
    int value = (seriesData.isNotEmpty) ? seriesData.last.value.toInt() : 0;

    return Container(
      width: 50.0,
      padding: EdgeInsets.all(3),
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            //                    <--- bottom side
            color: decorationColor,
            width: 3.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kTextColor,
              fontSize: 9.0,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            value.toInt().toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kTextColor,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _changeDate(bool bNextPrev) async {
    ImuContainer.of(context).clearData();

    if (_availableDate.isNotEmpty) {
      List<String> _reverseDateList = List.from(_availableDate.reversed);

      if (!bNextPrev && _selectedDateIndex < _availableDate.length) {
        _selectedDateIndex++;
      } else if (bNextPrev && _selectedDateIndex > 0) {
        _selectedDateIndex--;
      }

      (_selectedDateIndex == 0)
          ? _selectedDateTitle = 'Hari ini'
          : _selectedDateTitle = _reverseDateList[_selectedDateIndex];

      await _getData(_reverseDateList[_selectedDateIndex]);
    }
  }

  _getData(String date) async {
    if (_availableDate.isNotEmpty) {
      PostController postController = PostController();
      List<PostForm> data = List<PostForm>();

      data = await postController.getData(date);

      if (data.isNotEmpty) {
        for (var i = 0; i < data.length; i++) {
          List<int> values =
              data[i].data.map((value) => int.parse(value)).toList();

          ImuContainer.of(context).updateSeriesData(
            1,
            data[i].time,
            <int>[
              values[0],
              values[1],
              values[2],
              values[3],
              values[4],
            ],
          );

          for (var j = 0; j < 7; j++) {
            ImuContainer.of(context).updateSeriesData(
              (j + 2),
              data[i].time,
              <int>[
                values[5 + (j * 3)],
                values[6 + (j * 3)],
                values[7 + (j * 3)],
                0,
              ],
            );
          }
        }
      } else {
        ImuContainer.of(context).updateSeriesData(
          1,
          "",
          <int>[
            0,
            0,
            0,
            0,
            0,
          ],
        );

        for (var j = 0; j < 7; j++) {
          ImuContainer.of(context).updateSeriesData(
            (j + 2),
            "",
            <int>[
              0,
              0,
              0,
              0,
            ],
          );
        }
      }

      setState(() {});
    }
  }

  _getAvailableDate() async {
    if (_availableDate.isEmpty) {
      PostController postController = PostController();
      String today = DateFormat('yyyy-M-d').format(DateTime.now());

      _availableDate = await postController.getAvailableDate();

      if (!_availableDate.contains(today)) {
        _availableDate.add(today);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _selectedDateIndex = 0;
    _selectedDateTitle = 'Hari ini';
  }

  @override
  Widget build(BuildContext context) {
    final inheritContainer = ImuContainer.of(context);
    _imuData = inheritContainer.imuDataBase;
    _owasData = inheritContainer.owasDataBase;

    _getAvailableDate();

    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          // center the children
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0.5,
                    blurRadius: 10,
                    offset: Offset(0, 1), // changes position of shadow
                  )
                ],
              ),
              child: Column(
                children: <Widget>[
                  _owasLevel(_owasData.last),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _valueContainer(
                          "Back",
                          _imuData[0].multiSeriesData[0].seriesData,
                          kSeriesColors[0],
                        ),
                        _valueContainer(
                          "Arms",
                          _imuData[0].multiSeriesData[1].seriesData,
                          kSeriesColors[1],
                        ),
                        _valueContainer(
                          "Legs",
                          _imuData[0].multiSeriesData[2].seriesData,
                          kSeriesColors[2],
                        ),
                        _valueContainer(
                          "Load",
                          _imuData[0].multiSeriesData[3].seriesData,
                          kSeriesColors[3],
                        ),
                      ],
                    ),
                  ),
                  LineChart.withHeight(
                    "",
                    _imuData[0],
                    MediaQuery.of(context).size.height * 0.30,
                  ),
                  // LineChart("", _imuData[0]),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.navigate_before,
                      color: kTextColor,
                    ),
                    iconSize: 50,
                    onPressed: () {
                      //_getData(false);
                      _changeDate(false);
                    },
                  ),
                  SizedBox(),
                  Text(
                    _selectedDateTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                    ),
                  ),
                  SizedBox(),
                  IconButton(
                    icon: Icon(
                      Icons.navigate_next,
                      color: kTextColor,
                    ),
                    iconSize: 50,
                    onPressed: () {
                      _changeDate(true);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
