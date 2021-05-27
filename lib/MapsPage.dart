import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miniproj2/meetup.dart';
import 'database_services.dart';
import 'package:dart_numerics/dart_numerics.dart' as numerics;
import 'package:google_map_polyline/google_map_polyline.dart';

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

  // friends info from getDetails method(firebase).
  List<Map> info = [];
  Set<Map> infoSet = new Set();

  //result from distancematrix api
  var matrix;

  //result from places api(restaurants)
  var result = [];

  //List and sets for polyline.
  final Set<Polyline> polyline = {};
  List<LatLng> routeCoords;
  GoogleMapPolyline googleMapPolyline =
      new GoogleMapPolyline(apiKey: "AIzaSyA6nnUoGCwJeuKUsnssd8S_PHvCtGOfsA8");

  //references for firebase requests.
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference _userRef = FirebaseFirestore.instance.collection('users');

  //done will be set when all the async fuctions are called. done variable is in widget builder.
  int done = 0;

  //uid and name of the current user.
  String uid;
  String myname;

  //no of restaurants being displayed on the map.
  var len;

  //making choice for places. {0: restaurant, 1: cafe, 2:mall}.
  int placeChoice = 0;

  //for updating current user location to database.
  Future updateLocation(var latitude, var longitude) async {
    GeoPoint g = new GeoPoint(latitude, longitude);
    await _userRef.doc(uid).update({'loc': g});
  }

  // for getting current location of user.
  Future getCurrentLocation() async {
    final geoposition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    latitudedata = geoposition.latitude;
    longitudedata = geoposition.longitude;

    await DataService(uid).updateLocation(latitudedata, longitudedata);
    // print("111111111111111111111111");
    return null;
  }

  // for filtering dupicates from info list.
  filterDuplicates() {
    for (var friend in info) {
      if (infoSet.any((e) => e['dname'] == friend['dname'])) {
        continue;
      }
      infoSet.add(friend);
    }
  }

  //for fetching user's friends from databse.
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
          Map m = {
            'dname': value.data()['dname'],
            'loc': value.data()['loc'],
            'uid': element.id
          };
          info.add(m);
        });
      });
    });
    filterDuplicates();
    // print("2222222222222222222222222222222222");

    return null;
  }

  //for finding center location out of all friends.
  LatLng getCenterLocation() {
    double centLat = latitudedata;
    double centLong = longitudedata;
    var n = infoSet.length;

    for (var i = 0; i < n; i++) {
      centLat += infoSet.elementAt(i)['loc'].latitude;
      centLong += infoSet.elementAt(i)['loc'].longitude;
    }
    centLat /= n + 1;
    centLong /= n + 1;
    if (centLat == 0 && centLong == 0) {
      centLat = latitudedata;
      centLong = longitudedata;
    }
    return LatLng(centLat, centLong);
  }

  //for fetching restaurants from places api.
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
    result = response.data['results'];
    if (result.length >= 5) {
      len = 5;
    } else if (result.length == 0) {
      len = 0;
      print('No restaurants found');
    } else {
      len = result.length;
    }

    result = result.sublist(0, len);

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
    // print("33333333333333333333333333333333");
  }

  //for fetching distance details from distancemartrix api.
  Future getDistanceMatrix() async {
    var base = 'https://maps.googleapis.com/maps/api/distancematrix/json?';
    String origins = '&origins=$latitudedata,$longitudedata|';
    String dest = '&destinations=';
    String key = '&key=AIzaSyA6nnUoGCwJeuKUsnssd8S_PHvCtGOfsA8';

    int n = infoSet.length;

    for (int i = 0; i < n; i++) {
      var friend = infoSet.elementAt(i)['loc'];
      // print(friend['dname']);
      origins += '${friend.latitude},${friend.longitude}';
      if (i != n - 1) origins += '|';
    }
    for (int i = 0; i < len; i++) {
      var restaurant = result[i]['geometry']['location'];
      dest += '${restaurant['lat']},${restaurant['lng']}';
      if (i != len - 1) dest += '|';
    }
    // print(len);

    var url = base + origins + dest + key;
    // print(url);
    var response = await Dio().get(url);
    matrix = response.data['rows'];
    print(matrix);
    // print("44444444444444444444444444444444444444");
  }

  //for finding closest restaurant for any friend.
  List getClosestResDistance(int index) {
    int min = numerics.int64MaxValue;
    int j = -1;
    var row = matrix[index]['elements'];
    for (int i = 0; i < len; i++) {
      if (min > row[i]['distance']['value']) {
        min = row[i]['distance']['value'];
        j = i;
      }
    }

    return [result[j]['name'], row[j]['distance']['text']];
  }

  //for setting friend markers on the map usinf infoSet.
  Future getAllFriends() async {
    for (int i = 0; i < infoSet.length; i++) {
      var friend = infoSet.elementAt(i);

      var data = getClosestResDistance(i + 1);
      // print(friend['dname']);
      _friendMarkers.add(Marker(
        markerId: MarkerId(i.toString()),
        position: LatLng(friend['loc'].latitude, friend['loc'].longitude),
        infoWindow: InfoWindow(
            title: friend['dname'], snippet: '${data[0]}, ${data[1]}'),
      ));
    }
    // print("5555555555555555555555555555555");
  }

  //for setting plyline from user to his closest restaurant.
  Future setPolyline() async {
    int min = numerics.int64MaxValue;
    int j = -1;
    var row = matrix[0]['elements'];
    for (int i = 0; i < len; i++) {
      if (min > row[i]['distance']['value']) {
        min = row[i]['distance']['value'];
        j = i;
      }
      // print(
      //     '${result[i]['name']}, ${row[i]['distance']['text']},  ${row[i]['duration']['text']}');
    }
    routeCoords = await googleMapPolyline.getCoordinatesWithLocation(
        origin: LatLng(latitudedata, longitudedata),
        destination: LatLng(result[j]['geometry']['location']['lat'],
            result[j]['geometry']['location']['lng']),
        mode: RouteMode.driving);

    polyline.add(Polyline(
        polylineId: PolylineId('route1'),
        visible: true,
        points: routeCoords,
        width: 4,
        color: Colors.blue,
        startCap: Cap.roundCap,
        endCap: Cap.buttCap));
  }

  //custom image for restaurant marker.
  Future setResMarker() async {
    resMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/resnew.png');
  }

  void _onRestaurantPressed() async {
    setState(() {
      placeChoice = 0;
      getAllRestaurants(placeChoice);
      getDistanceMatrix();
      getAllFriends();
      setPolyline();
    });
  }

  void _onCafePressed() {
    setState(() {
      placeChoice = 1;
      getAllRestaurants(placeChoice);
      getDistanceMatrix();
      getAllFriends();
      setPolyline();
    });
  }

  void _onMallPressed() {
    setState(() {
      placeChoice = 2;
      getAllRestaurants(placeChoice);
      getDistanceMatrix();
      getAllFriends();
      setPolyline();
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
          infoWindow: InfoWindow(title: myname, snippet: 'home')));
    });
  }

  void _onMeetupPressed() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => Meetup(infoSet, matrix, result)));
  }

  //button for changing places.
  Widget button(Function function, IconData icon) {
    return Transform.scale(
      scale: .85,
      child: FloatingActionButton(
        heroTag: null,
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
    await getDetails();
    await setResMarker();
    await getAllRestaurants(placeChoice);
    await getDistanceMatrix();
    await getAllFriends();
    await setPolyline();

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
                    polylines: polyline,
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
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: [
                          Transform.scale(
                            scale: .85,
                            child: FloatingActionButton.extended(
                              onPressed: _onMeetupPressed,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              backgroundColor: Colors.blue,
                              label: Text('Your Meetups'),
                            ),
                          )
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
