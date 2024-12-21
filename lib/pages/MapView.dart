import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:journey2/Classes/PointData.dart';
import 'package:journey2/auth.dart';
import 'package:journey2/constants.dart';
import 'package:journey2/pages/NewRideAlong.dart';
import 'package:journey2/pages/home_page.dart';
import 'package:journey2/pages/newRide.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:convert';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:path_provider/path_provider.dart';
import 'SearchComponent.dart';
import 'location_service.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_card/image_card.dart';
import 'package:file_picker/file_picker.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  bool _isNightMode = false;
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  final CustomInfoWindowController _customInfoRideAlongController =
      CustomInfoWindowController();

  bool locationUpdated = false;
  bool peningRideAlong = false;
  GoogleMapController? _controller;
  LocationData? _currentLocation;
  var currentPosition;
  StreamSubscription<LocationData>? _locationSubscription;
  StreamSubscription<QuerySnapshot>? _markerSubscription;
  Set<Marker> markers = {};
  Set<Polyline> _polylines = {}; // Add this line
  final double significantDistance =
      25; // meters, threshold for significant movement

//Variables for new rides etc
  late String _setTime, _setDate;

  late String _hour, _minute, _time;

  late String dateTime;

  DateTime selectedDate = DateTime.now();
  bool use24HourTime = false;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
// final TextEditingController _newRideAlongTextController =

  final TextEditingController _newRideAlongTextController =
      TextEditingController();
  //New Text
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newStartDate = TextEditingController();
  final TextEditingController _newStartTime = TextEditingController();
  final TextEditingController _newDescription = TextEditingController();
  final TextEditingController _newPrivacySetting = TextEditingController();

  var errorMsg = "";
  //Push Data to Firebase

  File? _image;
  File? selectedGalleryImg;
  bool selectedFile = false;

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

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    getMarkerData();
    WidgetsBinding.instance.addObserver(this);
  }

//Functions for saving new Ride Along to DB
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
    if (picked != null) {
      setState(() {
        _newStartDate.text = DateFormat.yMd().format(picked);
      });
    }
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

