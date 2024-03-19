import 'package:cloud_firestore/cloud_firestore.dart'; //This is the push and pull
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journey2/auth.dart';
import 'package:journey2/constants.dart';
import 'package:journey2/pages/home_page.dart';

class NewRideAlong extends StatefulWidget {
  const NewRideAlong({Key? key}) : super(key: key);

  @override
  _NewRideAlongState createState() => _NewRideAlongState();
}

class _NewRideAlongState extends State<NewRideAlong> {
//Global Variables/functions
  final TextEditingController _newRideAlongTextController =
      TextEditingController();

  //New Text
  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newStartDate = TextEditingController();
  final TextEditingController _newDescription = TextEditingController();
  final TextEditingController _newPrivacySetting = TextEditingController();

  var errorMsg = "";
  //Push Data to Firebase

  //This is the area to get the text from the user
  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
        style: const TextStyle(color: Colors.white),
        controller: controller,
        decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromARGB(132, 37, 32, 32),
            hintText: title,
            hintStyle: const TextStyle(color: Colors.white),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            )));
  }

  Widget _saveButton() {
    var txtValue = "Save";
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 25),
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
          backgroundColor: Colors.red[800]),
      onPressed: () async {
        setState(() {
          if (_newRideAlongTextController.text == "") {
            errorMsg = "Stop playing - Add Text. . .";
          } else {
            //Save The Post
          }
        });
      },
      child: Text(txtValue),
    );
  }

  //Speed Run Firebase Save
  Future<void> _postToFirebase() async {
    var currentUser = Auth().currentUser;
    var now = DateTime.now();
    var formatDate = DateFormat('mm/dd/yyyy - kk:mm');
    String cleanDate = formatDate.format(now);
    await FirebaseFirestore.instance.collection("Posts").add({
      "userKey": currentUser?.uid,
      "text": _newRideAlongTextController.text,
      'date': cleanDate.toString(),
      "TimeStamp": "Thu JUN 8 7:08PM"
    }).whenComplete(() => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        ));
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2023),
        lastDate: DateTime(2100));
    if (picked != null)
      setState(() {
        _newStartDate.text = DateFormat.yMd().format(picked) as String;
      });
  }

  @override
  void dispose() {
    //Place all controllers here for disposal
    _newStartDate.dispose();
    _newNameController.dispose();
    _newRideAlongTextController.dispose();
    _newDescription.dispose();
    _newPrivacySetting.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //formats for all devices
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Color.fromARGB(255, 49, 11, 11),
            height: size.height,
            width: size.width,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height * 0.15,
                  ),
                  Text(
                    "Create New Ride Along",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Container(
                    width: size.width * 0.90,
                    child: _entryField(
                        "Enter Name for Ride Along. . .", _newNameController),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Container(
                    width: size.width * 0.9,
                    child: TextField(
                        style: const TextStyle(color: Colors.white),
                        controller: _newDescription,
                        keyboardType: TextInputType.multiline,
                        minLines: 5, // Normal textInputField will be displayed
                        maxLines: 5,
                        decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color.fromARGB(132, 37, 32, 32),
                            hintText: "Description for Ride Along",
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            )) // When user presses enter it will adapt to it
                        ),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Container(
                    height: size.height * 0.05,
                    width: size.width * 0.8,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _selectDate(context);
                          },
                          icon: Icon(Icons.date_range),
                          color: Colors.white,
                          iconSize: 25,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        if (_newStartDate.text == "") ...[
                          Text(
                            "Select Date. . .",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.05,
                                fontWeight: FontWeight.bold),
                          )
                        ] else ...[
                          GestureDetector(
                              onTap: () {
                                _selectDate(context);
                              },
                              child: Text(
                                "Schedule For : " + _newStartDate.text,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.05,
                                    fontWeight: FontWeight.bold),
                              ))
                        ]
                      ],
                    ),
                  ),
                  Container(
                    height: size.height * 0.05,
                    width: size.width * 0.8,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _selectDate(context);
                          },
                          icon: Icon(Icons.date_range),
                          color: Colors.white,
                          iconSize: 25,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        if (_newStartDate.text == "") ...[
                          Text(
                            "Select Date. . .",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.05,
                                fontWeight: FontWeight.bold),
                          )
                        ] else ...[
                          GestureDetector(
                              onTap: () {
                                _selectDate(context);
                              },
                              child: Text(
                                "Schedule For : " + _newStartDate.text,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.05,
                                    fontWeight: FontWeight.bold),
                              ))
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Text(
//           errorMsg,
//           style: TextStyle(
//               color: Colors.red[700],
//               fontWeight: FontWeight.bold),
//         ),
//         Text(
//           "Create New Ride Along",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: size.width * 0.07,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(
//           height: size.height * 0.05,
//         ),
//         _entryField(
//             "Enter Name for Ride Along. . .", _newNameController),
//         SizedBox(
//           height: size.height * 0.05,
//         ),
//         TextField(
//             style: const TextStyle(color: Colors.white),
//             controller: _newDescription,
//             keyboardType: TextInputType.multiline,
//             minLines:
//                 5, // Normal textInputField will be displayed
//             maxLines: 5,
//             decoration: const InputDecoration(
//                 filled: true,
//                 fillColor: Color.fromARGB(132, 37, 32, 32),
//                 hintText: "Description for Ride Along",
//                 hintStyle: TextStyle(color: Colors.white),
//                 enabledBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white),
//                 )) // When user presses enter it will adapt to it
//             ),
//         SizedBox(
//           height: size.height * 0.05,
//         ),
//         Row(
//           children: [
//             IconButton(
//               onPressed: () {
//                 _selectDate(context);
//               },
//               icon: Icon(Icons.date_range),
//               color: Colors.white,
//               iconSize: 25,
//             ),
//             SizedBox(
//               width: size.width * 0.3,
//             ),
//             GestureDetector(
//               onTap: () {
//                 _selectDate(context);
//               },
//             ),
//             if (_newStartDate.text == "") ...[
//               const Text(
//                 "Select Date. . .",
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold),
//               )
//             ] else ...[
//               Text(
//                 _newStartDate.text,
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold),
//               )
//             ]
//           ],
//         ),
