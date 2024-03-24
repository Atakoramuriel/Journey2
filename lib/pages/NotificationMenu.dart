import 'package:flutter/material.dart';
import 'package:journey2/constants.dart';
// import 'package:flutter_auth/Screens/Main/Pages/Images_page.dart';
// import 'package:flutter_auth/Screens/Main/Pages/Recent_Legacy_Posts.dart';
// import 'package:flutter_auth/Screens/Main/Pages/WritingList.dart';
// import 'package:flutter_auth/Screens/Main/Pages/general_post.dart';
// import 'package:flutter_auth/Screens/Main/Pages/legacy_nav.dart';
// import 'package:flutter_auth/Screens/Main/Pages/profile.dart';
// import 'package:flutter_auth/Screens/Main/Pages/profile_nav.dart';
// import 'package:flutter_auth/Screens/Main/models/send_menu_items.dart';
// import 'package:flutter_auth/Screens/Tools/newLegacyPostMenu.dart';
// import 'package:flutter_auth/Screens/Tools/newPostMenu.dart';
// import 'package:flutter_auth/constants.dart';

class NotificationMenu extends StatefulWidget {
  //Variables needed
  bool pushNotifications;
  bool postNotifications;
  bool legacyNotifications;
  bool commentNotifications;
  bool friendNotifications;
  bool messageNotifications;

//The firebase data will need to update the constructor below
  NotificationMenu(
      {this.pushNotifications = false,
      this.postNotifications = false,
      this.legacyNotifications = true,
      this.commentNotifications = true,
      this.friendNotifications = false,
      this.messageNotifications = true});

  @override
  _NotificationMenuState createState() => _NotificationMenuState();
}

class _NotificationMenuState extends State<NotificationMenu> {
  @override
  Widget build(BuildContext context) {
    //Variables for notifications
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: kBackgroundColor,
        child: Column(
          children: <Widget>[
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(children: <Widget>[
                SizedBox(
                  height: 5,
                ),
                //List of all of the button options
                Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "All Push Notifications",
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      Switch(
                        value: widget.pushNotifications,
                        onChanged: (value) {
                          setState(() {
                            widget.pushNotifications = value;
                            print(widget.pushNotifications);
                          });
                        },
                        activeTrackColor: kPrimaryColor,
                        activeColor: kPrimaryColor,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey,
                ),
                Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Post Notifications",
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      Switch(
                        value: widget.postNotifications,
                        onChanged: (value) {
                          setState(() {
                            widget.postNotifications = value;
                            print(widget.postNotifications);
                          });
                        },
                        activeTrackColor: kPrimaryColor,
                        activeColor: kPrimaryColor,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey,
                ),
                Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Legacy Notifications",
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      Switch(
                        value: widget.legacyNotifications,
                        onChanged: (value) {
                          setState(() {
                            widget.legacyNotifications = value;
                            print(widget.legacyNotifications);
                          });
                        },
                        activeTrackColor: kPrimaryColor,
                        activeColor: kPrimaryColor,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey,
                ),
                Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Comment Notifications",
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      Switch(
                        value: widget.commentNotifications,
                        onChanged: (value) {
                          setState(() {
                            widget.commentNotifications = value;
                            print(widget.commentNotifications);
                          });
                        },
                        activeTrackColor: kPrimaryColor,
                        activeColor: kPrimaryColor,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey,
                ),
                Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Friend Notifications",
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      Switch(
                        value: widget.friendNotifications,
                        onChanged: (value) {
                          setState(() {
                            widget.friendNotifications = value;
                            print(widget.friendNotifications);
                          });
                        },
                        activeTrackColor: kPrimaryColor,
                        activeColor: kPrimaryColor,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey,
                ),
                Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Message Notifications",
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      Switch(
                        value: widget.messageNotifications,
                        onChanged: (value) {
                          setState(() {
                            widget.messageNotifications = value;
                            print(widget.messageNotifications);
                          });
                        },
                        activeTrackColor: kPrimaryColor,
                        activeColor: kPrimaryColor,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey,
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}

//Standby section
// Switch(
//             value: pushNotifications,
//             onChanged: (value) {
//               setState(() {
//                 pushNotifications = value;
//                 print(pushNotifications);
//               });
//             },
//             activeTrackColor: Colors.lightGreenAccent,
//             activeColor: Colors.green,
//           ),
