import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journey2/Tools/Crop.dart';
import 'package:journey2/auth.dart';
import 'package:journey2/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crop_your_image/crop_your_image.dart';

// ignore: must_be_immutable
class EditProfile extends StatefulWidget {
  //Values needed for page
  String username = Auth().currentUser!.displayName as String;
  String email = Auth().currentUser!.email as String;
  String bio = "";

  // String rune;

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  //Controllers
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  var bioController = TextEditingController();

  late String tempImage;
  var selectedProfileImg = "";
  File? _profileImg = null;
  File? _selectedGalleryImg;
  bool selectedImg = false;

  late String username;
  late String profileImg;

  //For cropping Image selected
  bool croppedImg = false;
  final _cropController = CropController();
  Uint8List? _croppedData;
  final _imageDataList = <Uint8List>[];

  var _isSumbnail = false;
  var _isCropping = false;
  var _isCircleUi = true;
  var _statusText = '';

  //  final ImagePicker _picker = ImagePicker();
  Future _getImage() async {
    print("_getImage Called I");
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final imageTemp = File(image.path);
    //Set State
    setState(() async {
      _profileImg = imageTemp;
      _selectedGalleryImg = _profileImg;
      selectedImg = true;
      _imageDataList.add(await _selectedGalleryImg!.readAsBytes());
      _cropController.image = await _selectedGalleryImg!.readAsBytes();
      //assignProfilePhoto();

      // print('_profileImg: $_profileImg');
    });
  }

  Future assignProfilePhoto() async {
    //Starting Variable
    Reference firebaseRef = FirebaseStorage.instance.ref();
    Reference firebaseUserRef = FirebaseStorage.instance.ref();
    String stockImgRef = "";
    final FirebaseAuth _auth = FirebaseAuth.instance;
    File stockFile;
    User? currentUser = _auth.currentUser;
    //Starting logic
    if (_selectedGalleryImg != null) {
      stockFile = _selectedGalleryImg!;
      firebaseUserRef = FirebaseStorage.instance
          .ref(Auth().currentUser!.uid)
          .child("ProfileImgs/${_selectedGalleryImg}");
    }

    if (_selectedGalleryImg != null && selectedImg) {
      await firebaseUserRef
          .putFile(File(_selectedGalleryImg!.path))
          .whenComplete(() => {print("Upload Complete")});

      firebaseUserRef
          .getDownloadURL()
          .then((urlV) => {
                print("Download URL obtained successfully : " + urlV),
                setState(() {
                  print("Setting the widget value of the CircleAvatar==> " +
                      urlV);
                  selectedProfileImg = urlV;
                })
              })
          .catchError((Error) => {print("Error getting download URL")});
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // username = prefs.getString("username")!;
      // profileImg = prefs.getString("profileImg")!;
      username = Auth().currentUser!.displayName.toString();
      profileImg = Auth().currentUser!.photoURL.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    // this.usernameController.text = widget.username.toString();
    // this.emailController.text = widget.email.toString();
    String errorTxt = "";
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        //resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          leadingWidth: size.width * 0.3,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Spacer()
                  ],
                ),
              ],
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: kBlueShade,
          title: Row(
            children: <Widget>[
              Spacer(),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0)),
                color: Colors.blueGrey[700],
                onPressed: () {
                  print("Updating");

                  if (usernameController.text == null ||
                      usernameController.text.length == 0 ||
                      usernameController.text == "") {
                    errorTxt = "Username cannot be empty";
                    return;
                  }
                  if (usernameController.text.length < 8) {
                    errorTxt = "Username cannot be less than 8 letters";
                    return;
                  }

                  if (selectedImg) {
                    Auth().currentUser?.updatePhotoURL(selectedProfileImg);
                  }

                  FirebaseFirestore.instance
                      .collection("Riders")
                      .doc(Auth().currentUser!.uid.toString())
                      .update({"Bio": bioController.text.toString()}).then(
                          (value) {
                    Navigator.pop(context);
                  });
                  //After post return to the main page
                },
                child: const Text(
                  "Update",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: kBackgroundColor,
            height: size.height,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: <Widget>[
                    const Spacer(),
                    if (selectedImg == false) ...[
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ImageCrop()));
                          },
                          child: _profileImg == null
                              ? CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage: NetworkImage(profileImg),
                                  radius: 50,
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage: FileImage(_profileImg!),
                                  radius: 50,
                                )),
                    ] else ...[
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ImageCrop()));
                          },
                          // onTap: _getImage,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(selectedProfileImg),
                            radius: 50,
                          ))
                    ],
                    const Spacer()
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                const Row(
                  children: <Widget>[
                    Spacer(),
                    Text(
                      "Change Profile Image",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 255, 204, 0)),
                    ),
                    Spacer()
                  ],
                ),
                const SizedBox(
                  height: 35,
                ),
                Text(
                  errorTxt,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 196, 8, 8),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        inputFormatters: [
                          //Set the max number of characters, this should give you five pages
                          LengthLimitingTextInputFormatter(30),
                        ],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter Username",
                          hintStyle: TextStyle(color: Colors.white),
                          //enabledBorder: InputBorder.none,
                          //focusedBorder: InputBorder.none,
                          //prefixIcon: Icon(Icons.search,color: Colors.grey.shade400,size: 20,),
                          filled: false,
                          fillColor: Colors.grey[850],
                          contentPadding: EdgeInsets.all(15),
                        ),
                        controller: usernameController,
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        inputFormatters: [
                          //Set the max number of characters, this should give you five pages
                          LengthLimitingTextInputFormatter(30),
                        ],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Update Bio. . .",
                          hintStyle: TextStyle(color: Colors.white),
                          //enabledBorder: InputBorder.none,
                          //focusedBorder: InputBorder.none,
                          //prefixIcon: Icon(Icons.search,color: Colors.grey.shade400,size: 20,),
                          filled: false,
                          fillColor: Colors.grey[850],
                          contentPadding: EdgeInsets.all(15),
                        ),
                        controller: bioController,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
