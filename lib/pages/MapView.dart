import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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

  Marker initMarker(DocumentSnapshot specify, String userName) {
    final markerId = MarkerId(specify.id);
    final marker = Marker(
      markerId: markerId,
      position: LatLng(
        specify['coordinates']['latitude'],
        specify['coordinates']['longitude'],
      ),
      // Customize the marker as needed (e.g., add an info window)
      infoWindow: InfoWindow(
        title: userName,
        snippet: 'online',
      ),
    );

    return marker;
  }

  void getMarkerData() {
    _markerSubscription = FirebaseFirestore.instance
        .collection('UserLocation')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        markers.clear();
        snapshot.docs.forEach((doc) async {
          final userNameDoc = await FirebaseFirestore.instance
              .collection('Riders')
              .doc(doc.id)
              .get();
          final userName = userNameDoc['userName'] ?? 'No username';
          markers.add(initMarker(doc, userName));
        });
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
        final userName = userNameDoc['userName'] ?? 'No username';

        final Map<String, dynamic> userData = {
          'userId': userId,
          'coordinates': {
            'latitude': _currentLocation!.latitude,
            'longitude': _currentLocation!.longitude,
          },
          'userName': userName, // Add the username to the saved data
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
