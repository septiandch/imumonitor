import 'package:flutter/material.dart';
import '../screen/saved.dart';
import '../widget/textbox.dart';
import '../config/colorscheme.dart';

class SettingTab extends StatefulWidget {
  @override
  _SettingTabState createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  final int oneInput = 1;
  final int twoInput = 2;

  void submit(String label, String text) {
    switch (label) {
      case "Min":
        break;
      case "Max":
        break;
      case "Minutes":
        break;
      default:
        print("Invalid submission : " + label);
        break;
    }
  }

  Widget inputField(String inputTitle, int fieldCount) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              width: 160,
              height: 50,
              child: Text(
                inputTitle,
                style: TextStyle(
                  color: kTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            if (fieldCount == 2) ...[
              Container(
                width: 60,
                height: 50,
                child: TextBox("Min", "", numberInput, submit),
              ),
              Container(
                width: 60,
                height: 50,
                child: TextBox("Max", "", numberInput, submit),
              ),
            ] else
              Container(
                width: 145,
                height: 50,
                child: TextBox("Minutes", "", numberInput, submit),
              ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget button(String title, IconData icon, VoidCallback func) {
    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width * 0.8,
      child: RaisedButton(
        onPressed: func,
        color: kButtonColor,
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

  void test1() {
    print("GANTI USER");
  }

  void toSavedScreen() {
    Navigator.of(context).pushNamed(SavedScreen.id);
  }

  @override
  Widget build(BuildContext context) {
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
              inputField("Back", twoInput),
              inputField("Upper Arms", twoInput),
              inputField("Lower Arms", twoInput),
              inputField("Right Legs", twoInput),
              inputField("Left Legs", twoInput),
              inputField("Update Interval", oneInput),
              SizedBox(
                height: 15,
              ),
              button("Simpan", Icons.save, toSavedScreen),
              SizedBox(
                height: 20,
              ),
              button("Ganti User", Icons.person, test1),
            ],
          ),
        ),
      ),
    );
  }
}
