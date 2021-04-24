import 'package:cloud_firestore/cloud_firestore.dart';

class DataService {
  final String uid;
  DataService(this.uid);
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference _userRef = FirebaseFirestore.instance.collection('users');

  Future updateLocation(var latitude, var longitude) async {
    print('ye kaha aa gaye hum');
    return await _firestore
        .collection('friends')
        .doc('lUb3VEzLQsqxxEhwO3nU')
        .collection('friends')
        .doc('eyHBWGrNoxSMe8cQUqWC')
        .set({'loc': 'hell'});
  }
}
