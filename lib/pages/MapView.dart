import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _controller;
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _initializeLocation() async {
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

    _locationSubscription =
        location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
      });
    });
  }

  Future<void> _saveUserLocation() async {
    if (_currentLocation != null) {
      final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      try {
        final CollectionReference userLocationCollection =
            FirebaseFirestore.instance.collection('UserLocation');
        final DocumentReference userLocationDoc =
            userLocationCollection.doc(userId);

        final Map<String, dynamic> userData = {
          'userId': userId,
          'latitude': _currentLocation!.latitude,
          'longitude': _currentLocation!.longitude,
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
<<<<<<< HEAD
    Size size = MediaQuery.of(context).size;
    var username = FirebaseAuth.instance.currentUser?.displayName.toString();

    return MaterialApp(
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: kPrimaryAccentColor),
      ),
      home: Scaffold(
          body: currentLocation == null
              ? Container(
                  height: size.height,
                  width: size.width,
                  color: Colors.black,
                  child: Column(
                    children: [
                      Spacer(),
                      Text(
                        "Loading",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.08),
                      ),
                      Image.asset(
                        "assets/gifs/VS2.GIF",
                        height: size.width,
                        width: size.width,
                      ),
                      Text(
                        "Map View. . .",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.08),
                      ),
                      Spacer()
                    ],
                  ),
                )
              : _mapScreen()),
=======
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _controller = controller;
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(37.4219999, -122.0840575),
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
>>>>>>> 2425652 (needed)
    );
  }
}
