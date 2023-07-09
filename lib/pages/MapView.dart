import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void initMarker(specify, specifyId) async {
    var markerIdVal = specifyId;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(
            specify['latitude'].latitude, specifyId['longitude'].longitude

            ///InfoWindow(title: )
            ));
    setState(() {
      markers[markerId] = marker;
    });
  }

  getMarkerData() async {
    FirebaseFirestore.instance
        .collection('UserLocation')
        .get()
        .then((myLocationData) {
      if (myLocationData.docs.isNotEmpty) {
        for (int i = 0; i < myLocationData.docs.length; i++) {
          initMarker(
              myLocationData.docs[i].data, myLocationData.docs[i].data());
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    getMarkerData();
    super.initState();
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
    );
  }
}
