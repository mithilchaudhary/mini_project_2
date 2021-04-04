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

  //Future<List<Map<String, GeoPoint>>>
  Future<List<Map<String, dynamic>>> getFriends() async {
    List<Map<String, dynamic>> info = [];
    info.add({"name": "ham"});
    await _firestore
        .collection('friends')
        .doc('lUb3VEzLQsqxxEhwO3nU')
        .collection('friends')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        print("hello " + element.id.toString());
        await _userRef.doc(element.id).get().then((value) {
          info.add(value.data());
        });
      });
    });
    return info;
  }
}
