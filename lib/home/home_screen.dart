import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widget/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _latitude = 0.0;
  double _longitude = 0.0;
  CameraPosition? _initialPosition;
  List<Marker> markerList = [];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      await _getLocation();
    } else if (status.isDenied) {
      await Permission.location.request();
      await _getLocation();
    } else if (status.isPermanentlyDenied) {
      _checkLocationPermission();
    }
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _initialPosition = CameraPosition(
          target: LatLng(_latitude, _longitude),
          zoom: 14,
        );

        markerList = [
          Marker(
            markerId: const MarkerId('First'),
            position: LatLng(_latitude, _longitude),
            infoWindow: const InfoWindow(title: "My location"),
          ),
        ];
      });
    } catch (e) {
      log('Error: $e');
    }
  }

  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initialPosition != null
          ? GoogleMap(
              initialCameraPosition: _initialPosition!,
              mapType: MapType.normal,
              markers: Set<Marker>.of(markerList),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            )
          : Center(
              child: MapLoadingScreen(
                latitude: _latitude,
                longitude: _longitude,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          GoogleMapController controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(_latitude, _longitude), zoom: 17),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}
