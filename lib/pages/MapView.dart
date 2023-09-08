import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _controller;
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  StreamSubscription<QuerySnapshot>? _markerSubscription;

  Set<Marker> markers = {};

  Future<BitmapDescriptor> getBitmapDescriptorFromUrl(String url, int width) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    final frameInfo = await codec.getNextFrame();
    final image = frameInfo.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<Marker> initMarker(DocumentSnapshot specify) async {
    final markerId = MarkerId(specify.id);
    final profileImgUrl = specify['profilemg'] ?? '';

    return Marker(
      markerId: markerId,
      position: LatLng(
        specify['coordinates']['latitude'],
        specify['coordinates']['longitude'],
      ),
      icon: await getBitmapDescriptorFromUrl(profileImgUrl, 80),
      infoWindow: InfoWindow(
        title: specify['username'] ?? 'No username',
        snippet: 'online',
      ),
    );
  }

  void getMarkerData() {
    _markerSubscription = FirebaseFirestore.instance
        .collection('UserLocation')
        .snapshots()
        .listen((QuerySnapshot snapshot) async {
      final newMarkers = <Marker>{};
      final List<Future<Marker>> markerFutures = [];
      for (var doc in snapshot.docs) {
        markerFutures.add(initMarker(doc));
      }
      final allMarkers = await Future.wait(markerFutures);
      newMarkers.addAll(allMarkers);
      setState(() {
        markers = newMarkers;
      });
    });
}


  @override
  void initState() {
    super.initState();
    _initializeLocation().then((_) {
      getMarkerData();
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _markerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    final Location location = Location();

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await location.getLocation();

    _locationSubscription =
        location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
      });
    });
  }

  Future<void> _saveUserLocation() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No user is currently signed in.'),
        ),
      );
      return;
    }

    if (_currentLocation != null) {
      final String userId = user.uid;

      try {
        final CollectionReference userLocationCollection =
            FirebaseFirestore.instance.collection('UserLocation');
        final DocumentReference userLocationDoc =
            userLocationCollection.doc(userId);

        // Fetch the username from the Riders collection
        final userNameDoc = await FirebaseFirestore.instance
            .collection('Riders')
            .doc(userId)
            .get();
        final userName = userNameDoc['username'] ?? 'No username';

        final Map<String, dynamic> userData = {
          'userId': userId,
          'coordinates': {
            'latitude': _currentLocation!.latitude,
            'longitude': _currentLocation!.longitude,
          },
          'userName': userName,
          'timestamp': FieldValue.serverTimestamp(),
        };

        await userLocationDoc.set(userData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User location saved successfully.'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save user location.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Current location data is unavailable.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    _controller = controller;
                  },
                  markers: markers,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentLocation!.latitude ?? 0,
                      _currentLocation!.longitude ?? 0,
                    ),
                    zoom: 14.0,
                  ),
                  myLocationEnabled: true,
                ),
                Positioned(
                  bottom: 70.0,
                  right: 10.0,
                  child: FloatingActionButton(
                    onPressed: _saveUserLocation,
                    child: Icon(Icons.save),
                  ),
                ),
              ],
            ),
    );
  }
}
