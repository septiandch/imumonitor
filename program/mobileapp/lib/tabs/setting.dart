import 'package:flutter/material.dart';
import 'package:imumonitor/widget/textbox.dart';
import 'package:imumonitor/config/colorscheme.dart';

class SettingTab extends StatefulWidget {
  @override
  _SettingTabState createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
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
              TextBox("Nama", "Ketik Nama anda"),
              TextBox("Umur", "Tahun"),
              TextBox("Tinggi Badan", "Cm"),
              TextBox("Berat Badan", "Kg"),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 55,
                width: MediaQuery.of(context).size.width * 0.8,
                child: RaisedButton(
                  onPressed: () {},
                  color: kButtonColor,
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      color: kTitleColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
