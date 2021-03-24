import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Maps extends StatefulWidget {
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  //user latitude, longitude
  double latitudedata;
  double longitudedata;

  //List of markers for all the friends.
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getAllFriends();
  }

  getCurrentLocation() async {
    final geoposition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitudedata = geoposition.latitude;
      longitudedata = geoposition.longitude;
    });
  }

  getAllFriends() {
    setState(() {
      //Fake sample data, should be replaced with data provided by addFriendsPage(mithil).
      _markers = {
        Marker(
            markerId: MarkerId('val-2'),
            position: LatLng(19.11969264069933, 72.90916799688964),
            infoWindow: InfoWindow(title: 'Nehal', snippet: 'just my house')),
        Marker(
            markerId: MarkerId('val-3'),
            position: LatLng(19.102499403988425, 72.91723608145941),
            infoWindow: InfoWindow(title: 'Mithil', snippet: 'just my house')),
        Marker(
            markerId: MarkerId('val-4'),
            position: LatLng(19.120665789310753, 72.87861227234882),
            infoWindow: InfoWindow(title: 'Hamaza', snippet: 'just my house'))
      };
    });
  }

  GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    //Setting user marker when map is created.
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('val-1'),
          position: LatLng(latitudedata, longitudedata),
          infoWindow: InfoWindow(title: 'Chirag', snippet: 'home')));
    });
  }

  @override
  Widget build(BuildContext context) {
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
