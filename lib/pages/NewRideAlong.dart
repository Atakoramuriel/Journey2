import 'dart:io';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart'; //This is the push and pull
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_card/image_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:journey2/Classes/PointData.dart';
import 'package:journey2/Classes/RideAlong.dart';
import 'package:journey2/auth.dart';
import 'package:journey2/constants.dart';
import 'package:journey2/pages/home_page.dart';
import 'package:path_provider/path_provider.dart';

class NewRideAlong extends StatefulWidget {
  final pointData srcPoint;

  const NewRideAlong({Key? key, required this.srcPoint}) : super(key: key);

  @override
  _NewRideAlongState createState() =>
      _NewRideAlongState(srcPoint: this.srcPoint);
}

class _NewRideAlongState extends State<NewRideAlong> {
//Test
  final pointData srcPoint;
  _NewRideAlongState({required this.srcPoint});

//Global Variables/functions
  final TextEditingController _newRideAlongTextController =
      TextEditingController();

  //New Text
  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newStartDate = TextEditingController();
  final TextEditingController _newDescription = TextEditingController();
  final TextEditingController _newPrivacySetting = TextEditingController();

//The usual
  //Start
  late String _setTime, _setDate;

  late String _hour, _minute, _time;

  late String dateTime;

  DateTime selectedDate = DateTime.now();
  bool use24HourTime = false;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  final TextEditingController _newStartTime = TextEditingController();

  //New Text
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  var errorMsg = "";
  var selectedImg = "";
  //Push Data to Firebase

  File? _image;
  File? selectedGalleryImg;
  bool selectedFile = false;
  //End

  //Push Data to Firebase

