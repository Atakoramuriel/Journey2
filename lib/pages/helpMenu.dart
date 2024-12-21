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
// import 'package:flutter_auth/Screens/Tools/NewReport.dart';
// import 'package:flutter_auth/Screens/Tools/editPassword.dart';
// import 'package:flutter_auth/Screens/Tools/newLegacyPostMenu.dart';
// import 'package:flutter_auth/Screens/Tools/newPostMenu.dart';
// import 'package:flutter_auth/Screens/Tools/personalInformation.dart';
// import 'package:flutter_auth/constants.dart';

// ignore: must_be_immutable
class HelpMenu extends StatefulWidget {
  //variables for toggle buttons
  bool useData;
  HelpMenu({this.useData = true});

  @override
  _HelpMenuState createState() => _HelpMenuState();
}

class _HelpMenuState extends State<HelpMenu> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Help",
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
                    //   return NewReport(
                    //       reportType:
                    //           "What problem would you like to Report. . ?");
                    // }));
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Report a Problem",
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
                    //   return NewReport(
                    //       reportType:
                    //           "Explain the situation with the user. . .");
                    // }));
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Report a User",
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
                    //   return NewReport(
                    //       reportType:
                    //           "What new feature would you like to see ? ");
                    // }));
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Request a new feature",
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
