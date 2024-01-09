import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart'; //This is the push and pull
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:journey2/auth.dart';
import 'package:journey2/constants.dart';
import 'package:journey2/widget_tree.dart';
import 'package:journey2/pages/ProfileView.dart';
import 'package:journey2/pages/home_page.dart';

class NewPost extends StatefulWidget {
  const NewPost({Key? key}) : super(key: key);

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
//Global Variables/functions
  final TextEditingController _newPostTextController = TextEditingController();
  var errorMsg = "";
  File? _image;
  var selectedImg = "";
  File? selectedGalleryImg;
  bool selectedFile = false;

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

  Future _getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final imageTemp = File(image.path);

    print("Image collected : " + imageTemp.toString());

    setState(() {
      _image = imageTemp;
      selectedGalleryImg = _image;
      selectedFile = true;

      // //Test
      // print("\n \n \n ");
      // print("_Image Value: " + _image.toString() + "\n");
      // print(
      //     "selectedGalleryImg Value: " + selectedGalleryImg.toString() + "\n");
      // print("selectedFile Value: " + selectedFile.toString() + "\n");
      // print("\n \n \n ");
    });
  }

  Future selectFile() async {
    final selectedImgs = [];
    final selection =
        await FilePicker.platform.pickFiles(allowCompression: true);
    if (selection != null) {
      for (var element in selection.files) {
        selectedImgs.add(element.path);
      }
    }
  }

  //This is the area to get the text from the user
  Widget _entryPostField(
      String type, String title, TextEditingController controller, Size size) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    File stockFile;
    return Container(
      height: size.height * 0.5,
      width: size.width * 0.85,
      color: Color.fromARGB(0, 158, 158, 158),
      child: Column(
        children: [
          Padding(
              padding: EdgeInsets.all(3),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    FirebaseAuth.instance.currentUser?.photoURL as String),
                radius: size.width * 0.125,
              )),
          //Area for Image if not null
          if (selectedGalleryImg != null && selectedFile) ...[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              margin: EdgeInsets.all(10),
            )
          ],
          TextField(
              keyboardType: TextInputType.multiline,
              minLines: 1, //Normal textInputField will be displayed
              maxLines: 7,
              style: const TextStyle(color: Colors.white),
              controller: controller,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(0, 37, 32, 32),
                  hintText: title,
                  hintStyle: const TextStyle(color: Colors.white),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ))),
          Row(
            children: [
              IconButton(
                  color: Colors.white,
                  onPressed: _getImage,
                  icon: Icon(Icons.add_a_photo_rounded)),
              GestureDetector(
                onTap: _getImage,
                child: Text(
                  "Add A photo",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          GestureDetector(
            onTap: () {
              _postToFirebase();
            },
            child: Card(
              color: kPrimaryAccentColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(25.0),
              )),
              elevation: 4.0,
              child: Container(
                  width: size.width * 0.6,
                  height: size.height * 0.06,
                  child: Center(
                    child: Text("SAVE",
                        style: TextStyle(
                            color: Colors.white, fontSize: size.width * 0.05)),
                  )),
            ),
          )
        ],
      ),
    );
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
          if (_newPostTextController.text == "") {
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
    var now = new DateTime.now();
    var formatDate = new DateFormat('mm/dd/yyyy - kk:mm');
    String cleanDate = formatDate.format(now);
    await FirebaseFirestore.instance.collection("Posts").add({
      "Date": DateFormat.yMd(),
      "Img": "",
      "LikesNum": "0",
      "TimeStamp": "Thu JUN 8 7:08PM",
      "text": _newPostTextController.text,
      "type": "Standard",
      "userKey": currentUser?.uid,
      'date': cleanDate.toString(),
    }).whenComplete(() => {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          )
        });
  }

  //This is the display of how to upload an image
  //   Future _getImage() async {
  //   final image = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (image == null) return;

  //   final imageTemp = File(image.path);

  //   print("Image collected : " + imageTemp.toString());

  //   setState(() {
  //     _image = imageTemp;
  //     selectedGalleryImg = _image;
  //     selectedFile = true;
  //     assignProfilePhoto();
  //     //Test
  //     // print("\n \n \n ");
  //     // print("_Image Value: " + _image.toString() + "\n");
  //     // print(
  //     //     "selectedGalleryImg Value: " + selectedGalleryImg.toString() + "\n");
  //     // print("selectedFile Value: " + selectedFile.toString() + "\n");
  //     // print("\n \n \n ");
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //formats for all devices
    return Container(
      color: kBackgroundColor2,
      height: size.height,
      width: size.width,
      padding: const EdgeInsets.all(5),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height * 0.05,
            ),
            Card(
              elevation: 4.0,
              child: Container(
                  color: kBackgroundColor2,
                  width: size.width * 0.9,
                  height: size.height * 0.9,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.height * 0.005,
                      ),
                      Text(
                        errorMsg,
                        style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "New Post",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.005,
                      ),
                      _entryPostField("Standard", "Enter Text. . . ",
                          _newPostTextController, size),
                      SizedBox(
                        height: size.height * 0.05,
                      ),

                      // _saveButton()
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
