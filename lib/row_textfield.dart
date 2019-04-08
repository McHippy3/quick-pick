import 'package:flutter/material.dart';

///Simple widget consisting of a row with a leading text and trailing textfield
class RowTextField extends StatelessWidget {
  final String frontText, prefill;
  final double widthTextField, fontSize, paddingValue;
  final TextEditingController controller;
  final onChange;
  final int maxLength;

  RowTextField(
      {this.frontText = '',
      this.widthTextField = 0.0,
      this.fontSize = 24.0,
      this.controller,
      this.paddingValue = 0,
      this.onChange,
      this.prefill = "",
      this.maxLength = 25});

  @override
  Widget build(BuildContext context) {
    TextField tf = TextField(controller: controller, maxLength: maxLength, onChanged: (val) => {onChange()});
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: paddingValue),
          child: Center(
            child: Text(
              frontText,
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: paddingValue * 2),
          width: widthTextField,
          child: tf,
        ),
      ],
    );
  }
}
