
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey2/constants.dart';
import 'package:journey2/pages/NewRideAlong.dart';
import 'package:journey2/pages/newRide.dart';
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

class _MapViewState extends State<MapView> with WidgetsBindingObserver, TickerProviderStateMixin {
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
  WidgetsBinding.instance.addObserver(this);
  createRideAlongDocument();

  // Test marker
  final testMarker = Marker(
    markerId: MarkerId('test'),
    position: LatLng(39.02595, -77.420963),
    icon: BitmapDescriptor.defaultMarker,
  );

  setState(() {
    markers.add(testMarker);
  });
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

  Future<Marker?> initRideAlongMarker(DocumentSnapshot doc) async {
  print('Ride Along Document Data: ${doc.data()}');

  try {
    final markerId = MarkerId(doc.id);
    final coordinates = doc['coordinates'] as Map<String, dynamic>;
    final latitude = coordinates['latitude'] as double;
    final longitude = coordinates['longitude'] as double;
    final title = doc['title'] as String;
    final description = doc['description'] as String;
    final destination = doc['destination'] as String;
    final owner = doc['owner'] as String;
    final dateTime = doc['dateTime'] as Timestamp?;

    print('Latitude: $latitude, Longitude: $longitude');

    return Marker(
      markerId: markerId,
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarker,
      onTap: () {
        _customInfoRideAlongController.addInfoWindow!(
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(description),
                        SizedBox(height: 5),
                        Text('Destination: $destination'),
                        SizedBox(height: 5),
                        Text('Owner: $owner'),
                        SizedBox(height: 5),
                        Text('Date/Time: ${dateTime?.toDate() ?? 'N/A'}'),
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
      },
    );
  } catch (e) {
    print("Error initializing ride along marker: $e");
    return null;
  }
}

  void getMarkerData() {
  _markerSubscription = FirebaseFirestore.instance
      .collection('Markers')
      .where('isOnline', isEqualTo: true)
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

  FirebaseFirestore.instance
      .collection('RideAlongs')
      .snapshots()
      .listen((QuerySnapshot snapshot) {
    Set<Marker> tempRideAlongMarkers = {};

    for (var doc in snapshot.docs) {
      final coordinates = doc['coordinates'] as Map<String, dynamic>;
      final latitude = coordinates['latitude'] as double;
      final longitude = coordinates['longitude'] as double;
      final title = doc['title'] as String;
      final description = doc['description'] as String;
      final destination = doc['destination'] as String;
      final ownerId = doc['owner'] as String;
      final dateTime = doc['dateTime'] as Timestamp;

      // Fetch the owner's username from the Riders collection
      FirebaseFirestore.instance
          .collection('Riders')
          .doc(ownerId)
          .get()
          .then((ownerDoc) {
        final ownerUsername = ownerDoc['userName'] as String;

        final marker = Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(latitude, longitude),
          icon: BitmapDescriptor.defaultMarker,
          onTap: () {
            _customInfoRideAlongController.addInfoWindow!(
              Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(description),
                            SizedBox(height: 5),
                            Text('Destination: $destination'),
                            SizedBox(height: 5),
                            Text('Owner: $ownerUsername'),
                            SizedBox(height: 5),
                            Text('Date/Time: ${dateTime.toDate()}'),
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
          },
        );

        tempRideAlongMarkers.add(marker);

        print('Ride Along Markers: $tempRideAlongMarkers');

        setState(() {
          markers.addAll(tempRideAlongMarkers);
          print('Updated markers: $markers');
        });
      });
    }
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

      setState(() {}); //rebuild the widget after getting the current location of the user
    } on Exception {
      currentPosition = null;
    }
  }

  Future<void> _updateUserLocationInFirestore(LocationData currentLocation) async {
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
    final DocumentReference userLocationDoc = FirebaseFirestore.instance.collection('Markers').doc(userId);

    final snapshot = await userLocationDoc.get();

    if (!snapshot.exists) {
      print("Snapshot Not found in UULF");
      await _createUserLocation(userLocationDoc, userId, currentLocation);
      return;
    }

    final previousLocation = snapshot.data() as Map<String, dynamic>;
    final previousCoordinates = previousLocation['coordinates'] as Map<String, dynamic>;
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
      _refreshMarkers(userId, LatLng(currentLocation.latitude!, currentLocation.longitude!));
      locationUpdated = true;
    }
  }

  Future<void> _createUserLocation(DocumentReference doc, String userId, LocationData currentLocation) async {
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
    var p = 0.017453292519943295; // Pi / 180
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () {
          _customInfoRideAlongController.addInfoWindow!(
            Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: ui.Color.fromARGB(255, 65, 19, 229),
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
                                "Create New Ride Along?",
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
                                  "Create",
                                  style: TextStyle(fontSize: 20),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const ui.Color.fromARGB(
                                      255, 59, 81, 222),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const NewRideAlong();
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
                                  backgroundColor: ui.Color.fromARGB(255, 216, 32, 47),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  int index = markers.length - 1;
                                  if (index > 0) {
                                    markers.remove(markers.elementAt(index));
                                    setState(() {
                                      peningRideAlong = false;
                                      _customInfoRideAlongController.hideInfoWindow!();
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

Future<void> createRideAlongDocument() async {
    try {
      final rideAlongData = {
        'coordinates': {
          'latitude': 38.9523,
          'longitude': -77.4586,
        },
        'title': 'First Ride',
        'description': 'Join us to go shopping at tysons!',
        'destination': 'Tysons Center Mall',
        'owner': 'EuVCs4QdpVhJKnFXrYFIS3SzNjH3',
        'dateTime': Timestamp.fromDate(DateTime(2024, 6, 10, 9, 0)), // Adjust the date and time as needed
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('RideAlongs').add(rideAlongData);

      print('Ride along document created successfully.');
    } catch (e) {
      print('Error creating ride along document: $e');
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _markerSubscription?.cancel();
    _customInfoWindowController.dispose();
    _customInfoRideAlongController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
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

      final Path clipPath = Path()
        ..addOval(Rect.fromCircle(center: const Offset(radius, radius), radius: radius));
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

  Future<BitmapDescriptor> createMarkerIcon(String profileUrl, bool isOnline) async {
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
  }

  final ui.Picture picture = pictureRecorder.endRecording();
  final ui.Image markerAsImage = await picture.toImage(
    canvasSize.toInt(),
    canvasSize.toInt(),
  );
  final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
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
    final riderLastTime = doc['timestamp']?.toDate()?.toString() ?? 'N/A';
    final markerType = doc['Type'] as String;
    final isOnline = doc['isOnline'] as bool;

    final BitmapDescriptor markerIcon = await createMarkerIcon(profileImageUrl, isOnline);

    return Marker(
      markerId: markerId,
      position: LatLng(latitude, longitude),
      icon: markerIcon,
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
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 5),
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(profileImageUrl),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                riderUsername,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
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
                                style: TextStyle(color: Colors.white, fontSize: 15),
                              ),
                              Spacer(),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Spacer(),
                              Text(
                                "Last here " + riderLastTime,
                                style: TextStyle(color: Colors.white, fontSize: 15),
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
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 5),
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(profileImageUrl),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                riderUsername,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
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
                                style: TextStyle(color: Colors.white, fontSize: 15),
                              ),
                              Spacer(),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Spacer(),
                              Text(
                                "Start Time " + riderLastTime,
                                style: TextStyle(color: Colors.white, fontSize: 15),
                              ),
                              Spacer(),
                            ],
                          ),
                          SizedBox(height: 5),
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
                  _customInfoWindowController.googleMapController = controller;
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
                top: 50.0,
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

  
