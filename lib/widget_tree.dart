import 'package:flutter/material.dart';
import 'package:journey2/auth.dart';
import 'package:journey2/pages/login_page.dart';
import 'package:journey2/pages/preHome_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const preHomePage();
          } else {
            return const LoginPage();
          }
        });
  }
}

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


// FirebaseAuth.instance
//   .authStateChanges()
//   .listen((User user) {
//     if (user == null) {
//       print('User is currently signed out!');
//     } else {
//       print('User is signed in!');
//     }
//   });