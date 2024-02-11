import 'dart:ui';

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

  //Motorcycle Makes
  List<String> motorcycleMakes = [
    'Select Make...',
    'Honda',
    'Yamaha',
    'Kawasaki',
    'Suzuki',
    'Ducati',
    'Harley-Davidson',
    'BMW',
    'Triumph',
    'KTM',
    'Aprilia',
    'MV Agusta',
    'Indian',
    'Victory',
    'Moto Guzzi',
    'Husqvarna',
    'Buell',
    'Piaggio',
    'Royal Enfield',
    'Can-Am',
    'Zero',
    'Hyosung',
    'Benelli',
    'Kymco',
    'Bajaj',
    'SYM',
    'Daelim',
    'Lambretta',
    'GAS GAS',
    'Keeway',
    'Vespa',
    'Derbi',
    'SWM',
    'Oset',
    'Energica',
    'Ural',
    'Cagiva',
    'Moto Morini',
    'Hesketh',
    'CZ',
    'Norton',
    'Fantic',
    'Rieju',
    'Zontes',
    'Mondial',
    'AJP',
    'Skyteam',
    'Bimota',
    'Mash',
    'Horex',
    'Patronus',
    'Other...'
  ];

  //Motorcycle Colors
  List<String> motorcycleColors = [
    'Select Color...',
    'Black',
    'White',
    'Red',
    'Blue',
    'Silver',
    'Yellow',
    'Green',
    'Orange',
    'Gray',
    'Purple',
    'Gold',
    'Brown',
    'Burgundy',
    'Pink',
    'Turquoise',
    'Beige',
    'Bronze',
    'Teal',
    'Olive',
    'Copper',
    'Lime',
    'Magenta',
    'Indigo',
    'Charcoal',
    'Navy',
  ];

  //Motorcycle Years
  List<String> past100Years = [
    'Select Year...',
    '2025',
    '2024',
    '2023',
    '2022',
    '2021',
    '2020',
    '2019',
    '2018',
    '2017',
    '2016',
    '2015',
    '2014',
    '2013',
    '2012',
    '2011',
    '2010',
    '2009',
    '2008',
    '2007',
    '2006',
    '2005',
    '2004',
    '2003',
    '2002',
    '2001',
    '2000',
    '1999',
    '1998',
    '1997',
    '1996',
    '1995',
    '1994',
    '1993',
    '1992',
    '1991',
    '1990',
    '1989',
    '1988',
    '1987',
    '1986',
    '1985',
    '1984',
    '1983',
    '1982',
    '1981',
    '1980',
    '1979',
    '1978',
    '1977',
    '1976',
    '1975',
    '1974',
    '1973',
    '1972',
    '1971',
    '1970',
    '1969',
    '1968',
    '1967',
    '1966',
    '1965',
    '1964',
    '1963',
    '1962',
    '1961',
    '1960',
    '1959',
    '1958',
    '1957',
    '1956',
    '1955',
    '1954',
    '1953',
    '1952',
    '1951',
    '1950',
    '1949',
    '1948',
    '1947',
    '1946',
    '1945',
    '1944',
    '1943',
    '1942',
    '1941',
    '1940',
    '1939',
    '1938',
    '1937',
    '1936',
    '1935',
    '1934',
    '1933',
    '1932',
    '1931',
    '1930',
    '1929',
    '1928',
    '1927',
    '1926',
    '1925',
    '1924',
    '1923',
    '1922',
    '1921',
    '1920',
  ];

  //Models
  List<String> hondaModels = [
    'CBR1000RR',
    'CBR600RR',
    'CRF250L',
    'CRF450R',
    'Africa Twin',
    'Rebel 500',
    'CB500F',
    'CB650R',
    'Gold Wing',
    'NC750X',
    'CBR650R',
    'CB300R',
    'CB1000R',
    'CRF300L',
    'CB125R',
    'Forza 350',
    'PCX160',
    'X-ADV',
    'SH150i',
    'CB500X',
    'CRF1100L Africa Twin',
    'CRF250R',
    'Monkey',
    'Super Cub C125',
    'MSX125 Grom',
  ];

  List<String> yamahaModels = [
    'YZF-R1',
    'YZF-R6',
    'MT-07',
    'MT-09',
    'MT-03',
    'MT-10',
    'YZF-R3',
    'YZF-R15',
    'XSR900',
    'XSR700',
    'Tracer 900 GT',
    'Tracer 700',
    'Tenere 700',
    'YZF-R125',
    'MT-125',
    'MT-25',
    'YZ450F',
    'YZ250F',
    'Niken',
    'FJR1300',
    'XTZ 700 Tenere',
    'XT660Z Tenere',
    'VMAX',
    'XMAX 300',
    'TMAX',
  ];

  List<String> kawasakiModels = [
    'Ninja ZX-10R',
    'Ninja 650',
    'Z900',
    'Versys 650',
    'Z650',
    'Z400',
    'Ninja 400',
    'Vulcan S',
    'Ninja H2',
    'Z1000',
    'Versys 1000',
    'Z125',
    'Ninja 1000SX',
    'Ninja H2 SX',
    'Ninja ZX-6R',
    'KLX230',
    'KLX300R',
    'Z H2',
    'Z900RS',
    'KX450',
    'Z650 Performance',
    'Ninja 650 KRT',
    'Z400 Performance',
    'Ninja 400 KRT',
    'Z H2 SE',
  ];

  List<String> suzukiModels = [
    'GSX-R1000',
    'GSX-R750',
    'GSX-S750',
    'GSX-R600',
    'GSX-S1000',
    'V-Strom 650',
    'Hayabusa',
    'SV650',
    'V-Strom 1050',
    'Burgman 400',
    'GSX250R',
    'GSX-S750Z',
    'V-Strom 250',
    'SV650X',
    'RM-Z450',
    'RM-Z250',
    'DR650S',
    'DR-Z400S',
    'DR200S',
    'GSX-S1000F',
    'RM85',
    'SV650 ABS',
    'Boulevard M50',
    'Boulevard M109R',
    'V-Strom 1050XT',
  ];

  List<String> ducatiModels = [
    'Panigale V4',
    'Panigale V2',
    'Monster',
    'Scrambler',
    'Streetfighter V4',
    'Diavel',
    'Multistrada V4',
    'SuperSport',
    'Hypermotard',
    'Supersport 950',
    'Monster 797',
    'Scrambler 1100',
    'Monster 821',
    'Multistrada 950',
    'Scrambler Desert Sled',
    'Panigale V4 R',
    'XDiavel',
    'Panigale V4 S',
    'Diavel 1260',
    'Scrambler Sixty2',
    'Hypermotard 950',
    'Scrambler Cafe Racer',
    'Panigale V4 SP',
    'Monster 1200',
    'Monster 937',
  ];

  List<String> harleyDavidsonModels = [
    'Street Glide',
    'Road Glide',
    'Road King',
    'Fat Boy',
    'Iron 883',
    'Forty-Eight',
    'Sportster',
    'Softail',
    'Fat Bob',
    'Low Rider',
    'Street Bob',
    'Heritage Classic',
    'Roadster',
    'Breakout',
    'Electra Glide',
    'CVO',
    'SuperLow',
    'Tri Glide',
    'Screamin\' Eagle',
    'Ultra Limited',
    'Freewheeler',
    'Street Rod',
    'Deluxe',
    'Street 750',
    'Livewire',
  ];

  List<String> bmwModels = [
    'S1000RR',
    'R1250GS',
    'F850GS',
    'R nineT',
    'K1600GTL',
    'G310R',
    'S1000XR',
    'R1250RT',
    'F750GS',
    'F900R',
    'R18',
    'R1200GS',
    'F800GS',
    'S1000R',
    'G310GS',
    'R1250RS',
    'F850R',
    'K1600B',
    'S1000XR',
    'R1250R',
    'F900XR',
    'C400X',
    'R1250GS Adventure',
    'R nineT Scrambler',
    'K1600 Grand America',
  ];

  List<String> triumphModels = [
    'Street Triple',
    'Tiger 800',
    'Bonneville T120',
    'Tiger 1200',
    'Speed Triple',
    'Rocket 3',
    'Thruxton',
    'Scrambler 1200',
    'Speed Twin',
    'Tiger 900',
    'Street Twin',
    'Bonneville Bobber',
    'Daytona Moto2 765',
    'Tiger 850 Sport',
    'Bonneville T100',
    'Scrambler 900',
    'Tiger 1200 Alpine Edition',
    'Street Scrambler',
    'Tiger Sport',
    'Bonneville Speedmaster',
    'Tiger 1200 Desert Edition',
    'Thruxton RS',
    'Bonneville Street Twin',
    'Tiger 1200 GT',
    'Rocket 3 GT',
  ];

  List<String> ktmModels = [
    'Duke 390',
    'RC 390',
    'Adventure 390',
    'Duke 200',
    'Adventure 250',
    'RC 200',
    'Duke 125',
    'Adventure 790',
    'Super Adventure 1290',
    'Duke 690',
    'Adventure 690',
    'RC 125',
    'Super Duke R',
    'Adventure 1090',
    'Super Adventure S',
    'Duke 790',
    'RC 250',
    'Duke 890',
    'Adventure 1290',
    'Freeride 250 F',
    'SX 85',
    'EXC 350 F',
    'XC-W 300',
    'Enduro 690',
    'Freeride E-XC',
  ];

  List<String> apriliaModels = [
    'RS 125',
    'RSV4',
    'Tuono V4',
    'Dorsoduro',
    'RS 660',
    'Shiver',
    'Tuono 125',
    'SR 125',
    'RS 50',
    'Tuono 660',
    'Tuono V4 Factory',
    'RSV4 Factory',
    'RSV4 RR',
    'RSV4 RF',
    'Tuono V4 X',
    'SR 160',
    'RS 660 Factory',
    'RS 660 Trofeo',
    'RS 660 Ténéré',
    'RS 660 R',
    'RSV4 R FW-GP',
    'Tuono 660 Factory',
    'RSV4 X',
    'RSV4 R FW',
    'Tuono V4 1100 Factory',
  ];

  List<String> mvAgustaModels = [
    'Brutale 800',
    'F3 800',
    'Dragster 800',
    'F4',
    'Brutale 1000',
    'F3 675',
    'Turismo Veloce',
    'Dragster 800 RR',
    'F4 RR',
    'Brutale 800 RR',
    'Superveloce 800',
    'F3 800 RC',
    'Brutale 800 RC',
    'Dragster 800 RC',
    'F4 RC',
    'F3 675 RC',
    'Brutale 1000 RR',
    'Dragster 800 RR SCS',
    'Brutale 800 RR SCS',
    'Turismo Veloce Lusso',
    'F4 RC',
    'F3 800 RC',
    'Dragster 800 RC',
    'Brutale 800 RC',
    'Superveloce 800 Serie Oro',
  ];

  List<String> indianModels = [
    'Chief',
    'Scout',
    'Chieftain',
    'Springfield',
    'Roadmaster',
    'FTR',
    'Scout Bobber',
    'Chieftain Dark Horse',
    'Challenger',
    'Chief Dark Horse',
    'Vintage',
    'FTR Rally',
    'Chieftain Elite',
    'Chief Bobber Dark Horse',
    'Springfield Dark Horse',
    'Scout Bobber Twenty',
    'FTR Carbon',
    'Chieftain Limited',
    'Scout Bobber Sixty',
    'Chieftain Classic',
    'Roadmaster Dark Horse',
    'Scout 100th Anniversary',
    'Challenger Dark Horse',
    'Chief Vintage Dark Horse',
    'Chief Bobber 100th Anniversary',
  ];

  List<String> victoryModels = [
    'Cross Country',
    'Cross Country Tour',
    'Octane',
    'Gunner',
    'Magnum',
    'High-Ball',
    'Vegas',
    'Vision',
    'Hammer',
    'Kingpin',
    'Boardwalk',
    'Judge',
    'Cross Roads',
    'Zach Ness Vegas',
    'Cross Country 8-Ball',
    'Vegas 8-Ball',
    'Cory Ness Cross Country',
    'Cory Ness Magnum',
    'V92C',
    'Ness Magnum',
    'Jackpot',
    'Ness Cross Country',
    'Vegas Jackpot',
    'Arlen Ness Vision',
    'Ness Vegas',
  ];

  List<String> motoGuzziModels = [
    'V7',
    'V85 TT',
    'V9',
    'V85 TT Travel',
    'V7 III',
    'V7 Stone',
    'V7 III Racer',
    'V7 III Special',
    'V7 III Rough',
    'V7 III Milano',
    'V7 III Carbon',
    'V85 TT Adventure',
    'V7 III Limited',
    'V7 III Anniversario',
    'V7 III Stone',
    'V7 III Stone Night Pack',
    'V7 III Stone S',
    'V7 III Racer Limited',
    'V7 III Rough Night Pack',
    'V7 III Special Night Pack',
    'V7 III Milano Night Pack',
    'V7 III Carbon Dark',
    'V9 Bobber',
    'V9 Roamer',
    'V9 Roamer Night Pack',
  ];

  List<String> husqvarnaModels = [
    'Svartpilen 401',
    'Vitpilen 401',
    'Svartpilen 250',
    'Vitpilen 250',
    'Svartpilen 125',
    'Vitpilen 125',
    '701 Enduro',
    '701 Supermoto',
    '701 Enduro LR',
    'FC 450',
    'FE 450',
    'TE 300i',
    'FE 250',
    'FE 501',
    'FC 250',
    'TC 250',
    'FS 450',
    'FX 450',
    'TC 125',
    'TE 150i',
    'FC 350',
    'FE 350',
    'TE 250i',
    'FE 501s',
    'TC 85',
  ];

  List<String> buellModels = [
    'XB12R Firebolt',
    'XB9R Firebolt',
    'XB12S Lightning',
    '1125R',
    '1125CR',
    'XB12X Ulysses',
    'XB9SX Lightning CityX',
    'XB9S Lightning',
    '1125RR',
    'RS1200 Westwind',
    'RS1200S Westwind',
    'XB12XT Ulysses',
    'RR1000 Battletwin',
    'RR1200 Battletwin',
    'XB12STT Ulysses',
    'XB12XP Ulysses Police',
    'XB9TT Lightning',
    'RS1200S Battletwin',
    'RR1200 Battletwin Race',
    'RS1200S Corsa',
    'S3 Thunderbolt',
    'S3T Thunderbolt',
    'RR1200 Battletwin Road',
    'M2 Cyclone',
    'X1 Lightning',
  ];

  String? selectedMake = 'Select Make...';
  String? selectedModel = "Select Model...";
  String? selectedColor = "Select Color...";
  String? selectedYear = "Select Year...";

  final TextEditingController textEditingController = TextEditingController();

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

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
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
          padding: const EdgeInsets.fromLTRB(130, 10, 130, 10),
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
          padding: const EdgeInsets.fromLTRB(130, 10, 130, 10),
          backgroundColor: Colors.purple[800]),
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

  Future<void> updateProfileImg() async {
    var userID = FirebaseAuth.instance.currentUser?.uid; //Get the userid first

    await FirebaseFirestore.instance
        .collection("Riders")
        .doc(userID)
        .get()
        .then((value) {
      if (value.exists) {
        print("Value Found" + value.data()!['profileImg'].toString());

        FirebaseAuth.instance.currentUser
            ?.updatePhotoURL(value.data()!['profileImg'].toString())
            .then((value) => {print("Updated Profile")});
      } else {}
    });
  }

  Future<void> _createUserProfile() async {
    var currentUser = Auth().currentUser;

    bool finalVerdict = false;
    //Update the User INfo
    await FirebaseAuth.instance.currentUser
        ?.updateDisplayName(_usernameController.text)
        .whenComplete(() => print("Username updated"));

    //Update the DB
    await FirebaseFirestore.instance
        .collection("Riders")
        .doc(currentUser?.uid)
        .set({
      "userKey": currentUser?.uid,
      "userName": _usernameController.text,
      "profileImg": selectedImg,
      "Bio": _bioController.text,
    }).whenComplete(() => FirebaseFirestore.instance
                  .collection("Riders")
                  .doc(currentUser?.uid)
                  .collection("Motorcycles")
                  .add({
                "Make": _motoMakeController.text,
                "Model": _motoModelController.text,
                "Year": _motoYearController.text,
                "Color": _motoColorController.text
              }).whenComplete(() => _profileComplete())
            );
  }

  Widget _FinishButton() {
    var txtValue = "Finish";
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 25),
          padding: const EdgeInsets.fromLTRB(110, 10, 110, 10),
          backgroundColor: Colors.red[800]),
      onPressed: () async {
        updateProfileImg();
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

  //Hold
  // decoration: BoxDecoration(
  //   image: DecorationImage(
  //     image: AssetImage("assets/images/AzerPromo.png"),
  //     fit: BoxFit.cover,
  //   ),
  // ),

  @override
  Widget build(BuildContext context) {
    //starting variables
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: kBackgroundColor,
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: Stack(
            children: [
              Container(
                height: size.height,
                width: size.width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/AzerPromo.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    decoration:
                        BoxDecoration(color: Colors.white.withOpacity(0.0)),
                  ),
                ),
              ),
              Container(
                  height: size.height,
                  width: size.width,
                  padding: const EdgeInsets.all(0),
                  child: Stack(
                    children: [
                      SafeArea(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: kDefaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(
                              flex: 1,
                            ),

                            const Spacer(
                              flex: 1,
                            ),

                            //A Mess to be cleaned later

                            //Starting with subtitle
                            if (pageindex == 0) ...[
                              SizedBox(
                                height: size.height * 0.3,
                              ),
                              _title(),
                              const SizedBox(
                                height: 25,
                              ),
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
                              SizedBox(
                                height: size.height * 0.3,
                              ),
                              _title(),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                errorMsg,
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: kDefaultPadding),
                                child: _entryField(
                                    'Username. . .', _usernameController),
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
                              if (selectedGalleryImg != null &&
                                  selectedFile) ...[
                                CircleAvatar(
                                  radius: 55,
                                  backgroundImage:
                                      FileImage(selectedGalleryImg!),
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                          backgroundImage:
                                              NetworkImage(selectedImg),
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
                                  DropdownButton<String>(
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                    dropdownColor:
                                        const Color.fromARGB(255, 58, 19, 16),
                                    focusColor: Colors.red,
                                    isExpanded: true,
                                    value: selectedMake,
                                    onChanged: (String? val) {
                                      setState(() {
                                        selectedMake = val;
                                      });
                                    },
                                    items: motorcycleMakes.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  //Get Model
                                  _entryField("Model...", _motoModelController),

                                  const SizedBox(
                                    height: 30,
                                  ),
                                  //Get Color
                                  DropdownButton<String>(
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                    dropdownColor:
                                        const Color.fromARGB(255, 58, 19, 16),
                                    focusColor: Colors.red,
                                    isExpanded: true,
                                    value: selectedColor,
                                    onChanged: (String? val) {
                                      setState(() {
                                        selectedColor = val;
                                      });
                                    },
                                    items: motorcycleColors.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  //Get Year
                                  DropdownButton<String>(
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                    dropdownColor:
                                        const Color.fromARGB(255, 58, 19, 16),
                                    focusColor: Colors.red,
                                    isExpanded: true,
                                    value: selectedYear,
                                    onChanged: (String? val) {
                                      setState(() {
                                        selectedYear = val;
                                      });
                                    },
                                    items: past100Years.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),

                                  const SizedBox(
                                    height: 30,
                                  ),
                                  _saveButton(),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const Text(
                                    "-- Or --",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const Text(
                                    "Skip if you don't have one",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
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
                                          backgroundImage:
                                              NetworkImage(selectedImg),
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
                                        _entryField(
                                            "Make...", _motoMakeController),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        _entryField(
                                            "Model...", _motoModelController),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        _entryField(
                                            "Color...", _motoColorController),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        _entryField(
                                            "Year...", _motoYearController),
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
                  ))
            ],
          ),
        ));
  }
}
