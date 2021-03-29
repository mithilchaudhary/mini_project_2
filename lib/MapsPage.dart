import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

class Maps extends StatefulWidget {
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  //user latitude, longitude
  double latitudedata;
  double longitudedata;

  //List of markers for all the friends.
  List<Marker> _markers = [];

  //custom marker for restaurants.
  BitmapDescriptor resMarker;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getAllFriends();
    setResMarker();
    getAllRestaurants();
  }

  Future<LatLng> getCurrentLocation() async {
    final geoposition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitudedata = geoposition.latitude;
      longitudedata = geoposition.longitude;
    });

    return LatLng(latitudedata, longitudedata);
  }

  getAllFriends() {
    setState(() {
      //Fake sample data, should be replaced with data provided by addFriendsPage(mithil).
      _markers = [
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
            infoWindow: InfoWindow(title: 'Hamaza', snippet: 'just my house')),
        Marker(
            markerId: MarkerId('val-5'),
            position: LatLng(19.11081101698239, 72.83717735727085),
            infoWindow: InfoWindow(title: 'Atharva', snippet: 'just my house')),
      ];
    });
  }

  //finds center location from friends list.
  LatLng getCenterLocation() {
    double centLat = 0;
    double centLong = 0;
    var n = _markers.length;

    for (var i = 0; i < n; i++) {
      centLat += _markers[i].position.latitude;
      centLong += _markers[i].position.longitude;
    }
    centLat /= n;
    centLong /= n;
    if (centLat == 0 && centLong == 0) {
      centLat = latitudedata;
      centLong = longitudedata;
    }
    return LatLng(centLat, centLong);
  }

  //radius of circle from center location to farthest friend.
  double getSearchRadius() {
    LatLng _center = getCenterLocation();
    int n = _markers.length;
    double radius = 0;
    for (var i = 0; i < n; i++) {
      double tempRad = Geolocator.distanceBetween(
              _center.latitude,
              _center.longitude,
              _markers[i].position.latitude,
              _markers[i].position.longitude)
          .toDouble();
      if (tempRad > radius) {
        radius = tempRad;
      }
    }
    return radius;
  }

  getAllRestaurants() async {
    LatLng center = getCenterLocation();

    // ignore: todo
    //TODO: send get request using proper parameters
    var url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${center.latitude},${center.longitude}&keyword=restaurant&radius=500&type=restaurant&opennow=true&minprice=2&key=AIzaSyA6nnUoGCwJeuKUsnssd8S_PHvCtGOfsA8';
    var response = await Dio().get(url);
    var result = response.data['results'];

    for (var i = 0; i < 5; i++) {
      var restaurant = result[i];
      _markers.add(Marker(
        markerId: MarkerId(restaurant['place_id']),
        position: LatLng(restaurant['geometry']['location']['lat'],
            restaurant['geometry']['location']['lng']),
        icon: resMarker,
        infoWindow: InfoWindow(
            title: restaurant['name'],
            snippet: restaurant['rating'].toString()),
      ));
    }
  }

  void setResMarker() async {
    resMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/cutlery.png');
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
          getAllRestaurants();
        },
      ),
      body: GoogleMap(
        zoomControlsEnabled: false,
        onMapCreated: _onMapCreated,
        markers: _markers.toSet(),
        initialCameraPosition: CameraPosition(
          target: LatLng(latitudedata, longitudedata),
          zoom: 11.0,
        ),
      ),
    );
  }
}
