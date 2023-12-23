// ignore_for_file: prefer_final_fields

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ignore: must_be_immutable
class MapLoadingScreen extends StatelessWidget {
  double latitude;
  double longitude;
  MapLoadingScreen(
      {super.key, required this.latitude, required this.longitude});

  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(latitude, longitude), // San Francisco coordinates
              zoom: 12.0,
            ),
          ),
          const Center(
            child: SpinKitWave(
              color: Colors.blue, // Customize the color
              size: 50.0, // Adjust the size
            ),
          ),
        ],
      ),
    );
  }
}
