import 'package:flutter/material.dart';
import 'package:imumonitor/config/colorscheme.dart';

class TextBox extends StatefulWidget {
  final String label;
  final String hint;

  TextBox(this.label, this.hint);

  @override
  _TextBoxState createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> {
  String teks = "";

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(
            fillColor: kTextBoxColor,
            border: OutlineInputBorder(),
            labelText: widget.label,
            hintText: widget.hint,
          ),
          controller: controller,
          onSubmitted: (String str) {
            setState(() {
              teks = str + '\n' + teks;
              controller.text = "";
            });
          },
        ),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
