import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:miniproj2/newschedule.dart';

class Meetup extends StatefulWidget {
  final Set meetup;
  final List matrix;
  final List result;
  Meetup(this.meetup, this.matrix, this.result);
  @override
  _MeetupState createState() => _MeetupState(meetup, matrix, result);
}

class _MeetupState extends State<Meetup> {
  Set meetup;
  QuerySnapshot qs;
  var matrix;
  var result;
  _MeetupState(this.meetup, this.matrix, this.result);
  String uid = FirebaseAuth.instance.currentUser.uid;
  int done = 0;

  Future getMeets() async {
    qs = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('meets')
        .get();

    done = 1;
    return null;
  }

  Widget listofmeets() {
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.calendar_today,
                    color: Colors.amber,
                  ),
                  title: Text('Meeting at: ' +
                      qs.docs[index]['rname'].toString() +
                      '\nAddress: ' +
                      qs.docs[index]['address'] +
                      '\nDate & Time: ' +
                      qs.docs[index]['date'].toDate().toString()),
                  subtitle:
                      Text('Invited: ' + qs.docs[index]['invited'].toString()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                        child: const Text('Cancel'),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .collection('meets')
                              .doc(qs.docs[index].id)
                              .delete();
                          setState(() {});
                        }),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemCount: qs.docs.length);
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
                builder: (BuildContext context) =>
                    NewSchedule(meetup, matrix, result)));
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
                      qs.docs.length != 0
                          ? Expanded(child: listofmeets())
                          : null,
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          );
        });
  }
}
