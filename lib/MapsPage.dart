import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Maps extends StatefulWidget {
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  double latitudedata;
  double longitudedata;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  getCurrentLocation() async {
    final geoposition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitudedata = geoposition.latitude;
      longitudedata = geoposition.longitude;
    });
  }

  GoogleMapController mapController;
  //Hardcoded Latitude Longitude value, should be changed to user's current location. //implemented
  // final LatLng _center = const LatLng(19.1125112, 72.93308);
  //List of markers for all the friends.
  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    //Whenever new friend is added '_markers' set should be updated here.
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('val-1'),
          position: LatLng(latitudedata, longitudedata),
          infoWindow: InfoWindow(title: 'My house', snippet: 'just my house')));
    });
  }

  @override
  Widget build(BuildContext context) {
    getCurrentLocation();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.replay),
        backgroundColor: Colors.red[800],
        mini: true,
        onPressed: () {
          _onMapCreated(mapController);
        },
      ),
      body: GoogleMap(
        zoomControlsEnabled: false,
        onMapCreated: _onMapCreated,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(latitudedata, longitudedata),
          zoom: 11.0,
        ),
      ),
    );
  }
}
