import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:komuniti/constant/color.dart';

class AnimatedTextField extends StatefulWidget {
  final String labelText;
  final IconData iconData;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;

  const AnimatedTextField({
    Key? key,
    required this.labelText,
    required this.iconData,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  }) : super(key: key);

  @override
  _AnimatedTextFieldState createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    widget.controller.addListener(() {

    });
  }



  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: bgColor,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: _isFocused ? bgColor : Colors.black,
            width: 1.0,
          ),
        ),
        prefixIcon: Icon(
          widget.iconData,
          color: Colors.black,
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: 50.0,
        ),
      ),
      cursorColor: bgColor,
      style: TextStyle(fontSize: 18.0),
      validator: (value) {

      },// set the text input font size
    );
  }
}



