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
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  //Marcadores definidos por el usuario
  Set<Marker> _markers = {};

  //Lista de marcadores
  List<LatLng> _markerLocations = [];

  Location _locationController = new Location();

  late BitmapDescriptor myIcon;

  LatLng? _currentP = null;

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(48, 48)), 'assets/images/user.png')
        .then((onValue) {
      myIcon = onValue;
    });
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null
          ? const Center(
              child: Text("Loading :)"),
            )
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _currentP!,
                zoom: 13,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
              onTap: (LatLng location) {
                setState(() {
                  _markers.add(
                    Marker(
                      markerId: MarkerId(location.toString()),
                      position: location,
                    ),
                  );
                });
              },
              markers: {
                Marker(
                    markerId: MarkerId("_currentLocation"),
                    icon: myIcon,
                    position: _currentP!),
                ..._markers
              },
            ),
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

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }
}
