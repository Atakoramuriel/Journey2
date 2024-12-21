import 'package:cloud_firestore/cloud_firestore.dart'; //This is the push and pull
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journey2/auth.dart';
import 'package:journey2/constants.dart';
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
    var now = DateTime.now();
    var formatDate = DateFormat('mm/dd/yyyy - kk:mm');
    String cleanDate = formatDate.format(now);
    await FirebaseFirestore.instance.collection("Posts").add({
      "userKey": currentUser?.uid,
      "text": _newPostTextController.text,
      'date': cleanDate.toString(),
      "TimeStamp": "Thu JUN 8 7:08PM"
    }).whenComplete(() => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          )
        );
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
              height: size.height * 0.1,
            ),
            Card(
              elevation: 4.0,
              child: Container(
                  color: kBackgroundColor2,
                  width: size.width * 0.9,
                  height: size.height * 0.9,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.height * 0.05,
                      ),
                      Text(
                        errorMsg,
                        style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "New Post to Ride Along",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.05,
                      ),
                      _entryField("Enter Text. . . ", _newPostTextController),
                      SizedBox(
                        height: size.height * 0.05,
                      ),
                      GestureDetector(
                        onTap: () {
                          _postToFirebase();
                        },
                        child: Card(
                          elevation: 4.0,
                          child: Container(
                              color: kPrimaryAccentColor,
                              width: size.width * 0.9,
                              height: size.height * 0.08,
                              child: Center(
                                child: Text("SAVE",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: size.width * 0.08)),
                              )),
                        ),
                      )

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
