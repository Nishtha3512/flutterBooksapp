import 'package:flutter/material.dart';

Widget textfrm({hint, controller, keyboadrdtype}) {
  return Container(
    //color: Colors.grey,
    decoration: BoxDecoration(
        //   color: Colors.grey,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.teal)),
    child: Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: TextFormField(
          keyboardType: keyboadrdtype,
          controller: controller,
          decoration: InputDecoration(
              hintText: hint,

              //  fillColor: Colors.green,
              //  labelText: labelText,
              // fillColor: Colors.green,
              focusColor: Colors.teal[200],
              border: InputBorder.none)),
    ),
  );
}
