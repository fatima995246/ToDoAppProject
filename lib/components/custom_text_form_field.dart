import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef Validator = String? Function(String?);

class CustomTextFormField extends StatelessWidget {
  String lable;

  TextInputType keyboardTybe;

  bool isPassword;

  TextEditingController controller;

  Validator myValidator;

  CustomTextFormField(
      {required this.lable,
      this.keyboardTybe = TextInputType.text,
      this.isPassword = false,
      required this.controller,
      required this.myValidator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
            label: Text(lable),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColor, width: 4)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColor, width: 4))),
        keyboardType: keyboardTybe,
        obscureText: isPassword,
        controller: controller,
        validator: myValidator,
      ),
    );
  }
}
