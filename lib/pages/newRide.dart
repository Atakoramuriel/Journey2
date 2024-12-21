//This is the push and pull
import 'package:flutter/material.dart';
import 'package:journey2/constants.dart';

class NewRide extends StatefulWidget {
  const NewRide({Key? key}) : super(key: key);

  @override
  _NewRideState createState() => _NewRideState();
}

class _NewRideState extends State<NewRide> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: const SizedBox(
            width: 200.0, // Set your desired width and height
            height: 200.0,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 31, 31, 31),
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Create New..."),
        backgroundColor: kPrimaryAccentColor,
      ),
      body: Center(
          child: Column(
        children: [
          SizedBox(
            height: size.height * 0.05,
          ),
          Card(
            elevation: 50,
            shadowColor: Colors.black,
            color: const Color.fromARGB(255, 255, 0, 0),
            child: SizedBox(
              width: size.width * 0.8,
              height: size.height * 0.15,
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    //SizedBox
                    Text(
                      'Ride Along Event',
                      style: TextStyle(
                        fontSize: 30,
                        color: Color.fromARGB(255, 94, 27, 27),
                        fontWeight: FontWeight.w500,
                      ), //Textstyle
                    ), //Text
                    SizedBox(
                      height: 10,
                    ), //SizedBox
                    Text(
                      'Invite other riders to join you on your Journey',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ), //Textstyle
                    ), //Text
                    SizedBox(
                      height: 5,
                    ), //SizedBox//SizedBox
                  ],
                ), //Column
              ), //Padding
            ), //SizedBox
          ),
          SizedBox(
            height: size.height * 0.05,
          ),
          Card(
            elevation: 50,
            shadowColor: Colors.black,
            color: const Color.fromARGB(255, 43, 255, 0),
            child: SizedBox(
              width: size.width * 0.8,
              height: size.height * 0.15,
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    //SizedBox
                    Text(
                      'Free Ride',
                      style: TextStyle(
                        fontSize: 30,
                        color: Color.fromARGB(255, 27, 94, 42),
                        fontWeight: FontWeight.w500,
                      ), //Textstyle
                    ), //Text
                    SizedBox(
                      height: 10,
                    ), //SizedBox
                    Text(
                      'Share your location while you ride with other Riders',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 31, 49, 39),
                      ), //Textstyle
                    ), //Text
                    //SizedBox//SizedBox
                  ],
                ), //Column
              ), //Padding
            ), //SizedBox
          ),
        ],
      )),
    );
  }
}
