import 'package:flutter/material.dart';
import 'package:imumonitor/config/colorscheme.dart';

typedef ListStrCallback = void Function(String, String);

const TextInputType numberInput =
    TextInputType.numberWithOptions(decimal: true, signed: false);
const TextInputType textInput = TextInputType.text;

class TextBox extends StatefulWidget {
  final String label;
  final String hint;
  final TextInputType type;
  final ListStrCallback func;

  TextBox(this.label, this.hint, this.type, this.func);

  @override
  _TextBoxState createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: kTextBoxColor,
        border: OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.grey, width: 0.0),
        ),
        labelText: widget.label,
        hintText: widget.hint,
      ),
      keyboardType: widget.type,
      maxLines: 1,
      onChanged: (text) {
        widget.func(widget.label, text);
      },
    );
  }
}
