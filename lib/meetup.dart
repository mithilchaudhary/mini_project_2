import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Meetup extends StatefulWidget {
  @override
  _MeetupState createState() => _MeetupState();
}

class _MeetupState extends State<Meetup> {
  String uid = FirebaseAuth.instance.currentUser.uid;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference _userRef = FirebaseFirestore.instance.collection('users');
  List<Map> info = [];
  int done = 0;

  Future getMeets() async {
    await _firestore
        .collection('friends')
        .doc(uid)
        .collection('friends')
        .get()
        .then((querySnapshot) async {
      querySnapshot.docs.forEach((element) async {
        await _userRef.doc(element.id).get().then((value) {
          Map m = {'dname': value.data()['dname'], 'uid': element.id};
          info.add(m);
        });
      });
    });
    done = 1;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheduleNewButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.cyan,
        child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () async {},
          child: Text(
            "Schedule a New Meetup",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ));
    return FutureBuilder(
        future: getMeets(),
        builder: (BuildContext context, somedata) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(40),
              child: AppBar(
                centerTitle: true,
                title: Text(
                  'Schedule',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.amber,
              ),
            ),
            body: done == 0
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [
                      Padding(
                          child: scheduleNewButton,
                          padding: const EdgeInsets.all(20)),
                      Divider(),
                      ListTile(
                        tileColor: Colors.amber,
                        title: Center(
                            child: Text(
                          'Upcoming Meetups',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                      ),
                    ],
                  ),
          );
        });
  }
}
