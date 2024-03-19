
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey2/constants.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:convert';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'SearchComponent.dart';
import 'location_service.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';







class MapView extends StatefulWidget {
  
  const MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
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

  

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    getMarkerData();
  }

  void _toggleMapStyle() async {
  
    if (_isNightMode) {
      _controller?.setMapStyle(null); // Switch to normal mode
    } else {
      // Add your night mode style JSON string below
      String nightStyle = jsonEncode([
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]);
      _controller?.setMapStyle(nightStyle);
    }
    setState(() {
      _isNightMode = !_isNightMode;
    });
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

  Future<Marker?> initMarker(DocumentSnapshot doc) async {
    try {
      final markerId = MarkerId(doc.id);
      final coordinates = doc['coordinates'] as Map<String, dynamic>;
      final latitude = coordinates['latitude'] as double;
      final longitude = coordinates['longitude'] as double;
      final userId = doc['userId'] as String;

      final DocumentSnapshot riderDoc = await FirebaseFirestore.instance
          .collection('Riders')
          .doc(userId)
          .get();

      final profileImageUrl = riderDoc['profileImg'] as String;
      final riderUsername = riderDoc['userName'] as String;
      final riderBio = riderDoc['Bio'] as String;
      final riderLastTime = doc['timestamp'].toDate().toString();
      final markerType = doc['Type'] as String;
      final markerImage = await getMarker(profileImageUrl);

      return Marker(
        markerId: markerId,
        // position: LatLng(currentPosition.latitude, currentPosition.longitude),
        position: LatLng(latitude, longitude),
        icon: BitmapDescriptor.fromBytes(markerImage),
        // infoWindow: InfoWindow(
        //   title: riderDoc['userName'] as String,
        //   snippet: 'Last updated: ${doc['timestamp'].toDate()}',
        // ),
        onTap: () {
          if (markerType == "Rider") {
            _customInfoWindowController.addInfoWindow!(
              Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ui.Color.fromARGB(255, 26, 123, 202),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      NetworkImage(profileImageUrl),
                                ),
                                SizedBox(
                                  width: 8.0,
                                ),
                                Text(
                                  riderUsername,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Spacer(),
                                Text(
                                  riderBio,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                Spacer()
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Spacer(),
                                Text(
                                  "Last here " + riderLastTime,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                Spacer()
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
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
                                Spacer()
                              ],
                            )
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
          } else if (markerType == "RideAlong") {
            _customInfoRideAlongController.addInfoWindow!(
              Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ui.Color.fromARGB(255, 100, 15, 28),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          children: [
                            // Row(
                            //   children: [

                            //   ],
                            // ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      NetworkImage(profileImageUrl),
                                ),
                                SizedBox(
                                  width: 8.0,
                                ),
                                Text(
                                  riderUsername,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Spacer(),
                                Text(
                                  riderBio,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                Spacer()
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Spacer(),
                                Text(
                                  "Start Time " + riderLastTime,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                Spacer()
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Spacer(),
                                ElevatedButton(
                                  child: Text("Join Ride Along"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo[700],
                                    elevation: 0,
                                  ),
                                  onPressed: () {},
                                ),
                                Spacer()
                              ],
                            )
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

  void getMarkerData() {
    _markerSubscription = FirebaseFirestore.instance
        .collection('Markers')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      Set<Marker> tempMarkers = {};

      for (var doc in snapshot.docs) {
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

  Future<void> _updateUserLocationInFirestore(
      LocationData currentLocation) async {
    print("_UpdateUserLocationFirestorexCalled Successfully");
    final User? user = FirebaseAuth.instance.currentUser;

    if (locationUpdated) {
      // print("Already obtained location");
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
        currentLocation.longitude!);
    // _refreshMarkers(userId, LatLng(currentLocation.latitude!, currentLocation.longitude!));

    if (distance > significantDistance || !locationUpdated) {
      // print("LAM - Updating User Location");
      await userLocationDoc.update({
        'coordinates': {
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
        },
        'lastSeenTimestamp': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
        'Type': "Rider"
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
      markers.add(Marker(
          markerId: MarkerId(point.toString()),
          position: point,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: () {
            _customInfoRideAlongController.addInfoWindow!(
              Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ui.Color.fromARGB(255, 50, 40, 87),
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
                                  "New Ride Along",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Spacer(),
                                ElevatedButton(
                                  child: Text("Enter Details"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo[700],
                                    elevation: 0,
                                  ),
                                  onPressed: () {},
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                ElevatedButton(
                                  child: Text("Cancel"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ui.Color.fromARGB(255, 68, 10, 15),
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

    super.dispose();
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
                  polylines: _polylines, // Add this line
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        currentPosition.latitude, currentPosition.longitude),
                    zoom: 15.0,
                  ),
                ),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
                  height: size.height * 0.20,
                  width: size.width * 0.8,
                  offset: 0,
                ),
                CustomInfoWindow(
                  controller: _customInfoRideAlongController,
                  height: size.height * 0.20,
                  width: size.width * 0.85,
                  offset: 0,
                ),
                Positioned(
                  top: 14.0, // Adjust the top position as needed
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
            child:
                Icon(_isNightMode ? Icons.wb_sunny : Icons.nightlight_round),
          ),
        ),
      ),
    );
  }
}

  