import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journey2/constants.dart';
import 'package:journey2/pages/profile_nav.dart';
import 'package:google_fonts/google_fonts.dart';

class Rider {
  String username;
  String profileImage;
  String bio;
  Rider(
      {required this.username, required this.profileImage, required this.bio});
}

Future getUser(userKey) async {
  Map<String, dynamic>? rider;

  await FirebaseFirestore.instance
      .collection("Riders")
      .doc(userKey)
      .get()
      .then((doc) {
    if (doc.exists) {
      // print(doc.data());
      rider = doc.data();
      // print(rider);
    }

    // rider = Rider(
    //     username: doc['displayName'],
    //     profileImage: doc['photoURL'],
    //     bio: doc['bio']);
  }).whenComplete(() {});

  return rider;
}

final FirebaseAuth auth = FirebaseAuth.instance;

class ProfileView extends StatefulWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  var userID = FirebaseAuth.instance.currentUser?.uid;

  ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  //Test Tab Controllers
  //TabController _tabController;
  final List<Tab> _tabs = <Tab>[
    Tab(text: 'Posts'),
    Tab(text: 'Bio'),
    Tab(text: 'Settings'),
  ];

  //Animated Variables End
  bool start = true;

  //Let's try another approach - 5 Animations
  late Animation<double> animation,
      animation2,
      animation3,
      animation4,
      animation5,
      animation6;
  late AnimationController animationController, ac2, ac3, ac4, ac5, ac6;

  late TabController _tab2Controller;
  late ScrollController _scrollController;
  var userID = FirebaseAuth.instance.currentUser?.uid;
  var userEmail = FirebaseAuth.instance.currentUser?.email;
  var profileImg = FirebaseAuth.instance.currentUser!.photoURL;
  var username = FirebaseAuth.instance.currentUser!.displayName;

  //Quick Functions

  //Collection of Widgets
  Widget _StandardRider(size) {
    return Container(
      padding: EdgeInsets.all(5),
      height: size.height,
      width: size.width,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(0, animation.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 1.2,
                        color: Colors.red.withOpacity(0.2),
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(30, animation2.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 1.9,
                        color: Colors.red.withOpacity(0.2),
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(80, animation3.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 0.09,
                        color: Colors.red.withOpacity(0.2),
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(0, animation4.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 0.9,
                        color: Colors.red.withOpacity(0.2),
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(75, animation5.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      height: size.height * 0.005,
                      width: size.width * 0.03,
                      color: Colors.red.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Transform.translate(
              offset: Offset(0, animation6.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      height: size.height * 0.005,
                      width: size.width * 0.4,
                      color: Colors.red.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _TravelerRider(size) {
    return Container(
      padding: EdgeInsets.all(5),
      height: size.height,
      width: size.width,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(0, animation.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 1.2,
                        color: Colors.green,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(30, animation2.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 1.9,
                        color: Colors.green,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(80, animation3.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 0.09,
                        color: Colors.green,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(0, animation4.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 0.9,
                        color: Colors.green,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(75, animation5.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      height: size.height * 0.005,
                      width: size.width * 0.03,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Transform.translate(
              offset: Offset(0, animation6.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      height: size.height * 0.005,
                      width: size.width * 0.4,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _NightRider(size) {
    return Container(
      padding: EdgeInsets.all(5),
      height: size.height,
      width: size.width,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(0, animation.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.001,
                        width: size.width * 1.2,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(30, animation2.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.001,
                        width: size.width * 1.9,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(80, animation3.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.001,
                        width: size.width * 0.09,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(0, animation4.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.001,
                        width: size.width * 0.9,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(75, animation5.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      height: size.height * 0.001,
                      width: size.width * 0.03,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Transform.translate(
              offset: Offset(0, animation6.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      height: size.height * 0.001,
                      width: size.width * 0.4,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _GhostRider(size) {
    return Container(
      padding: EdgeInsets.all(5),
      height: size.height,
      width: size.width,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(0, animation.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 1.2,
                        color: Colors.blueGrey,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(30, animation2.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 1.9,
                        color: Colors.blueGrey,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(80, animation3.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 0.09,
                        color: Colors.blueGrey,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(0, animation4.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 0.9,
                        color: Colors.blueGrey,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(75, animation5.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      height: size.height * 0.005,
                      width: size.width * 0.03,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Transform.translate(
              offset: Offset(0, animation6.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      height: size.height * 0.005,
                      width: size.width * 0.4,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _SquibRider(size) {
    return Container(
      padding: EdgeInsets.all(5),
      height: size.height,
      width: size.width,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(0, animation.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 1.2,
                        color: Colors.red,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(30, animation2.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 1.9,
                        color: Colors.purple,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(80, animation3.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 0.09,
                        color: Colors.blue,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(0, animation4.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        height: size.height * 0.005,
                        width: size.width * 0.9,
                        color: Colors.orange,
                      )),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(75, animation5.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      height: size.height * 0.005,
                      width: size.width * 0.03,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Transform.translate(
              offset: Offset(0, animation6.value),
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      height: size.height * 0.005,
                      width: size.width * 0.4,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Tab Widgets

  // Vex
  Widget _buildButton(BuildContext context, String text, IconData icon) {
    return InkWell(
      onTap: () {
        // TODO: Implement action for button press
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon),
            SizedBox(width: 16.0),
            Text(text),
            Spacer(),
            Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }

  //initialize the values of the class
  @override
  void initState() {
    // print("ARRIVED @ ProfileView()");

    super.initState();
    _tab2Controller = TabController(length: _tabs.length, vsync: this);
    //Working animation process
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 8));
    animation =
        Tween<double>(begin: -500, end: 650).animate(animationController)
          ..addListener(() {
            setState(() {});
          });

    //second Animation steps
    ac2 = AnimationController(vsync: this, duration: Duration(seconds: 10));
    animation2 = Tween<double>(begin: -1250, end: 650).animate(ac2)
      ..addListener(() {
        setState(() {});
      });
    //third Animation steps
    ac3 = AnimationController(vsync: this, duration: Duration(seconds: 9));
    animation3 = Tween<double>(begin: -1050, end: 650).animate(ac3)
      ..addListener(() {
        setState(() {});
      });

    //fourth Animation steps
    ac4 = AnimationController(vsync: this, duration: Duration(seconds: 7));
    animation4 = Tween<double>(begin: -500, end: 750).animate(ac4)
      ..addListener(() {
        setState(() {});
      });

    //fifth Animation steps
    ac5 = AnimationController(vsync: this, duration: Duration(seconds: 11));
    animation5 = Tween<double>(begin: -1220, end: 750).animate(ac4)
      ..addListener(() {
        setState(() {});
      });

    //final Animation steps
    ac6 = AnimationController(vsync: this, duration: Duration(seconds: 5));
    animation6 = Tween<double>(begin: -1000, end: 750).animate(ac4)
      ..addListener(() {
        setState(() {});
      });

    //Start the animations
    animationController.forward();
    ac2.forward();
    ac3.forward();
    ac4.forward();
    ac5.forward();
    animationController.repeat();
    ac2.repeat();
    ac3.repeat();
    ac4.repeat();
    ac5.repeat();
  }

  //For the desposal
  @override
  void dispose() {
    _tab2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return FutureBuilder(
        future: getUser(userID),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                body: Stack(
              children: [
                //Start of Animations
                if (snapshot.data["RiderType"] == "Standard") ...[
                  _StandardRider(size),
                ] else if (snapshot.data["RiderType"] == "Traveler") ...[
                  _TravelerRider(size),
                ] else if (snapshot.data["RiderType"] == "Night") ...[
                  _NightRider(size),
                ] else if (snapshot.data["RiderType"] == "Ghost") ...[
                  _GhostRider(size),
                ] else if (snapshot.data["RiderType"] == "Squib") ...[
                  _SquibRider(size),
                ],

//                 //End of Animations
                SizedBox(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: size.height * 0.07,
                            ),
                            CircleAvatar(
                              radius: size.width * 0.15,
                              backgroundImage:
                                  NetworkImage(snapshot.data["profileImg"]),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Text(
                              snapshot.data["userName"],
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: size.width * 0.06,
                              ),
                            ),

                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Text(
                              snapshot.data["Bio"],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.05,
                              ),
                            ),

                            //This is the Row for the user information
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //Break into four Columns
                                //rides
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  height: size.height * 0.15,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "0",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * 0.07),
                                      ),
                                      Text(
                                        "Rides",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * 0.04),
                                      ),
                                    ],
                                  ),
                                ),

                                //rides
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  height: size.height * 0.15,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "0",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * 0.07),
                                      ),
                                      Text(
                                        "Friends",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * 0.04),
                                      ),
                                    ],
                                  ),
                                ),
                                //rides
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  height: size.height * 0.15,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "0",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * 0.07),
                                      ),
                                      Text(
                                        "Badges",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * 0.04),
                                      ),
                                    ],
                                  ),
                                ),
                                //rides
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  height: size.height * 0.15,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "0",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * 0.07),
                                      ),
                                      Text(
                                        "Rides",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * 0.04),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            TabBar(
                              controller: _tab2Controller,
                              tabs: _tabs,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: size.height * 0.4,
                          width: size.width,
                          child: TabBarView(
                            controller: _tab2Controller,
                            children: [
                              //If there are no posts
                              //Show the no posts for now
                              Center(
                                child: Text(
                                  'No Posts',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width * 0.05),
                                ),
                              ),

                              //This is the User Bio Section to show previous Rides
                              //Previous Rides
                              //Motorcycle Info
                              Container(
                                  child: Column(
                                children: [
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                  if (snapshot.data["RiderType"] ==
                                      "Night") ...[
                                    Text(
                                      snapshot.data["RiderType"] + " Rider",
                                      style: GoogleFonts.allura(
                                          fontStyle: FontStyle.normal,
                                          textStyle: TextStyle(
                                              color: Color(0xff8c92ac),
                                              fontSize: 35)),
                                    ),
                                  ] else if (snapshot.data["RiderType"] ==
                                      "Standard") ...[
                                    Text(
                                      snapshot.data["RiderType"] + " Rider",
                                      style: GoogleFonts.bodoniModa(
                                        fontSize: size.width * 0.07,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              )),
                              SizedBox(
                                  height: size.height,
                                  width: size.width,
                                  child: SingleChildScrollView(
                                      child: Column(
                                    children: [
                                      //This is the Row of the My Garage and Past Rides
                                      Row(
                                        children: [
                                          Spacer(),
                                          Center(
                                              /** Card Widget **/
                                              child: GestureDetector(
                                            onTap: () {
                                              print("Tapped My Garage Button");
                                            },
                                            child: Card(
                                              elevation: 50,
                                              shadowColor: Colors.black,
                                              color: Colors.blueGrey[800],
                                              child: SizedBox(
                                                width: size.width * 0.4,
                                                height: size.height * 0.06,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Column(
                                                    children: [
                                                      //CircleAvatar

                                                      Text(
                                                        'My Garage',
                                                        style: TextStyle(
                                                          fontSize:
                                                              size.width * 0.05,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ), //Textstyle
                                                      ), //Text
                                                      //Text
                                                      //SizedBox
                                                    ],
                                                  ), //Column
                                                ), //Padding
                                              ), //SizedBox
                                            ),
                                          ) //Card
                                              ),
                                          SizedBox(
                                            height: size.height * 0.01,
                                          ),
                                          Center(
                                              /** Card Widget **/
                                              child: GestureDetector(
                                            onTap: () {
                                              print("Tapped Past Rides Button");
                                            },
                                            child: Card(
                                              elevation: 50,
                                              shadowColor: Colors.black,
                                              color: Colors.lightBlue[900],
                                              child: SizedBox(
                                                width: size.width * 0.4,
                                                height: size.height * 0.06,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Column(
                                                    children: [
                                                      //CircleAvatar

                                                      Text(
                                                        'Past Rides',
                                                        style: TextStyle(
                                                          fontSize:
                                                              size.width * 0.05,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ), //Textstyle
                                                      ), //Text
                                                      //Text
                                                      //SizedBox
                                                    ],
                                                  ), //Column
                                                ), //Padding
                                              ), //SizedBox
                                            ),
                                          ) //Card
                                              ),
                                          Spacer(),
                                        ],
                                      ),

                                      //This is the List of Buttons
                                    ],
                                  ))),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ));
          }

          return Container(
            padding: EdgeInsets.all(20),
            width: size.width,
            height: size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator()],
            ),
          );
        });
  }
}
//Hold 0
