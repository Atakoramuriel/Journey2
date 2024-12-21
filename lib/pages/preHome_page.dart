import 'package:flutter/material.dart';
import 'package:journey2/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journey2/pages/AccountSetup.dart';
import 'package:journey2/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Prep Code
class User {
  String username;
  String profileImg;
  User({required this.username, required this.profileImg});
}

Future getUser(userKey) async {
  Map<String, dynamic>? user;
  final userPrefs = await SharedPreferences.getInstance();
  await FirebaseFirestore.instance
      .collection("Riders")
      .doc(userKey)
      .get()
      .then((doc) async {
    if (doc.exists) {
      // print("USER EXISTS");
      user = doc.data();
    } else {
      return null;
    }
  }).whenComplete(() {
    if (user != null) {
      print(" \n \n \n \n \n");
      print("USER DATA : " + user!.toString());
      userPrefs.setString("profileImg", user!['profileImg'].toString());
      userPrefs.setString("username", user!['userName'].toString());
      userPrefs.setStringList("UserData", ['profileImg', user.toString()]);
      print(" \n \n \n \n \n");
      print("USER PREF TEST ");
      print(userPrefs.getString("profileImg"));
    }
  });
  // print("UserVal" + user);
  return user;
}

class preHomePage extends StatefulWidget {
  const preHomePage({Key? key}) : super(key: key);

  @override
  _preHomePageState createState() => _preHomePageState();
}

// ignore: camel_case_types
class _preHomePageState extends State<preHomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUser(Auth().currentUser?.uid.toString()),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return const HomePage();
          } else {
            print("SNAPSHOT V");
            print(snapshot);
            return AccountSetup();
            // return TestMap();
          }
        });
  }
}
