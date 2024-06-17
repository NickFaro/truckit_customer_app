import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  Location _locationController = new Location();

  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  LatLng? _currentP = null;

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }

  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null 
        ? const Center(
          child: Text("Loading..."),
        ) 
      : GoogleMap(
        onMapCreated: ((GoogleMapController controller) => _mapController.complete(controller)),
          initialCameraPosition: CameraPosition(
            target: _pGooglePlex, 
            zoom: 13,
          ),
          markers: {
            Marker(
              markerId: MarkerId("_currentLocation"),
              icon: BitmapDescriptor.defaultMarker,
              position: _currentP!)
          }
        ),
    );
  }

  Future<void> _cameraToPostion(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos, 
      zoom: 15,
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        setState(() {
          _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPostion(_currentP!);
        });
      }
    });
  }

}