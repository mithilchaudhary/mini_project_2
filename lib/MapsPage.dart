import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class Maps extends StatefulWidget {
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  GoogleMapController mapController;

  //Hardcoded Latitude Longitude value, should be changed to user's current location.
  final LatLng _center = const LatLng(19.112461, 72.933177);

  //List of markers for all the friends.
  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    //Whenever new friend is added '_markers' set should be updated here.
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('val-1'),
          position: _center,
          infoWindow: InfoWindow(title: 'My house', snippet: 'just my house')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
      ),
    );
  }
}
