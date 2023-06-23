import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:journey2/constants.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  //Starting Variables

  //Start with the icon for the current Marker
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  //Update the icon to the current user profile
  void addCustomIcon() {
    // BitmapDescriptor.fromBytes()
  }

  Widget _mapScreen() {
    var username = FirebaseAuth.instance.currentUser?.displayName;
    var currentPos =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);

    return GoogleMap(
      buildingsEnabled: true,
      mapToolbarEnabled: true,
      liteModeEnabled: false,
      rotateGesturesEnabled: true,
      compassEnabled: true,
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: currentPos,
        zoom: 14.0,
      ),
      myLocationEnabled: true,
      markers: const {
        // Marker(
        //   markerId: const MarkerId('CurrentLocation'),
        //   position:
        //       LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        //   infoWindow: InfoWindow(title: username),
        // ),
      },
      circles: {
        Circle(
            circleId: CircleId("1"),
            center: currentPos,
            radius: 750,
            strokeWidth: 2,
            fillColor: Color(0xFF006491).withOpacity(0.2))
      },
    );
  }

  int _selectedIndex = 2;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  // ignore: prefer_final_fields

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late GoogleMapController _controller;
  final LatLng _center = const LatLng(37.4219999, -122.0840575);
  final Location _location = Location();
  LocationData? currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;

  void getCurrentLocation() {
    Location location = Location();
    location.getLocation().then((value) {
      print("Obtained Location");
      currentLocation = value;
      setState(() {
        currentLocation = value;
      });
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription =
        _location.onLocationChanged.listen((LocationData currentLocation) {
      _controller.animateCamera(CameraUpdate.newLatLng(
          LatLng(currentLocation.latitude!, currentLocation.longitude!)));
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
