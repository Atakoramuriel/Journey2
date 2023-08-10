import 'package:flutter/material.dart';

Widget _entryPostField(
  String title,
  TextEditingController controller,
) {
  return TextField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
          filled: true,
          fillColor: Color.fromARGB(3, 37, 32, 32),
          hintText: title,
          hintStyle: const TextStyle(color: Colors.white),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          )));
}