  Future _getImage() async {
    print("_getImage Called ");
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final imageTemp = File(image.path);

    print("Image collected : " + imageTemp.toString());

    setState(() {
      _image = imageTemp;
      selectedGalleryImg = _image;
      selectedFile = true;
      print("\n\n\n\n\n\n");
      print("Setting stage of image ${imageTemp}");
      print("Setting stage of image ${_image}");
      print("Setting stage of image ${selectedGalleryImg}");
      print("\n\n\n\n\n\n");
      assignCoverPhoto();
      // assignProfilePhoto();
    });
  }

//Start

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load(path);

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _newStartTime.text = "" +
            picked.hour.toString().padLeft(2, '0') +
            ":" +
            picked.minute.toString().padLeft(2, '0') +
            picked.period.toString().split('.')[1];
      });
      print("\n\n\n\n\n");
      // String formattedTime = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      print({
        picked.hour.toString() +
            ':' +
            picked.minute.toString() +
            "${picked.period.toString().split('.')[1]}"
      });
      print("\n\n\n\n\n");
    }
  }

  Future assignCoverPhoto() async {
    Reference firebaseRef = FirebaseStorage.instance.ref();
    Reference firebaseUserRef = FirebaseStorage.instance.ref();
    String stockImgRef = "";
    final FirebaseAuth _auth = FirebaseAuth.instance;
    File stockFile;
    User? currentUser = _auth.currentUser;

    //Send the Image to firebase
    if (selectedGalleryImg != null) {
      stockFile = selectedGalleryImg!;
      print("Selected Gallery Image Found: " +
          selectedGalleryImg!.path.characters.toString());
      firebaseUserRef = FirebaseStorage.instance
          .ref(Auth().currentUser!.uid)
          .child("RideAlongCovers/${selectedGalleryImg}");
    }

    if (selectedGalleryImg != null && selectedFile) {
      //This works
      print("Attempting to upload image to firebase");
      await firebaseUserRef
          .putFile(File(selectedGalleryImg!.path))
          .whenComplete(() => {print("uploading image complete")});
      print(" ~~~~  Prepping to get Download URL \n");
      firebaseUserRef
          .getDownloadURL()
          .then((urlValue) => {
                print("Download URL obtained successfully : " + urlValue),
                setState(() {
                  print("Setting the widget value of the CircleAvatar==> " +
                      urlValue);
                  selectedImg = urlValue;
                })
              })
          .catchError((Error) => {print("Error getting download URL")});
    }

    //User has selected one of the stock images at the top
    if (!selectedFile) {
      // await firebaseRef.putFile(File(selectedImg!));
    }
  }

  Future<void> _createRideAlong(pointData point) async {
    var currentUser = Auth().currentUser;

    var newJourney = RideAlong(
        coverImg: selectedImg,
        title: _newNameController.text,
        description: _newDescription.text,
        coordinates: {'latitude': point.pointLat, "longitude": point.pointLong},
        startDate: _newStartDate.text,
        startTime: _newStartTime.text,
        date: "${_newStartDate.text} at ${_newStartTime.text}",
        Type: "RideAlong");

    //Add to The FBDB
    await FirebaseFirestore.instance.collection("Markers").add({
      "coverImg": selectedImg,
      "title": _newNameController.text,
      "description": _newDescription.text,
      "coordinates": {'latitude': point.pointLat, "longitude": point.pointLong},
      "startDate": _newStartDate.text,
      "startTime": _newStartTime.text,
      "date": "${_newStartDate.text} at ${_newStartTime.text}",
      "Type": "RideAlong",
      "Host": currentUser!.uid.toString()
    }).then((value) => {Navigator.pop(context)});
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
            color: kNightCard,
            height: size.height,
            width: size.width,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height * 0,
                  ),
                  Stack(
                    children: [
                      if (selectedGalleryImg == null && !selectedFile) ...[
                        GestureDetector(
                          child: FillImageCard(
                            color: Colors.transparent,
                            width: size.width,
                            heightImage: size.height * 0.3,
                            imageProvider:
                                const AssetImage('assets/images/A9.png'),
                          ),
                          onTap: _getImage,
                        ),
                      ] else ...[
                        GestureDetector(
                          child: FillImageCard(
                            color: Colors.transparent,
                            width: size.width,
                            heightImage: size.height * 0.3,
                            imageProvider: FileImage(selectedGalleryImg!),
                          ),
                          onTap: _getImage,
                        ),
                      ],
                      SizedBox(
                        height: size.height * 0.20,
                        width: size.width,
                        child: Column(children: [
                          const Spacer(),
                          Row(
                            children: [
                              const Spacer(),
                              Container(
                                  color: ui.Color.fromARGB(165, 0, 0, 0),
                                  width: size.width,
                                  child: Row(
                                    children: [
                                      Spacer(),
                                      Text(
                                        "Tap to Add Cover Img",
                                        style: TextStyle(
                                            fontSize: size.width * 0.08,
                                            color: ui.Color.fromARGB(
                                                255, 212, 212, 212),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Spacer()
                                    ],
                                  )),
                              const Spacer()
                            ],
                          )
                        ]),
                      )
                    ],
                  ),
                  if (errorMsg != "") ...[
                    Text(
                      errorMsg,
                      style: TextStyle(
                        color: const ui.Color.fromARGB(255, 203, 0, 0),
                        fontSize: size.width * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  Text(
                    "Create New Ride Along",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.025,
                  ),
                  Container(
                    width: size.width * 0.90,
                    child: _entryField("Title. . .", _newNameController),
                  ),
                  SizedBox(
                    height: size.height * 0.025,
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
                            hintText: "Description. . .",
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            )) // When user presses enter it will adapt to it
                        ),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  if (_newStartDate.text != "" && _newStartTime.text != "") ...[
                    Row(
                      children: [
                        const Spacer(),
                        Text(
                          "Scheduled for : " +
                              _newStartDate.text.toString() +
                              " at " +
                              _newStartTime.text.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer()
                      ],
                    ),
                    SizedBox(
                      height: size.height * 0.05,
                    )
                  ],
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
                  SizedBox(
                    height: size.height * 0.025,
                  ),
                  Container(
                    height: size.height * 0.025,
                    width: size.width * 0.8,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _selectTime(context);
                          },
                          icon: Icon(Icons.av_timer),
                          color: Colors.white,
                          iconSize: 25,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        if (_newStartTime.text == "") ...[
                          Text(
                            "Select Time. . .",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.05,
                                fontWeight: FontWeight.bold),
                          )
                        ] else ...[
                          GestureDetector(
                              onTap: () {
                                _selectTime(context);
                              },
                              child: Text(
                                "Start Time: " + _newStartTime.text.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.05,
                                    fontWeight: FontWeight.bold),
                              ))
                        ]
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Row(
                    children: [
                      Spacer(),
                      ElevatedButton(
                        child: Text(
                          "Create",
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const ui.Color.fromARGB(255, 59, 81, 222),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (_newNameController.text == "") {
                            errorMsg = "Must add Title...";
                          } else if (_newDescription.text == "") {
                            errorMsg =
                                "Must add a description of the ride along";
                          } else if (_newStartDate.text == "") {
                            errorMsg = "Must select date for the ride along";
                          } else if (_newStartTime.text == "") {
                            errorMsg = "Must select time for the ride along ";
                          } else {
                            setState(() {
                              errorMsg = "";
                            });

                            print("\n\n\n\n\n\nn\n\n\nn\n");
                            print("Creating New Ride Along ");
                            print("\n\n\n\n\n\nn\n\n\nn\n");
                            _createRideAlong(this.srcPoint);
                          }
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ui.Color.fromARGB(255, 216, 32, 47),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Spacer()
                    ],
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
