import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:journey2/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_auth/Screens/Login/login_screen.dart';
// import 'package:flutter_auth/Screens/Main/Pages/Settings.dart';
// import 'package:flutter_auth/Screens/Main/Pages/chat.dart';
// import 'package:flutter_auth/Screens/Main/Pages/dashboard.dart';
// import 'package:flutter_auth/Screens/Main/Pages/messages.dart';
// import 'package:flutter_auth/Screens/Main/Pages/notifications.dart';
// import 'package:flutter_auth/Screens/Main/Pages/profile.dart';
// import 'package:flutter_auth/Screens/Main/Pages/profile_pic.dart';
// import 'package:flutter_auth/Screens/Main/components/body.dart';
// import 'package:flutter_auth/Screens/Main/home_screen.dart';
// import 'package:flutter_auth/Screens/Main/modules/chat_detail_page.dart';
// import 'package:flutter_auth/Screens/Main/modules/chat_page.dart';
// import 'package:flutter_auth/Screens/Signup/signup_screen.dart';
// import 'package:flutter_auth/constants.dart';
// import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class EditProfile extends StatefulWidget {
  //Values needed for page
  String username;
  String email;
  String bio;
  String rune;

  EditProfile(
      {this.username = "Lord Atakora",
      this.email = "inquire@obsidianrune.com",
      this.bio = "Constant Development",
      this.rune = "Obsidian"});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  //Controllers
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  var bioController = TextEditingController();

  late String tempImage;
  File? _profileImg = null;

  late String username;
  late String profileImg;
  //  final ImagePicker _picker = ImagePicker();
  Future _getImage() async {
    // var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    //Set State
    setState(() {
      // _profileImg = image;
      // print('_profileImg: $_profileImg');
    });
  }

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

  @override
  Widget build(BuildContext context) {
    this.usernameController.text = widget.username.toString();
    this.emailController.text = widget.email.toString();

    Size size = MediaQuery.of(context).size;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        //resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          leadingWidth: size.width * 0.3,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Spacer()
                  ],
                ),
              ],
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: kBlueShade,
          title: Row(
            children: <Widget>[
              Spacer(),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0)),
                color: Colors.blueGrey[700],
                onPressed: () {
                  print("Updating");
                  //After post return to the main page
                  Navigator.pop(context);
                },
                child: Text(
                  "Update",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: kBackgroundColor,
            height: size.height,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 15,
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
                                backgroundImage: FileImage(_profileImg!),
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
                      "Change Profile Image",
                      style: TextStyle(color: Colors.amber[700]),
                    ),
                    Spacer()
                  ],
                ),
                Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        inputFormatters: [
                          //Set the max number of characters, this should give you five pages
                          LengthLimitingTextInputFormatter(30),
                        ],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter Username",
                          hintStyle: TextStyle(color: Colors.white),
                          //enabledBorder: InputBorder.none,
                          //focusedBorder: InputBorder.none,
                          //prefixIcon: Icon(Icons.search,color: Colors.grey.shade400,size: 20,),
                          filled: false,
                          fillColor: Colors.grey[850],
                          contentPadding: EdgeInsets.all(15),
                        ),
                        controller: usernameController,
                      ),
                    )
                  ],
                ),
                Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        inputFormatters: [
                          //Set the max number of characters, this should give you five pages
                          LengthLimitingTextInputFormatter(30),
                        ],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter Username",
                          hintStyle: TextStyle(color: Colors.white),
                          //enabledBorder: InputBorder.none,
                          //focusedBorder: InputBorder.none,
                          //prefixIcon: Icon(Icons.search,color: Colors.grey.shade400,size: 20,),
                          filled: false,
                          fillColor: Colors.grey[850],
                          contentPadding: EdgeInsets.all(15),
                        ),
                        controller: emailController,
                      ),
                    )
                  ],
                ),
                Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        inputFormatters: [
                          //Set the max number of characters, this should give you five pages
                          LengthLimitingTextInputFormatter(30),
                        ],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Update Bio. . .",
                          hintStyle: TextStyle(color: Colors.white),
                          //enabledBorder: InputBorder.none,
                          //focusedBorder: InputBorder.none,
                          //prefixIcon: Icon(Icons.search,color: Colors.grey.shade400,size: 20,),
                          filled: false,
                          fillColor: Colors.grey[850],
                          contentPadding: EdgeInsets.all(15),
                        ),
                        controller: bioController,
                      ),
                    )
                  ],
                ),
                Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                ),
              ],
            ),
          ),
        ));
  }
}
