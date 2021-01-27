import 'package:flutter/material.dart';
import '../widget/textbox.dart';
import '../widget/imucontainer.dart';
import '../config/colorscheme.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = "registration_screen";

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  User _user;

  @override
  void initState() {
    _user = User(name: '', age: 0, weight: 0, height: 0);
    super.initState();
  }

  void submit(String label, String text) {
    // print(label + " : " + text);

    setState(() {
      switch (label) {
        case 'Nama':
          {
            _user.name = text;
          }
          break;
        case 'Umur':
          {
            (text == "") ? _user.age = 0 : _user.age = int.parse(text);
          }
          break;
        case 'Tinggi Badan':
          {
            (text == "") ? _user.height = 0 : _user.height = int.parse(text);
          }
          break;
        case 'Berat Badan':
          {
            (text == "") ? _user.weight = 0 : _user.weight = int.parse(text);
          }
          break;
        default:
          {
            print("Invalid submission : " + label);
          }
          break;
      }
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    _scaffoldState.currentState.showSnackBar(SnackBar(
      content: Text(
        text,
        style: TextStyle(fontSize: 20.0),
      ),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      body: SingleChildScrollView(
        child: SafeArea(
          minimum: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                // center the children
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "Masukkan\nData Diri Anda",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 28.0,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextBox("Nama", "Ketik Nama anda", textInput, submit),
                  SizedBox(
                    height: 30,
                  ),
                  TextBox("Umur", "Tahun", numberInput, submit),
                  SizedBox(
                    height: 30,
                  ),
                  TextBox("Tinggi Badan", "Cm", numberInput, submit),
                  SizedBox(
                    height: 30,
                  ),
                  TextBox("Berat Badan", "Kg", numberInput, submit),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: 55,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: RaisedButton(
                      onPressed: () {
                        if (_user.name.isEmpty ||
                            _user.age == 0 ||
                            _user.height == 0 ||
                            _user.weight == 0) {
                          _showSnackBar("Mohon lengkapi form...");
                        } else {
                          ImuContainer.of(context).updateUserData(_user);
                          Navigator.pop(context);
                        }
                      },
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
        ),
      ),
    );
  }
}