//Original Map View functions below

  void _toggleMapStyle() async {
    if (_isNightMode) {
      _controller?.setMapStyle(null); // Switch to normal mode
    } else {
      // Add your night mode style JSON string below
      String nightStyle = jsonEncode([
        {
          "elementType": "geometry",
          "stylers": [
            {"color": "#242f3e"}
          ]
        },
        {
          "elementType": "labels.text.fill",
          "stylers": [
            {"color": "#746855"}
          ]
        },
        {
          "elementType": "labels.text.stroke",
          "stylers": [
            {"color": "#242f3e"}
          ]
        },
        {
          "featureType": "administrative.locality",
          "elementType": "labels.text.fill",
          "stylers": [
            {"color": "#d59563"}
          ]
        },
        {
          "featureType": "poi",
          "elementType": "labels.text.fill",
          "stylers": [
            {"color": "#d59563"}
          ]
        },
        {
          "featureType": "poi.park",
          "elementType": "geometry",
          "stylers": [
            {"color": "#263c3f"}
          ]
        },
        {
          "featureType": "poi.park",
          "elementType": "labels.text.fill",
          "stylers": [
            {"color": "#6b9a76"}
          ]
        },
        {
          "featureType": "road",
          "elementType": "geometry",
          "stylers": [
            {"color": "#38414e"}
          ]
        },
        {
          "featureType": "road",
          "elementType": "geometry.stroke",
          "stylers": [
            {"color": "#212a37"}
          ]
        },
        {
          "featureType": "road",
          "elementType": "labels.text.fill",
          "stylers": [
            {"color": "#9ca5b3"}
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "geometry",
          "stylers": [
            {"color": "#746855"}
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "geometry.stroke",
          "stylers": [
            {"color": "#1f2835"}
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "labels.text.fill",
          "stylers": [
            {"color": "#f3d19c"}
          ]
        },
        {
          "featureType": "transit",
          "elementType": "geometry",
          "stylers": [
            {"color": "#2f3948"}
          ]
        },
        {
          "featureType": "transit.station",
          "elementType": "labels.text.fill",
          "stylers": [
            {"color": "#d59563"}
          ]
        },
        {
          "featureType": "water",
          "elementType": "geometry",
          "stylers": [
            {"color": "#17263c"}
          ]
        },
        {
          "featureType": "water",
          "elementType": "labels.text.fill",
          "stylers": [
            {"color": "#515c6d"}
          ]
        },
        {
          "featureType": "water",
          "elementType": "labels.text.stroke",
          "stylers": [
            {"color": "#17263c"}
          ]
        }
      ]);
      _controller?.setMapStyle(nightStyle);
    }
    setState(() {
      _isNightMode = !_isNightMode;
    });
  }

  void getMarkerDataOld() {
    _markerSubscription = FirebaseFirestore.instance
        .collection('Markers')
        .where('isOnline',
            isEqualTo: true) // Filter markers based on isOnline field
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      Set<Marker> tempMarkers = {};

      for (var doc in snapshot.docs) {
        print("\n\n\n\n\n");
        print("DATA: " + doc.data().toString());
        print("\n\n\n\n\n");
        initMarker(doc).then((marker) {
          if (marker != null) {
            tempMarkers.add(marker);
          } else {
            print("Err Marker is Null on initMarker Function");
          }
        });
      }

      setState(() {
        markers = tempMarkers;
      });
    });
  }

  void getMarkerData() {
    _markerSubscription = FirebaseFirestore.instance
        .collection('Markers')
        // Filter markers based on isOnline field
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      Set<Marker> tempMarkers = {};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // print("\n\n\n\n");
        // print("DD: " + data['Type']);
        // print("\n\n\n\n");
        if (data['Type'] == "Rider") {
          initMarker(doc).then((marker) {
            if (marker != null) {
              tempMarkers.add(marker);
            } else {
              print("Err Marker is Null on initMarker Function");
            }
          });
        } else if (data['Type'] == "RideAlong") {
          initRAMarker(doc).then((marker) {
            if (marker != null) {
              tempMarkers.add(marker);
            } else {
              print("Err Marker is Null on initRAMarker Function");
            }
          });
        }
      }

      setState(() {
        markers = tempMarkers;
      });
    });
  }

  void _initializeLocation() async {
    final Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationSubscription =
        location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
      });
      _updateUserLocationInFirestore(currentLocation);
    });
    var tlocation = Location();
    try {
      currentPosition = await tlocation.getLocation();

      setState(
          () {}); //rebuild the widget after getting the current location of the user
    } on Exception {
      currentPosition = null;
    }
  }

  Future<void> _updateUserLocationInFirestore(
      LocationData currentLocation) async {
    print("_UpdateUserLocationFirestorexCalled Successfully");
    final User? user = FirebaseAuth.instance.currentUser;

    if (locationUpdated) {
      return; //no need to use up resources
    }

    if (user == null) {
      print("NULL User or CurrentLocation in UULF");
      return;
    }

    final String userId = user.uid;
    final DocumentReference userLocationDoc =
        FirebaseFirestore.instance.collection('Markers').doc(userId);

    final snapshot = await userLocationDoc.get();

    if (!snapshot.exists) {
      print("Snapshot Not found in UULF");
      await _createUserLocation(userLocationDoc, userId, currentLocation);
      return;
    }

    final previousLocation = snapshot.data() as Map<String, dynamic>;
    final previousCoordinates =
        previousLocation['coordinates'] as Map<String, dynamic>;
    final double previousLatitude = previousCoordinates['latitude'];
    final double previousLongitude = previousCoordinates['longitude'];

    final double distance = _calculateDistance(
      previousLatitude,
      previousLongitude,
      currentLocation.latitude!,
      currentLocation.longitude!,
    );

    if (distance > significantDistance || !locationUpdated) {
      await userLocationDoc.update({
        'coordinates': {
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
        },
        'lastSeenTimestamp': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
        'Type': "Rider",
        'isOnline': true,
      });
      _refreshMarkers(userId,
          LatLng(currentLocation.latitude!, currentLocation.longitude!));
      locationUpdated = true;
    }
  }

  Future<void> _createUserLocation(DocumentReference doc, String userId,
      LocationData currentLocation) async {
    print("Creating New User Location");
    await doc.set({
      'userId': userId,
      'coordinates': {
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
      },
      'lastSeenTimestamp': FieldValue.serverTimestamp(),
      'timestamp': FieldValue.serverTimestamp(),
      'Type': "Rider"
    });

    _refreshMarkers(
        userId, LatLng(currentLocation.latitude!, currentLocation.longitude!));
  }

  void _refreshMarkers(String userId, LatLng newLocation) async {
    setState(() {
      markers.removeWhere((marker) => marker.markerId.value == userId);
      markers.add(Marker(
        markerId: MarkerId(userId),
        position: newLocation,
        icon: BitmapDescriptor
            .defaultMarker, // Replace with custom icon if needed
      ));
    });
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295; // Pi / 180
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  _handleTap(LatLng point) {
    if (peningRideAlong) {
      print("Must complete upcoming Ride Along before creating new one");
      return;
    }
    setState(() {
      Size size = MediaQuery.of(context).size;
      markers.add(Marker(
          markerId: MarkerId(point.toString()),
          position: point,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          onTap: () {
            _customInfoRideAlongController.addInfoWindow!(
              Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ui.Color.fromARGB(255, 58, 30, 124),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          children: [
                            Spacer(),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                SizedBox(
                                  width: 8.0,
                                ),
                                Text(
                                  "Create New Ride Along ?",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                Spacer(),
                                ElevatedButton(
                                  child: Text(
                                    "Yes",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const ui.Color.fromARGB(
                                        255, 59, 81, 222),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    var endPoint = pointData(
                                        point: point,
                                        pointLat: point.latitude,
                                        pointLong: point.longitude);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return NewRideAlong(
                                              srcPoint: endPoint);
                                        },
                                      ),
                                    );
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
                                    backgroundColor:
                                        ui.Color.fromARGB(255, 216, 32, 47),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    int index = markers.length - 1;
                                    if (index > 0) {
                                      markers.remove(markers.elementAt(index));
                                      setState(() {
                                        peningRideAlong = false;
                                        _customInfoRideAlongController
                                            .hideInfoWindow!();
                                      });
                                    }
                                  },
                                ),
                                Spacer()
                              ],
                            ),
                            Spacer()
                          ],
                        ),
                      ),
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ],
              ),
              point,
            );
          }));
      peningRideAlong = true;
    });
  }

  void _handleSearchSubmit(String placeId, String description) async {
    print("PlaceID: " + placeId);
    print("Desc: ${description}");
    // Retrieve place details using the place ID
    var place = await LocationService().getPlace(placeId);

    // Extract the latitude and longitude coordinates from the place details
    var lat = place['geometry']['location']['lat'];
    var lng = place['geometry']['location']['lng'];

    // Retrieve directions from the user's current location to the destination
    var directions = await LocationService().getDirections(
      '${currentPosition.latitude},${currentPosition.longitude}',
      '$lat,$lng',
    );
    _updateMapView(directions);
  }

  void _updateMapView(Map<String, dynamic> directions) {
    setState(() {
      _polylines.clear(); // Clear existing polylines
      _polylines.add(Polyline(
        polylineId: PolylineId("route"),
        points: directions['polyline_decoded']
            .map<LatLng>((point) => LatLng(point.latitude, point.longitude))
            .toList(),
        color: Colors.blue,
        width: 5,
      ));
    });

    // Update the map bounds
    final southwest = directions['bounds_sw'];
    final northeast = directions['bounds_ne'];
    final bounds = LatLngBounds(
      southwest: LatLng(southwest['lat'], southwest['lng']),
      northeast: LatLng(northeast['lat'], northeast['lng']),
    );

    _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _markerSubscription?.cancel();
    _customInfoWindowController.dispose();
    _customInfoRideAlongController.dispose();
    //Place all controllers here for disposal
    _newStartDate.dispose();
    _newNameController.dispose();
    _newRideAlongTextController.dispose();
    _newDescription.dispose();
    _newPrivacySetting.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _setUserOffline();
    }
  }

  Future<void> _setUserOffline() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      final DocumentReference userLocationDoc =
          FirebaseFirestore.instance.collection('Markers').doc(userId);
      await userLocationDoc.update({
        'isOnline': false,
      });
    }
  }

  Future<Uint8List> getMarker(String profileUrl) async {
    try {
      final File markerImageFile =
          await DefaultCacheManager().getSingleFile(profileUrl);
      final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(markerImageBytes,
          targetWidth: 120, targetHeight: 120);
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ui.Image image = fi.image;

      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      const int size = 120;
      final Paint paint = Paint();
      const double radius = size / 2;

      paint.color = Colors.white;
      canvas.drawCircle(const Offset(radius, radius), radius, paint);

      final Path clipPath = Path()
        ..addOval(Rect.fromCircle(
            center: const Offset(radius, radius), radius: radius));
      canvas.clipPath(clipPath);
      canvas.drawImage(image, Offset.zero, paint);

      final ui.Image markerAsImage =
          await pictureRecorder.endRecording().toImage(size, size);
      final ByteData? byteData =
          await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      print("Error fetching or processing marker image: $e");
      return (await rootBundle.load('assets/default_marker.png'))
          .buffer
          .asUint8List();
    }
  }

  Future<BitmapDescriptor> createMarkerIcon(
      String profileUrl, bool isOnline) async {
    final Uint8List markerImageBytes = await getMarker(profileUrl);
    final ui.Codec codec = await ui.instantiateImageCodec(markerImageBytes);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image image = fi.image;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint();

    final double borderWidth = 4;
    final double imageSize = image.width.toDouble();
    final double canvasSize = imageSize + (2 * borderWidth);

    canvas.drawImage(
      image,
      Offset(borderWidth, borderWidth),
      paint,
    );

    if (isOnline) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = borderWidth;
      paint.strokeCap = StrokeCap.round;

      final double radius = imageSize / 2;
      final Offset center = Offset(canvasSize / 2, canvasSize / 2);

      final AnimationController animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      )..repeat(reverse: true);

      final borderAnimation = ColorTween(
        begin: Colors.lightGreen,
        end: Colors.green[900],
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
      );

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..strokeCap = StrokeCap.round;

      animationController.addListener(() {
        canvas.drawCircle(
          center,
          radius,
          borderPaint..color = borderAnimation.value ?? Colors.green,
        );
      });

      animationController.forward();
      await Future.delayed(const Duration(milliseconds: 500));
      animationController.dispose();
    } else {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = borderWidth;
      paint.strokeCap = StrokeCap.round;

      final double radius = imageSize / 2;
      final Offset center = Offset(canvasSize / 2, canvasSize / 2);

      final AnimationController animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      )..repeat(reverse: true);

      final borderAnimation = ColorTween(
        begin: ui.Color.fromARGB(255, 0, 128, 255),
        end: ui.Color.fromARGB(255, 0, 177, 247),
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
      );

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..strokeCap = StrokeCap.round;

      animationController.addListener(() {
        canvas.drawCircle(
          center,
          radius,
          borderPaint..color = borderAnimation.value ?? Colors.green,
        );
      });

      animationController.forward();
      await Future.delayed(const Duration(milliseconds: 500));
      animationController.dispose();
    }

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image markerAsImage = await picture.toImage(
      canvasSize.toInt(),
      canvasSize.toInt(),
    );
    final ByteData? byteData =
        await markerAsImage.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> createRAMarkerIcon(String coverImg) async {
    final Uint8List markerImageBytes = await getMarker(coverImg);
    final ui.Codec codec = await ui.instantiateImageCodec(markerImageBytes);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image image = fi.image;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint();

    final double borderWidth = 4;
    final double imageSize = image.width.toDouble();
    final double canvasSize = imageSize + (2 * borderWidth);

    canvas.drawImage(
      image,
      Offset(borderWidth, borderWidth),
      paint,
    );

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = borderWidth;
    paint.strokeCap = StrokeCap.round;

    final double radius = imageSize;
    final Offset center = Offset(canvasSize / 2, canvasSize / 2);

    final AnimationController animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    final borderAnimation = ColorTween(
      begin: const ui.Color.fromARGB(255, 74, 135, 195),
      end: ui.Color.fromARGB(255, 0, 94, 255),
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    animationController.addListener(() {
      canvas.drawCircle(
        center,
        radius,
        borderPaint
          ..color =
              borderAnimation.value ?? ui.Color.fromARGB(255, 0, 145, 255),
      );
    });

    animationController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    animationController.dispose();

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image markerAsImage = await picture.toImage(
      canvasSize.toInt(),
      canvasSize.toInt(),
    );
    final ByteData? byteData =
        await markerAsImage.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<Marker?> initMarker(DocumentSnapshot doc) async {
    try {
      final markerId = MarkerId(doc.id);
      final coordinates = doc['coordinates'] as Map<String, dynamic>;
      final latitude = coordinates['latitude'] as double;
      final longitude = coordinates['longitude'] as double;
      final userId = doc['userId'] as String;
      // final coverImg = doc['coverImg'] as String;

      final DocumentSnapshot riderDoc = await FirebaseFirestore.instance
          .collection('Riders')
          .doc(userId)
          .get();

      final profileImageUrl = riderDoc['profileImg'] as String;
      final riderUsername = riderDoc['userName'] as String;
      final riderKey = riderDoc['userKey'] as String;
      final riderBio = riderDoc['Bio'] as String;
      final riderLastTime = doc['timestamp'].toDate().toString();
      final markerType = doc['Type'] as String;
      final isOnline = doc['isOnline'] as bool;

      BitmapDescriptor markerIcon =
          await createMarkerIcon(profileImageUrl, isOnline);
      if (markerType != "Rider") {
        final title = doc['title'] as String;
        markerIcon = await createRAMarkerIcon(doc['coverImg']);
      }

      return Marker(
        markerId: markerId,
        position: LatLng(latitude, longitude),
        icon: markerIcon,
        onTap: () {
          if (markerType == "Rider" &&
              riderKey == FirebaseAuth.instance.currentUser?.uid.toString()) {
            _customInfoWindowController.addInfoWindow!(
              Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: kSly,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 5),
                                CircleAvatar(
                                  radius: 35,
                                  backgroundImage:
                                      NetworkImage(profileImageUrl),
                                ),
                                const SizedBox(width: 10.0),
                                Text(
                                  riderUsername,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Spacer(),
                                Text(
                                  riderBio,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ],
              ),
              LatLng(latitude, longitude),
            );
          } else if (markerType == "Rider" &&
              riderKey != FirebaseAuth.instance.currentUser?.uid.toString()) {
            _customInfoWindowController.addInfoWindow!(
              Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ui.Color.fromARGB(255, 26, 123, 202),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 5),
                                CircleAvatar(
                                  radius: 10,
                                  backgroundImage:
                                      NetworkImage(profileImageUrl),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  riderUsername,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Spacer(),
                                Text(
                                  riderBio,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                Spacer(),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Spacer(),
                                Text(
                                  "Seen @ " + riderLastTime,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                Spacer(),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Spacer(),
                                ElevatedButton(
                                  child: Text("Add Friend"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo[700],
                                    elevation: 0,
                                  ),
                                  onPressed: () {},
                                ),
                                Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ],
              ),
              LatLng(latitude, longitude),
            );
          }
        },
      );
    } catch (e) {
      print("Error initializing marker: $e");
      return null;
    }
  }

  Future<Marker?> initRAMarker(DocumentSnapshot doc) async {
    // print("LAM ATTEMPTING INITRAMARKER");
    try {
      final markerId = MarkerId(doc.id);
      final coordinates = doc['coordinates'] as Map<String, dynamic>;
      final latitude = coordinates['latitude'] as double;
      final longitude = coordinates['longitude'] as double;
      final userId = doc['Host'] as String;
      final coverImg = doc['coverImg'] as String;
      final startDate = doc['startDate'] as String;
      final startTime = doc['startTime'] as String;
      final date = doc['date'] as String;
      final title = doc['title'] as String;

      final DocumentSnapshot riderDoc = await FirebaseFirestore.instance
          .collection('Riders')
          .doc(userId)
          .get();

      final profileImageUrl = riderDoc['profileImg'] as String;
      final riderUsername = riderDoc['userName'] as String;
      final riderKey = riderDoc['userKey'] as String;
      final riderBio = riderDoc['Bio'] as String;
      final markerType = doc['Type'] as String;
      Size size = MediaQuery.of(context).size;

      BitmapDescriptor markerIcon = await createRAMarkerIcon(
          "https://obsidianrune.com/static/img/Ruimel.da20829.png");
      if (markerType != "Rider") {
        final title = doc['title'] as String;
        markerIcon = await createRAMarkerIcon(
            "https://obsidianrune.com/static/img/Ruimel.da20829.png");
      }

      return Marker(
        markerId: markerId,
        position: LatLng(latitude, longitude),
        icon: markerIcon,
        onTap: () {
          if (markerType == "RideAlong") {
            _customInfoRideAlongController.addInfoWindow!(
              Container(
                height: 750,
                width: double.maxFinite,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(coverImg),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Card(
                  color: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Column(
                      children: [
                        Spacer(),
                        Container(
                            color: const ui.Color.fromARGB(132, 0, 0, 0),
                            width: size.width,
                            child: Center(
                              child: Text(
                                title,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: size.width * 0.075),
                              ),
                            )),
                        Container(
                          color: const ui.Color.fromARGB(132, 0, 0, 0),
                          child: Center(
                            child: Text(
                              "START TIME : " + date,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.width * 0.035),
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
              LatLng(latitude, longitude),
            );
          }
        },
      );
    } catch (e) {
      print("Error initializing marker: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          if (currentPosition != null) ...[
            Stack(
              children: [
                GoogleMap(
                  onLongPress: (position) {
                    //Create New Marker @ Location
                    _handleTap(position);
                  },
                  onTap: (position) {
                    //Hide The Map
                    _customInfoWindowController.hideInfoWindow!();
                    _customInfoRideAlongController.hideInfoWindow!();
                  },
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                    _customInfoWindowController.googleMapController =
                        controller;
                    _customInfoRideAlongController.googleMapController =
                        controller;
                  },
                  onCameraMove: (position) {
                    _customInfoWindowController.onCameraMove!();
                    _customInfoRideAlongController.onCameraMove!();
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: markers,
                  polylines: _polylines,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        currentPosition.latitude, currentPosition.longitude),
                    zoom: 15.0,
                  ),
                ),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
                  height: size.height * 0.15,
                  width: size.width * 0.60,
                  offset: 0,
                ),
                CustomInfoWindow(
                  controller: _customInfoRideAlongController,
                  height: size.height * 0.20,
                  width: size.width * 0.65,
                  offset: 0,
                ),
                Positioned(
                  bottom: 10.0,
                  left: 16.0,
                  right: 16.0,
                  child: SearchComponent(
                    onSearchSubmit: _handleSearchSubmit,
                  ),
                ),
              ],
            ),
          ] else ...[
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: _toggleMapStyle,
            tooltip: 'Toggle Map Mode',
            child: Icon(_isNightMode ? Icons.wb_sunny : Icons.nightlight_round),
          ),
        ),
      ),
    );
  }
}
