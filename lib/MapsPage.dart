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
  List<Marker> _resMarkers = [];
  List<Marker> _friendMarkers = [];

  //custom marker for restaurants.
  BitmapDescriptor resMarker;

  int placeChoice = -1;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getAllFriends();
    setResMarker();
    getAllRestaurants(placeChoice);
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
      _friendMarkers = [
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
    var n = _friendMarkers.length;

    for (var i = 0; i < n; i++) {
      centLat += _friendMarkers[i].position.latitude;
      centLong += _friendMarkers[i].position.longitude;
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
    int n = _resMarkers.length;
    double radius = 0;
    for (var i = 0; i < n; i++) {
      double tempRad = Geolocator.distanceBetween(
              _center.latitude,
              _center.longitude,
              _resMarkers[i].position.latitude,
              _resMarkers[i].position.longitude)
          .toDouble();
      if (tempRad > radius) {
        radius = tempRad;
      }
    }
    return radius;
  }

  getAllRestaurants(int placeChoice) async {
    LatLng center = getCenterLocation();

    // var base =
    //     'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${center.latitude},${center.longitude}';
    var url = '';
    if (placeChoice == 0) {
      url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${center.latitude},${center.longitude}&keyword=restaurant&radius=500&type=restaurant&opennow=true&minprice=2&key=AIzaSyA6nnUoGCwJeuKUsnssd8S_PHvCtGOfsA8';
    } else if (placeChoice == 1) {
      url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${center.latitude},${center.longitude}&radius=500&type=cafe&key=AIzaSyA6nnUoGCwJeuKUsnssd8S_PHvCtGOfsA8';
    } else if (placeChoice == 2) {
      url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${center.latitude},${center.longitude}&radius=500&type=shopping_mall&key=AIzaSyA6nnUoGCwJeuKUsnssd8S_PHvCtGOfsA8';
    }

    var response = await Dio().get(url);
    var result = response.data['results'];
    var len;
    if (result.length >= 5) {
      len = 5;
    } else if (result.length == 0) {
      len = 0;
      print('No restaurants found');
    } else {
      len = result.length;
    }

    _resMarkers = [];
    for (var i = 0; i < len; i++) {
      var restaurant = result[i];
      setState(() {
        _resMarkers.add(Marker(
          markerId: MarkerId(restaurant['place_id']),
          position: LatLng(restaurant['geometry']['location']['lat'],
              restaurant['geometry']['location']['lng']),
          icon: resMarker,
          infoWindow: InfoWindow(
              title: restaurant['name'],
              snippet: restaurant['rating'].toString()),
        ));
      });
    }
    print(_resMarkers);
  }

  void setResMarker() async {
    resMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/cutlery.png');
  }

  void _onRestaurantPressed() {
    setState(() {
      placeChoice = 0;
      getAllRestaurants(placeChoice);
    });

    print(placeChoice);
  }

  void _onCafePressed() {
    setState(() {
      placeChoice = 1;
      getAllRestaurants(placeChoice);
    });

    print(placeChoice);
  }

  void _onMallPressed() {
    setState(() {
      placeChoice = 2;
      getAllRestaurants(placeChoice);
    });

    print(placeChoice);
  }

  GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    //Setting user marker when map is created.
    setState(() {
      _friendMarkers.add(Marker(
          markerId: MarkerId('val-1'),
          position: LatLng(latitudedata, longitudedata),
          infoWindow: InfoWindow(title: 'Chirag', snippet: 'home')));
    });
  }

  Widget button(Function function, IconData icon) {
    // return FloatingActionButton(
    //   onPressed: function,
    //   materialTapTargetSize: MaterialTapTargetSize.padded,
    //   backgroundColor: Colors.amber,
    //   child: Icon(
    //     icon,
    //     size: 28.0,
    //   ),
    // );
    return Transform.scale(
      scale: .85,
      child: FloatingActionButton(
        onPressed: function,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: Colors.amber,
        child: Icon(
          icon,
          size: 28.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.replay),
          backgroundColor: Colors.cyan,
          mini: true,
          onPressed: () {
            setState(() {});
          },
        ),
        body: Stack(children: <Widget>[
          GoogleMap(
            zoomControlsEnabled: false,
            onMapCreated: _onMapCreated,
            markers: (_resMarkers + _friendMarkers).toSet(),
            initialCameraPosition: CameraPosition(
              target: LatLng(latitudedata, longitudedata),
              zoom: 11.0,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  button(_onRestaurantPressed, Icons.restaurant),
                  SizedBox(
                    height: 16.0,
                  ),
                  button(_onCafePressed, Icons.local_cafe),
                  SizedBox(
                    height: 16.0,
                  ),
                  button(_onMallPressed, Icons.local_mall),
                ],
              ),
            ),
          )
        ]));
  }
}
