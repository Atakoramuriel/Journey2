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
// import 'package:flutter_auth/Screens/Tools/editPassword.dart';
// import 'package:flutter_auth/Screens/Tools/newLegacyPostMenu.dart';
// import 'package:flutter_auth/Screens/Tools/newPostMenu.dart';
// import 'package:flutter_auth/Screens/Tools/personalInformation.dart';
// import 'package:flutter_auth/constants.dart';

// ignore: must_be_immutable
class AccountMenu extends StatefulWidget {
  //variables for toggle buttons
  bool useData;
  AccountMenu({this.useData = true});

  @override
  _AccountMenuState createState() => _AccountMenuState();
}

class _AccountMenuState extends State<AccountMenu> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account",
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
                MaterialButton(
                  minWidth: size.width,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  onPressed: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) {
                    //   return EditPersonalInfo();
                    // }));
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Personal Information",
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
                Divider(
                  color: Colors.grey,
                ),
                MaterialButton(
                  minWidth: size.width,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  onPressed: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) {
                    //   return EditPassword();
                    // }));
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Change Password",
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
                Divider(
                  color: Colors.grey,
                ),
                MaterialButton(
                  minWidth: size.width,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  onPressed: () {},
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Saved Posts",
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
                Divider(
                  color: Colors.grey,
                ),
                Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Use Cellular Data",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Switch(
                        value: widget.useData,
                        onChanged: (value) {
                          setState(() {
                            widget.useData = value;
                            print(widget.useData);
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
                MaterialButton(
                  minWidth: size.width,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  onPressed: () {},
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Delete Account",
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
