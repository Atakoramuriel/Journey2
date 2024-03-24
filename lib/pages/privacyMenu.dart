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
// import 'package:flutter_auth/Screens/Tools/viewBlocked.dart';
// import 'package:flutter_auth/constants.dart';

class PrivacyMenu extends StatefulWidget {
  //Variables for toggle buttons
  bool privateAccount;
  bool privatePosts;
  bool privateLegacies;
  PrivacyMenu(
      {this.privateAccount = false,
      this.privatePosts = false,
      this.privateLegacies = true});
  @override
  _PrivacyMenuState createState() => _PrivacyMenuState();
}

//Enum for radio buttons
enum AllowFrom { Everyone, Friends, None }

class _PrivacyMenuState extends State<PrivacyMenu> {
  AllowFrom _commentsFrom = AllowFrom.Everyone;
  AllowFrom _messagesFrom = AllowFrom.Everyone;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Privacy",
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
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 10),
        child: Container(
          color: kBackgroundColor,
          child: Column(
            children: <Widget>[
              Column(children: <Widget>[
                SizedBox(
                  height: 5,
                ),
                //List of all of the button options
                Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 1,
                      ),
                      Icon(
                        Icons.lock_outline_rounded,
                        color: kPrimaryColor,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Private Account",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Switch(
                        value: widget.privateAccount,
                        onChanged: (value) {
                          setState(() {
                            widget.privateAccount = value;
                            print(widget.privateAccount);
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
                      SizedBox(
                        width: 1,
                      ),
                      Icon(
                        Icons.add,
                        color: kPrimaryColor,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Private Posts",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Switch(
                        value: widget.privatePosts,
                        onChanged: (value) {
                          setState(() {
                            widget.privatePosts = value;
                            print(widget.privatePosts);
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
                      SizedBox(
                        width: 1,
                      ),
                      Icon(
                        Icons.post_add,
                        color: kPrimaryColor,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Private Legacies",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Switch(
                        value: widget.privateLegacies,
                        onChanged: (value) {
                          setState(() {
                            widget.privateLegacies = value;
                            print(widget.privateLegacies);
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
                      Icon(
                        Icons.comment_rounded,
                        color: kPrimaryColor,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Allow Messages from : ",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Column(
                  children: <Widget>[
                    ListTile(
                      title: const Text(
                        'Everyone',
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: Radio<AllowFrom>(
                        value: AllowFrom.Everyone,
                        groupValue: _messagesFrom,
                        onChanged: (value) {
                          setState(() {
                            _messagesFrom = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Friends',
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: Radio<AllowFrom>(
                        value: AllowFrom.Friends,
                        groupValue: _messagesFrom,
                        onChanged: (value) {
                          setState(() {
                            _messagesFrom = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'No One',
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: Radio<AllowFrom>(
                        value: AllowFrom.None,
                        groupValue: _messagesFrom,
                        onChanged: (value) {
                          setState(() {
                            _messagesFrom = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.grey,
                ),
                Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.chat_bubble_outline,
                        color: kPrimaryColor,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Allow Comments from : ",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Column(
                  children: <Widget>[
                    ListTile(
                      title: const Text(
                        'Everyone',
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: Radio<AllowFrom>(
                        value: AllowFrom.Everyone,
                        groupValue: _commentsFrom,
                        onChanged: (value) {
                          setState(() {
                            _commentsFrom = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Friends',
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: Radio<AllowFrom>(
                        value: AllowFrom.Friends,
                        groupValue: _commentsFrom,
                        onChanged: (value) {
                          setState(() {
                            _commentsFrom = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'No One',
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: Radio<AllowFrom>(
                        value: AllowFrom.None,
                        groupValue: _commentsFrom,
                        onChanged: (value) {
                          setState(() {
                            _commentsFrom = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.grey,
                ),
                MaterialButton(
                  minWidth: size.width,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) {
                    //       //
                    //       return ViewBlocked();
                    //     },
                    //   ),
                    // );
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Blocked Accounts",
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
                Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    children: <Widget>[],
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
