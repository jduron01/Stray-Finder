import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class Waypoint extends StatefulWidget {
  final LatLng destination;
  final Null Function(LatLng selectedLocation) onLocationSelected;

  const Waypoint({
    Key? key,
    required this.destination,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<Waypoint> createState() => _WaypointState();
}

class _WaypointState extends State<Waypoint> {
  late double currentLatitude = 0.0;
  late double currentLongitude = 0.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error getting current location: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentLatitude == 0.0 || currentLongitude == 0.0) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(currentLatitude, currentLongitude),
        initialZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [
                LatLng(currentLatitude, currentLongitude),
                widget.destination,
              ],
              color: Colors.blue,
              strokeWidth: 3.0,
            ),
          ],
        ),
      ],
    );
  }
}
