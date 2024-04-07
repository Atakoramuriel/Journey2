import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class pointData {
  late LatLng point;
  late double pointLat, pointLong;
  pointData(
      {required this.point, required this.pointLat, required this.pointLong});
}
