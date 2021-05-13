import 'package:cloud_firestore/cloud_firestore.dart';

class DataService {
  final String uid;
  DataService(this.uid);

  CollectionReference _userRef = FirebaseFirestore.instance.collection('users');

  Future updateLocation(var latitude, var longitude) async {
    GeoPoint g = new GeoPoint(latitude, longitude);
    await _userRef.doc(uid).update({'loc': g});
    return null;
  }
}
