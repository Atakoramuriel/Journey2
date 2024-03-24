import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:journey2/constants.dart';
import 'package:journey2/pages/NotificationMenu.dart';
import 'package:journey2/pages/accountMenu.dart';
import 'package:journey2/pages/editProfile.dart';
import 'package:journey2/pages/helpMenu.dart';
import 'package:journey2/pages/privacyMenu.dart';
import 'package:journey2/pages/profile_menu.dart';
import 'package:journey2/screens/edit_screen.dart';
import 'package:journey2/widgets/forward_button.dart';
import 'package:journey2/widgets/setting_item.dart';
import 'package:journey2/widgets/setting_switch.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late String tempImage;
  late String username;
  late String profileImg;
  File _profileImg = new File(
      "https://firebasestorage.googleapis.com/v0/b/obsidianrune-vuejs.appspot.com/o/N4Posts%2FItVzlZqqYXQukCYVI3TZodI7oQq2%2Fimages%2FB1BF8558-3D05-46E1-830B-627CD82B5A78.jpeg?alt=media&token=a286c12d-5f26-4f71-a720-c83f3a55ad40");
  // final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username")!;
      profileImg = prefs.getString("profileImg")!;
    });
  }

  Future _getImage() async {
    // var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    //Set State
    setState(() {
      // _profileImg = image;
      // print('_profileImg: $_profileImg');
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      color: kBackgroundColor,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.01),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Spacer(),
                      GestureDetector(
                          onTap: _getImage,
                          child: _profileImg == null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(profileImg),
                                  radius: 50,
                                )
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(profileImg),
                                  radius: 50,
                                )),
                      Spacer()
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: <Widget>[
                      Spacer(),
                      Text(
                        username,
                        style: TextStyle(
                            color: const Color.fromARGB(255, 255, 252, 247),
                            decoration: TextDecoration.none,
                            fontSize: 20),
                      ),
                      Spacer()
                    ],
                  ),
                  SizedBox(height: 15),
                  Container(
                    //padding: EdgeInsets.only(top: size.height * 0.002),
                    width: size.width * 0.6,
                    height: size.height * 0.04,
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.grey[700],
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return EditProfile();
                        }));
                      },
                      child: Card(
                        
                        elevation: 10,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Spacer(),
                            Center(
                              child: Text(
                                "Edit Profile",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ProfileMenu(
                    text: "My Account",
                    icon: "assets/icons/User Icon.svg",
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/obsidianrune-vuejs.appspot.com/o/RuiLogo.png?alt=media&token=2a00ea98-57ac-45ee-9da9-008127c19d2a",
                    press: () => {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AccountMenu();
                      }))
                    },
                  ),
                  ProfileMenu(
                    text: "Notifications",
                    icon: "assets/icons/Bell.svg",
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/obsidianrune-vuejs.appspot.com/o/RuiLogo.png?alt=media&token=2a00ea98-57ac-45ee-9da9-008127c19d2a",
                    press: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return NotificationMenu();
                      }));
                    },
                  ),
                  ProfileMenu(
                    text: "Privacy",
                    icon: "assets/icons/Question mark.svg",
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/obsidianrune-vuejs.appspot.com/o/RuiLogo.png?alt=media&token=2a00ea98-57ac-45ee-9da9-008127c19d2a",
                    press: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return PrivacyMenu();
                      }));
                    },
                  ),
                  ProfileMenu(
                    text: "Help",
                    icon: "assets/icons/Log out.svg",
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/obsidianrune-vuejs.appspot.com/o/RuiLogo.png?alt=media&token=2a00ea98-57ac-45ee-9da9-008127c19d2a",
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return HelpMenu();
                          },
                        ),
                      );
                    },
                  ),
                  ProfileMenu(
                    text: "Log Out",
                    icon: "assets/icons/Log out.svg",
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/obsidianrune-vuejs.appspot.com/o/RuiLogo.png?alt=media&token=2a00ea98-57ac-45ee-9da9-008127c19d2a",
                    press: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) {
                      //       return LoginScreen();
                      //     },
                      //   ),
                      // );
                    },
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
