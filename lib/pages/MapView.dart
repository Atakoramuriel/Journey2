import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
      final int size = 120; // Size of the marker
      final Paint paint = Paint();
      final double radius = size / 2;

      // Draw the circle
      paint.color = Colors.white;
      canvas.drawCircle(Offset(radius, radius), radius, paint);

      // Clip the image to a circle and draw it
      final Path clipPath = Path()..addOval(Rect.fromCircle(center: Offset(radius, radius), radius: radius - 10));
      canvas.clipPath(clipPath);
      canvas.drawImage(image, Offset.zero, paint);

      // Convert canvas to image
      final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(size, size);
      final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      print("Error fetching or processing marker image: $e");
      // Return a default marker if there's an error
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

      // Fetch the profile image URL for the user from the Riders collection
      final DocumentSnapshot riderDoc = await FirebaseFirestore.instance.collection('Riders').doc(userId).get();
      final profileImageUrl = riderDoc['profileImg'] as String;

      final markerImage = await getMarker(profileImageUrl);

      return Marker(
        markerId: markerId,
        position: LatLng(latitude, longitude),
        icon: BitmapDescriptor.fromBytes(markerImage),
        infoWindow: InfoWindow(
          title: riderDoc['userName'] as String,
          snippet: 'Last updated: ${doc['timestamp'].toDate()}',
        ),
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
      if (snapshot.docs.isEmpty) {
        print('No documents found in UserLocation collection.');
      } else {
        print('Found ${snapshot.docs.length} documents in UserLocation collection.');
      }

      // Use a temporary set to store markers until all have been created
      Set<Marker> tempMarkers = {};

      Future.wait(snapshot.docs.map((doc) async {
        var marker = await initMarker(doc);
        if (marker != null) {
          tempMarkers.add(marker);
        }
      })).then((_) {
        // Once all markers are ready, update the state to display them
        setState(() {
          markers = tempMarkers;
        });
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
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _markerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: markers,
            initialCameraPosition: CameraPosition(
              target: _currentLocation != null
                  ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
                  : LatLng(37.4219999, -122.0840575), // Default to GooglePlex
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_currentLocation != null)
            Positioned(
              bottom: 70.0,
              right: 10.0,
              child: FloatingActionButton(
                onPressed: _saveUserLocation,
                child: const Icon(Icons.save),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveUserLocation() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No user is currently signed in.')));
      return;
    }

    if (_currentLocation != null) {
      final String userId = user.uid;
      final CollectionReference userLocationCollection = FirebaseFirestore.instance.collection('UserLocation');
      final DocumentReference userLocationDoc = userLocationCollection.doc(userId);

      try {
        final userNameDoc = await FirebaseFirestore.instance.collection('Riders').doc(userId).get();
        final userName = userNameDoc['userName'] ?? 'No username';

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User location saved successfully.')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save user location: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current location data is unavailable.')));
    }
  }
}
