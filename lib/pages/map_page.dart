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
  final Set<Marker> _markers = {};

  //Lista de marcadores
  final List<LatLng> _markerLocations = [];

  final Location _locationController = new Location();

  late BitmapDescriptor myIcon;

  LatLng? _currentP = null;

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)),
            'assets/images/user.png')
        .then((onValue) {
      myIcon = onValue;
    });
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🌎 Coolest map")),
      body: Stack(
        children: [
          _currentP == null
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
                      _markerLocations.add(location);
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
          Expanded(
              child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: _markerLocations.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(
                  'Marker ${index + 1}',
                  style: const TextStyle(
                      backgroundColor: Colors.blueAccent,
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                    'Lat: ${_markerLocations[index].latitude}, Lng: ${_markerLocations[index].longitude}'),
              );
            },
          ))
        ],
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
