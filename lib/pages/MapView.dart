import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';


import 'package:custom_info_window/custom_info_window.dart';


class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

   final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();


  bool locationUpdated = false;
  GoogleMapController? _controller;
  LocationData? _currentLocation;
  var currentPosition;
  StreamSubscription<LocationData>? _locationSubscription;
  StreamSubscription<QuerySnapshot>? _markerSubscription;
  Set<Marker> markers = {};
  final double significantDistance = 25; // meters, threshold for significant movement





  @override
  void initState() {
    super.initState();
    _initializeLocation();
    getMarkerData();
  }



  Future<Uint8List> getMarker(String profileUrl) async {
    try {
      final File markerImageFile = await DefaultCacheManager().getSingleFile(profileUrl);
      final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(markerImageBytes, targetWidth: 120, targetHeight: 120);
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ui.Image image = fi.image;

      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      const int size = 120;
      final Paint paint = Paint();
      const double radius = size / 2;

      paint.color = Colors.white;
      canvas.drawCircle(const Offset(radius, radius), radius, paint);

      final Path clipPath = Path()..addOval(Rect.fromCircle(center: const Offset(radius, radius), radius: radius));
      canvas.clipPath(clipPath);
      canvas.drawImage(image, Offset.zero, paint);

      final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(size, size);
      final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      print("Error fetching or processing marker image: $e");
      return (await rootBundle.load('assets/default_marker.png')).buffer.asUint8List();
    }
  }

  Future<Marker?> initMarker(DocumentSnapshot doc) async {
    try {
      final markerId = MarkerId(doc.id);
      final coordinates = doc['coordinates'] as Map<String, dynamic>;
      final latitude = coordinates['latitude'] as double;
      final longitude = coordinates['longitude'] as double;
      final userId = doc['userId'] as String;

      final DocumentSnapshot riderDoc = await FirebaseFirestore.instance.collection('Riders').doc(userId).get();
      final profileImageUrl = riderDoc['profileImg'] as String;

      final markerImage = await getMarker(profileImageUrl);

      
      return Marker(
        markerId: markerId,
        // position: LatLng(currentPosition.latitude, currentPosition.longitude),
        position: LatLng(latitude, longitude),
        icon: BitmapDescriptor.fromBytes(markerImage),
        infoWindow: InfoWindow(
          title: riderDoc['userName'] as String,
          snippet: 'Last updated: ${doc['timestamp'].toDate()}',
        ),
        onTap: (){

        },
      
      );
    } catch (e) {
      print("Error initializing marker: $e");
      return null;
    }
  }

  void getMarkerData() {
    _markerSubscription = FirebaseFirestore.instance
        .collection('UserLocation')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      Set<Marker> tempMarkers = {};

      for (var doc in snapshot.docs) {
        initMarker(doc).then((marker) {
          if (marker != null) {
            tempMarkers.add(marker);
          }else{
            print("Err Marker is Null on initMarker Function");
          }
        });
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

    _locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
      });
      // print("Prep Update Location in Firestore");
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


  Future<void> _updateUserLocationInFirestore(LocationData currentLocation) async {
    // print("_UpdateUserLocationFirestore Called Successfully");
    final User? user = FirebaseAuth.instance.currentUser;

  

    if (locationUpdated){
      // print("Already obtained location");
      return; //no need to use up resources
    }



    if (user == null) {
      print("NULL User or CurrentLocation in UULF");
      return;
    }

    final String userId = user.uid;
    final DocumentReference userLocationDoc = FirebaseFirestore.instance.collection('UserLocation').doc(userId);

    final snapshot = await userLocationDoc.get();
    if (!snapshot.exists) {
      print("Snapshot found in UULF");
      await _createUserLocation(userLocationDoc, userId, currentLocation);
      return;
    }


    final previousLocation = snapshot.data() as Map<String, dynamic>;
    final previousCoordinates = previousLocation['coordinates'] as Map<String, dynamic>;
    final double previousLatitude = previousCoordinates['latitude'];
    final double previousLongitude = previousCoordinates['longitude'];

    final double distance = _calculateDistance(
        previousLatitude, previousLongitude, currentLocation.latitude!, currentLocation.longitude!
    );
          // _refreshMarkers(userId, LatLng(currentLocation.latitude!, currentLocation.longitude!));


    if (distance > significantDistance || !locationUpdated) {
      await userLocationDoc.update({
        'coordinates': {
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
        },
        'lastSeenTimestamp': FieldValue.serverTimestamp(),
      });
      _refreshMarkers(userId, LatLng(currentLocation.latitude!, currentLocation.longitude!));
      locationUpdated = true;
    }
  }

  Future<void> _createUserLocation(DocumentReference doc, String userId, LocationData currentLocation) async {
    await doc.set({
      'userId': userId,
      'coordinates': {
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
      },
      'lastSeenTimestamp': FieldValue.serverTimestamp(),
    });

    _refreshMarkers(userId, LatLng(currentLocation.latitude!, currentLocation.longitude!));
  }

  void _refreshMarkers(String userId, LatLng newLocation) async {
    setState(() {
      markers.removeWhere((marker) => marker.markerId.value == userId);
      markers.add(Marker(
        markerId: MarkerId(userId),
        position: newLocation,
        icon: BitmapDescriptor.defaultMarker, // Replace with custom icon if needed
      ));
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;    // Pi / 180
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
             c(lat1 * p) * c(lat2 * p) * 
             (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _markerSubscription?.cancel();
        _customInfoWindowController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          if(currentPosition != null)...[
              Stack(
                children: [
                      GoogleMap(
                        onTap: (position){
                          // _customInfoWindowController.hideInfoWindow();
                        },
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: markers,                
                      initialCameraPosition: CameraPosition(
                        target: LatLng(currentPosition.latitude, currentPosition.longitude),
                        zoom: 15.0,
                      ),
                    ),  
                     CustomInfoWindow(
                        controller: _customInfoWindowController,
                        height: 75,
                        width: 150,
                        offset: 50,
                      ),           
                ]
              )
           
          ]else...[
            const Center(
                child: CircularProgressIndicator(),)

          ]

          // Add other widgets that you might need on your map screen
        ],
      ),
    );
  }
}
