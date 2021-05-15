import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_services.dart';

class Maps extends StatefulWidget {
  final String uid;
  Maps(this.uid);
  @override
  _MapsState createState() => _MapsState(uid);
}

class _MapsState extends State<Maps> {
  _MapsState(this.uid);

  //user latitude, longitude
  double latitudedata;
  double longitudedata;

  //List of markers for all the friends.
  List<Marker> _resMarkers = [];
  List<Marker> _friendMarkers = [];

  //custom marker for restaurants.
  BitmapDescriptor resMarker;

  // friends info
  List<Map> info = [];

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference _userRef = FirebaseFirestore.instance.collection('users');

  int flag = 0;
  int done = 0;
  int pendingReq;
  String uid;
  String myname;

  int placeChoice = 0;

  Future updateLocation(var latitude, var longitude) async {
    GeoPoint g = new GeoPoint(latitude, longitude);
    await _userRef.doc(uid).update({'loc': g});
  }

  Future getCurrentLocation() async {
    final geoposition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    latitudedata = geoposition.latitude;
    longitudedata = geoposition.longitude;

    await DataService(uid).updateLocation(latitudedata, longitudedata);
    return null;
  }

  Future getDetails() async {
    await _userRef.doc(uid).get().then((value) => myname = value['dname']);
    await _firestore
        .collection('friends')
        .doc(uid)
        .collection('friends')
        .get()
        .then((querySnapshot) async {
      querySnapshot.docs.forEach((element) async {
        await _userRef.doc(element.id).get().then((value) {
          Map m = {'dname': value.data()['dname'], 'loc': value.data()['loc']};
          info.add(m);
        });
      });
    });
    return null;
  }

  Future getAllFriends() async {
    await getDetails();

    for (int i = 0; i < info.length; i++) {
      _friendMarkers.add(Marker(
        markerId: MarkerId(i.toString()),
        position: LatLng(info[i]['loc'].latitude, info[i]['loc'].longitude),
        infoWindow: InfoWindow(
            title: info[i]['dname'], snippet: 'Friend ' + (i + 1).toString()),
      ));
    }
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

  Future setResMarker() async {
    resMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/resnew.png');
  }

  Future getAllRestaurants(int placeChoice) async {
    LatLng center = getCenterLocation();
    var base =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${center.latitude},${center.longitude}&';
    var url = '';
    if (placeChoice == 0) {
      url = base +
          'keyword=restaurant&radius=500&type=restaurant&opennow=true&minprice=2&key=AIzaSyA6nnUoGCwJeuKUsnssd8S_PHvCtGOfsA8';
    } else if (placeChoice == 1) {
      url = base +
          'radius=500&type=cafe&key=AIzaSyA6nnUoGCwJeuKUsnssd8S_PHvCtGOfsA8';
    } else if (placeChoice == 2) {
      url = base +
          'radius=500&type=shopping_mall&key=AIzaSyA6nnUoGCwJeuKUsnssd8S_PHvCtGOfsA8';
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
      _resMarkers.add(Marker(
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

  void _onRestaurantPressed() {
    setState(() {
      placeChoice = 0;
      getAllRestaurants(placeChoice);
    });
  }

  void _onCafePressed() {
    setState(() {
      placeChoice = 1;
      getAllRestaurants(placeChoice);
    });
  }

  void _onMallPressed() {
    setState(() {
      placeChoice = 2;
      getAllRestaurants(placeChoice);
    });
  }

  GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Setting user marker when map is created.
    setState(() {
      _friendMarkers.add(Marker(
          markerId: MarkerId('val-1'),
          position: LatLng(latitudedata, longitudedata),
          infoWindow: InfoWindow(title: 'Chirag', snippet: 'home')));
    });
  }

  Widget button(Function function, IconData icon) {
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

  Future myFuture() async {
    await getCurrentLocation();
    await getAllFriends();
    await setResMarker();
    await getAllRestaurants(placeChoice);
    done = 1;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: myFuture(),
        builder: (context, somedata) {
          if (done == 1) {
            return Scaffold(
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.replay),
                  backgroundColor: Colors.cyan,
                  mini: true,
                  onPressed: () {},
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
          } else {
            return Container(
                child: Center(
              child: CircularProgressIndicator(),
            ));
          }
        });
  }
}
