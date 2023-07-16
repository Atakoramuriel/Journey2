import 'package:cloud_firestore/cloud_firestore.dart'; //This is the push and pull
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:journey2/auth.dart';
import 'package:journey2/constants.dart';
import 'package:journey2/pages/ProfileView.dart';
import 'package:journey2/pages/home_page.dart';

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
          child: Container(
            width: 200.0, // Set your desired width and height
            height: 200.0,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("New Ride"),
        backgroundColor: const Color.fromARGB(255, 250, 183, 0),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Start New Ride'),
          onPressed: () => _showDialog(context),
        ),
      ),
    );
  }
}
