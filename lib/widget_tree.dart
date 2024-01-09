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




// FirebaseAuth.instance
//   .authStateChanges()
//   .listen((User user) {
//     if (user == null) {
//       print('User is currently signed out!');
//     } else {
//       print('User is signed in!');
//     }
//   });