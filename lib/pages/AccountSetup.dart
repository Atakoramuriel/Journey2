import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:journey2/auth.dart';
import 'package:journey2/constants.dart';
import 'package:journey2/pages/home_page.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class AccountSetup extends StatefulWidget {
  AccountSetup({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;

  @override
  _AccountSetupState createState() => _AccountSetupState();
}

class _AccountSetupState extends State<AccountSetup> {
  final User? user = Auth().currentUser;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  //For motorcycle info
  final TextEditingController _motoMakeController = TextEditingController();
  final TextEditingController _motoModelController = TextEditingController();
  final TextEditingController _motoYearController = TextEditingController();
  final TextEditingController _motoColorController = TextEditingController();

  //For any time a skip is required
  bool skipAvailable = false;

  // String newUsername = "";
  var newUsername;
  var newProfilePhoto;
  var riderType;
  var gender;
  var location;
  var profileBio;
  var errorMsg = "";
  var selectedImg = "";
  File? selectedGalleryImg;
  bool selectedFile = false;

  List profileImageList = [
    "https://firebasestorage.googleapis.com/v0/b/ridealongdb-fe563.appspot.com/o/StockProfiles%2FA0.jpeg?alt=media&token=3c5a851e-ce0b-4a30-8da7-04df2dff25fa",
    "https://firebasestorage.googleapis.com/v0/b/ridealongdb-fe563.appspot.com/o/StockProfiles%2FA2.png?alt=media&token=6ebfd878-cd4a-402c-8bf6-a436f97c6423",
    "https://firebasestorage.googleapis.com/v0/b/ridealongdb-fe563.appspot.com/o/StockProfiles%2FA5.png?alt=media&token=4ec347f3-33b0-489c-9719-a40b2bec125e",
    "https://firebasestorage.googleapis.com/v0/b/ridealongdb-fe563.appspot.com/o/StockProfiles%2FA4.png?alt=media&token=0dbd5c0b-f049-4709-acca-71e96fbf8052",
    "https://firebasestorage.googleapis.com/v0/b/ridealongdb-fe563.appspot.com/o/StockProfiles%2FA6.png?alt=media&token=c29639db-c07f-42e1-a62e-04f24e6fa0b3",
    "https://firebasestorage.googleapis.com/v0/b/ridealongdb-fe563.appspot.com/o/StockProfiles%2FA7.png?alt=media&token=f27de077-7779-4a5e-9054-1bca80839bcc",
    "https://firebasestorage.googleapis.com/v0/b/ridealongdb-fe563.appspot.com/o/StockProfiles%2FA13.png?alt=media&token=b70dd361-df03-469d-8cb9-e8702a7afd44",
    "https://firebasestorage.googleapis.com/v0/b/ridealongdb-fe563.appspot.com/o/StockProfiles%2FA14.png?alt=media&token=356eb626-957b-493f-ad5b-5fe19de1a9da",
  ];
  int _focusedImageIndex = 0;

  var headers = [
    "Welcome to Ride Along",
    "Create a new username",
    "Select Profile Photo",
    "Tell Us About Yourself",
    "Now tell us about your Ride",
    "Review your profile"
  ];
  var pageindex = 0;
  File? _image;

  //For getting a single image for posting

  Future _getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final imageTemp = File(image.path);

    print("Image collected : " + imageTemp.toString());

    setState(() {
      _image = imageTemp;
      selectedGalleryImg = _image;
      selectedFile = true;
      assignProfilePhoto();
      //Test
      // print("\n \n \n ");
      // print("_Image Value: " + _image.toString() + "\n");
      // print(
      //     "selectedGalleryImg Value: " + selectedGalleryImg.toString() + "\n");
      // print("selectedFile Value: " + selectedFile.toString() + "\n");
      // print("\n \n \n ");
    });
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load(path);

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<bool> validateUserName(riderName) async {
    var userName = riderName.toString().toUpperCase();
    userName.trim();
    userName.split(" ").join("");
    print("Username for consideration: " + userName);
    var currentUser = Auth().currentUser;
    bool finalVerdict = false;
    await FirebaseFirestore.instance
        .collection("RiderNames")
        .doc(userName)
        .get()
        .then((userData) {
      if (userData.exists) {
        //Can't use username
        finalVerdict = false;
        print("UserName is Taken");

        setState(() {
          errorMsg = "Username is Taken...";
        });
      } else {
        //All good to go
        finalVerdict = true;
        print("UserName is Available");
        setState(() {
          errorMsg = "";
        });
      }
    });

    //Before returning the verdict you have to write the username to the database you know
    await FirebaseFirestore.instance
        .collection("RiderNames")
        .doc(userName)
        .set({'username': userName});

    return finalVerdict;
  }

  Future assignProfilePhoto() async {
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
          .child("userProfileImage");
    } else {
      switch (_focusedImageIndex) {
        case 0:
          // firebaseRef =
          //     FirebaseStorage.instance.ref("StockProfiles").child("A0.jpeg");

          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A0.jpeg");
          break;
        case 1:
          // firebaseRef =
          //     FirebaseStorage.instance.ref("StockProfiles").child("A2.png");
          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A2.png");
          break;
        case 2:
          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A3.png");
          break;
        case 3:
          // firebaseRef =
          //     FirebaseStorage.instance.ref("StockProfiles").child("A4.png");
          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A4.png");
          break;
        case 4:
          // firebaseRef =
          //     FirebaseStorage.instance.ref("StockProfiles").child("A5.png");
          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A5.png");
          break;
        case 5:
          // firebaseRef =
          //     FirebaseStorage.instance.ref("StockProfiles").child("A6.png");
          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A6.png");
          break;
        case 6:
          // firebaseRef =
          //     FirebaseStorage.instance.ref("StockProfiles").child("A7.png");
          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A7.png");
          break;
        case 7:
          // firebaseRef =
          //     FirebaseStorage.instance.ref("StockProfiles").child("A8.png");
          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A8.png");
          break;
        case 8:
          // firebaseRef =
          //     FirebaseStorage.instance.ref("StockProfiles").child("A9.png");
          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A9.png");
          break;
        case 9:
          // firebaseRef =
          //     FirebaseStorage.instance.ref("StockProfiles").child("A10.png");
          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A10.png");
          break;
        case 10:
          // firebaseRef =
          //     FirebaseStorage.instance.ref("StockProfiles").child("A11.png");
          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A11.png");
          break;
        case 11:
          // firebaseRef =
          //     FirebaseStorage.instance.ref("StockProfiles").child("A12.png");
          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A12.png");
          break;
        case 12:
          // firebaseRef =
          //     FirebaseStorage.instance.ref("StockProfiles").child("A13.png");
          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A13.png");
          break;
        case 13:
          // firebaseRef =
          //     FirebaseStorage.instance.ref("StockProfiles").child("A14.png");
          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A14.png");
          break;
        default:
          // firebaseRef =
          //     FirebaseStorage.instance.ref("StockProfiles").child("A0.jpeg");
          stockFile =
              await getImageFileFromAssets("assets/ProfileIcons/A0.png");
      }

      firebaseRef = FirebaseStorage.instance
          .ref(Auth().currentUser!.uid)
          .child("ProfileImg");

      firebaseRef.putFile(stockFile);

      firebaseRef.getDownloadURL().then((value) {
        print("Collected Image " + value);
        stockImgRef = value;
        // print("Stock Image Collected : " + stockImgRef);
        //Updating the user url
        currentUser
            ?.updatePhotoURL(value)
            .then((value) => {print("User profile Image updated!")})
            .catchError((error) =>
                {print("Error setting user profile image: " + error)});
      }).catchError((err) => {print("Error: " + err)});

      firebaseUserRef = FirebaseStorage.instance
          .ref(Auth().currentUser!.uid)
          .child("ProfileImg");
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

  Future _getImage2() async {
    final ImagePicker _picker = ImagePicker();

    final _storage = FirebaseStorage.instance;
    // final _picker = ImagePicker;
    var image;

    //Check Permissions
    await Permission.photos.request(); //prompt to get permissions

    var permissionStatus =
        await Permission.photos.status; //Get result of prompt

    if (permissionStatus.isGranted) {
      //All good to go

      // image = await ImagePicker.pickImage(source: ImageSource.gallery);
      var file = File(image.path);

      if (image != null) {
        //Upload to firebase
      } else {
        print("No Image");
      }
    } else {
      //Permissions not granted for image selection
      print("Image Not Granted");
    }

    // var imagePicked = await ImagePicker.pickImage(source: ImageSource.gallery);

    //Add image to firebase storage

    //Set State
    setState(() {
      _image = image;
      print('_image: $_image');
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

  //Some functions
  Future<void> signOut() async {
    await Auth().signOut();
  }

  //Set up structure
  Widget _title() {
    return Text(
      headers[pageindex],
      style: const TextStyle(
          color: kPrimaryAccentColor,
          fontWeight: FontWeight.bold,
          fontSize: 26),
    );
  }

  Widget _riderSelection(RiderType, RiderDesc, Color, RiderImage) {
    return Container(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
        height: 220,
        width: double.maxFinite,
        child: Card(
            color: Color,
            elevation: 5,
            child: Stack(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    // Image(
                    //   image: AssetImage(RiderImage),
                    // )
                    Image.network(RiderImage)
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          RiderType,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 35),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Spacer(),
                    Text(
                      RiderDesc,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    const SizedBox(
                      height: 45,
                    )
                  ],
                ),
              ],
            )));
  }

  //Set up structure
  Widget _subTitle() {
    return const Text(
      "Let's Create your account",
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
    );
  }

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

  Widget _entryTextField(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
        minLines:
            6, // any number you need (It works as the rows for the textarea)
        keyboardType: TextInputType.multiline,
        maxLines: null,
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

  void _onItemFocus(int index) {
    setState(() {
      _focusedImageIndex = index;
    });
  }

  void _routePage(int index) {
    setState(() {
      pageindex = index;
    });
  }

  Widget _buildItemList(BuildContext context, int index) {
    if (index == profileImageList.length) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: GestureDetector(
            onTap: () {
              setState(() {
                selectedFile = false;
                selectedImg = profileImageList[index];
                _focusedImageIndex = index;
              });
            },
            child: CircleAvatar(
              // child: Image.network(profileImageList[index]),
              backgroundImage: NetworkImage(profileImageList[index]),
              // backgroundImage: Image.network(profileImageList[index]),
              // backgroundImage: Image(image: Image.network(profileImageList[index])),
              radius: 65,
            ),
          )),
        ],
      ),
    );
  }

  Widget _nextButton() {
    var txtValue = "Next";
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 25),
          padding: const EdgeInsets.fromLTRB(145, 10, 145, 10),
          backgroundColor: kPrimaryAccentColor),
      onPressed: () async {
        Future<bool> pushForward;
        switch (pageindex) {
          case 0:
            setState(() {
              pageindex++;
            });
            break;
          case 1:
            print("Testing Username");
            if (_usernameController.text == "") {
              print("Null Username Found");
              setState(() {
                errorMsg = "Fill out username...";
              });
            } else {
              // print("UserName " + _usernameController.text);
              pushForward = validateUserName(_usernameController.text);
              if (await pushForward) {
                setState(() {
                  print(pageindex);
                  pageindex++;
                });
              }
            }

            break;
          case 2:
            if (selectedImg != null || selectedGalleryImg != null) {
              assignProfilePhoto();
            }
            setState(() {
              print(pageindex);
              pageindex++;
            });
            break;
          case 3:
            setState(() {
              // print(pageindex);
              // print("Changing Value of Next Button");
              // txtValue = "Skip";
              skipAvailable = true;
              pageindex++;
            });
            break;
          default:
        }
      },
      child: Text(txtValue),
    );
  }

  Widget _skipButton() {
    var txtValue = "Skip";
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 25),
          padding: const EdgeInsets.fromLTRB(145, 10, 145, 10),
          side: const BorderSide(color: kPrimaryAccentColor, width: 3.0),
          backgroundColor: kPrimaryAccentColor),
      onPressed: () async {
        setState(() {
          pageindex++;
        });
      },
      child: Text(txtValue),
    );
  }

  Widget _saveButton() {
    var txtValue = "Save";
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 25),
          padding: const EdgeInsets.fromLTRB(145, 10, 145, 10),
          backgroundColor: Colors.red[800]),
      onPressed: () async {
        setState(() {
          if (_motoColorController.text == "" ||
              _motoMakeController.text == "" ||
              _motoModelController.text == "" ||
              _motoYearController.text == "") {
            errorMsg = "Must Fill out all fields to save";
          } else {
            pageindex++;
          }
        });
      },
      child: Text(txtValue),
    );
  }

  void _profileComplete() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Future<void> _createUserProfile() async {
    var currentUser = Auth().currentUser;

    bool finalVerdict = false;
    //Update the User INfo
    await FirebaseAuth.instance.currentUser
        ?.updateDisplayName(_usernameController.text)
        .whenComplete(() => {print("Username updated")});

    //Update the DB
    await FirebaseFirestore.instance
        .collection("Riders")
        .doc(currentUser?.uid)
        .set({
      "userKey": currentUser?.uid,
      "userName": _usernameController.text,
      "profileImg": selectedImg,
      "Bio": _bioController.text,
    }).whenComplete(() => {
              //You need to add the bike to collections
              FirebaseFirestore.instance
                  .collection("Riders")
                  .doc(currentUser?.uid)
                  .collection("Motorcycles")
                  .add({
                "Make": _motoMakeController.text,
                "Model": _motoModelController.text,
                "Year": _motoYearController.text,
                "Color": _motoColorController.text
              }).whenComplete(() => {_profileComplete()})
            });
  }

  Widget _FinishButton() {
    var txtValue = "Finish";
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 25),
          padding: const EdgeInsets.fromLTRB(145, 10, 145, 10),
          backgroundColor: Colors.red[800]),
      onPressed: () async {
        setState(() {
          _createUserProfile();
        });
      },
      child: Text(txtValue),
    );
  }

  Widget _addBikeButton() {
    var txtValue = "add Motorcycle";
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 25),
          padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
          side: const BorderSide(color: kPrimaryAccentColor, width: 3.0),
          backgroundColor: Colors.transparent),
      onPressed: () async {
        setState(() {
          pageindex = 4;
        });
      },
      child: Text(txtValue),
    );
  }

  Widget _prevButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 25),
          padding: const EdgeInsets.fromLTRB(120, 10, 120, 10),
          side: const BorderSide(color: kPrimaryAccentColor, width: 3.0),
          backgroundColor: Colors.transparent),
      onPressed: () {
        setState(() {
          pageindex--;
        });
      },
      child: const Text('Previous'),
    );
  }

  Widget _setupScreen() {
    return Text(user?.displayName ?? "Let's set up your account");
  }

  Widget _signOutBtn() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  @override
  Widget build(BuildContext context) {
    //starting variables
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: kBackgroundColor,
        body: Container(
            height: size.height,
            width: size.width,
            padding: const EdgeInsets.all(0),
            child: Stack(
              children: [
                SafeArea(
                    child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(
                        flex: 1,
                      ),
                      _title(),

                      const Spacer(
                        flex: 1,
                      ),

                      //A Mess to be cleaned later

                      //Starting with subtitle
                      if (pageindex == 0) ...[
                        _subTitle(),
                        Text(
                          errorMsg,
                          style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold),
                        ),
                      ],

                      //Start with getting username
                      if (pageindex == 1) ...[
                        Text(
                          errorMsg,
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: kDefaultPadding),
                          child:
                              _entryField('Username. . .', _usernameController),
                        )
                      ],

                      //Continue with getting photoURL or image upload
                      if (pageindex == 2) ...[
                        if (selectedImg != "" && !selectedFile) ...[
                          CircleAvatar(
                            radius: 55,
                            backgroundImage: NetworkImage(selectedImg),
                          ),
                        ],
                        if (selectedGalleryImg != null && selectedFile) ...[
                          CircleAvatar(
                            radius: 55,
                            backgroundImage: FileImage(selectedGalleryImg!),
                          )
                        ],
                        const SizedBox(height: 15),
                        Expanded(
                            flex: 4,
                            child: ScrollSnapList(
                              itemBuilder: _buildItemList,
                              itemSize: 475,
                              allowAnotherDirection: true,
                              dynamicItemSize: false,
                              onItemFocus: _onItemFocus,
                              onReachEnd: () {},
                              itemCount: profileImageList.length,
                            )),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          " -- or --",
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          "Upload your own profile Photo",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: _getImage,
                              child: RichText(
                                text: const TextSpan(
                                  children: [
                                    WidgetSpan(
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " Select Image to upload",
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      ],

                      //Tell us about yourself
                      if (pageindex == 3) ...[
                        Text(
                          errorMsg,
                          style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                            height: size.height * 0.5,
                            padding: const EdgeInsets.all(3.0),
                            child: SingleChildScrollView(
                                child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _getImage,
                                  child: CircleAvatar(
                                    radius: 75,
                                    backgroundImage: NetworkImage(selectedImg),
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 0.03,
                                ),
                                _entryField(
                                    'Username. . .', _usernameController),
                                const SizedBox(
                                  height: 45,
                                ),
                                _entryTextField(
                                    'Profile Bio...', _bioController),
                              ],
                            )))
                      ],

                      //For the bike make and model
                      if (pageindex == 4) ...[
                        //Get Make
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(children: [
                            Text(
                              errorMsg,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            _entryField("Make...", _motoMakeController),
                            const SizedBox(
                              height: 30,
                            ),
                            //Get Model
                            _entryField("Model...", _motoModelController),

                            const SizedBox(
                              height: 30,
                            ),
                            //Get Color
                            _entryField("Color...", _motoColorController),
                            const SizedBox(
                              height: 30,
                            ),
                            //Get Year
                            _entryField("Year...", _motoYearController),

                            const SizedBox(
                              height: 30,
                            ),
                            _saveButton(),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              "-- Or --",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              "Skip if you don't have one",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            _skipButton()
                          ]),
                        )
                      ],

                      //For the final review
                      if (pageindex == 5) ...[
                        Container(
                          height: 600,
                          padding: const EdgeInsets.all(10.0),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _getImage,
                                  child: CircleAvatar(
                                    radius: 75,
                                    backgroundImage: NetworkImage(selectedImg),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),

                                //Username
                                GestureDetector(
                                    onTap: () => {_routePage(1)},
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          _usernameController.text,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25),
                                        ),
                                      ],
                                    )),
                                const SizedBox(
                                  height: 20,
                                ),
                                _entryTextField(
                                    'Profile Bio...', _bioController),
                                const SizedBox(
                                  height: 40,
                                ),
                                if (_motoMakeController.text == "") ...[
                                  const Text(
                                    "No Motorcycle Information Entered",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  _addBikeButton(),
                                ],

                                //Include Bike information if the user provided
                                if (_motoMakeController.text != "") ...[
                                  const SizedBox(
                                    height: 45,
                                  ),
                                  const Text(
                                    "Motorcycle Information",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  _entryField("Make...", _motoMakeController),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _entryField("Model...", _motoModelController),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _entryField("Color...", _motoColorController),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _entryField("Year...", _motoYearController),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],

                      const Spacer(
                        flex: 2,
                      ),
                      if (pageindex != 4 && pageindex != 5) ...[
                        _nextButton(),
                      ],

                      if (pageindex == 5) ...[_FinishButton()],

                      if (pageindex >= 2 && pageindex != 4) ...[
                        const SizedBox(
                          height: 25,
                        ),
                        _prevButton()
                      ],

                      if (pageindex == 4) ...[_prevButton()],

                      const Spacer(
                        flex: 2,
                      )
                    ],
                  ),
                ))
              ],
            )));
  }
}
