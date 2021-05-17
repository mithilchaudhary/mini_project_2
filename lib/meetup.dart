import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:miniproj2/newschedule.dart';

class Meetup extends StatefulWidget {
  final Set meetup;
  Meetup(this.meetup);
  @override
  _MeetupState createState() => _MeetupState(meetup);
}

class _MeetupState extends State<Meetup> {
  Set meetup;
  _MeetupState(this.meetup);
  String uid = FirebaseAuth.instance.currentUser.uid;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference _userRef = FirebaseFirestore.instance.collection('users');

  int done = 1;

  Future getMeets() async {
    await _firestore
        .collection('friends')
        .doc(uid)
        .collection('friends')
        .get()
        .then((querySnapshot) async {
      querySnapshot.docs.forEach((element) async {
        await _userRef.doc(element.id).get().then((value) {
          //Map m = {'dname': value.data()['dname'], 'uid': element.id};
          //info.add(m);
          //print(m.toString());
        });
      });
      done = 1;
    });

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
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => NewSchedule(meetup)));
          },
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
            body: done == 1
                ? Column(
                    children: [
                      Padding(
                          child: scheduleNewButton,
                          padding: const EdgeInsets.all(20)),
                      ListTile(
                        tileColor: Colors.cyan,
                        title: Center(
                            child: Text(
                          'Upcoming Meetups',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                      ),
                      Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const ListTile(
                              leading: Icon(
                                Icons.calendar_today,
                                color: Colors.amber,
                              ),
                              title: Text(
                                  'Meeting at: chirag restaurant\nAddress:chirag road,chirag(w),pincode-chirag'),
                              subtitle:
                                  Text('Invited: maniac1, maniac2, maniac3'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {/* ... */},
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          );
        });
  }
}
