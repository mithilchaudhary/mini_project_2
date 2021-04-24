import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'requests.dart';
import 'package:miniproj2/database_services.dart';
import 'package:flutter/material.dart';

class Friends extends StatefulWidget {
  final String uid;
  Friends(this.uid);
  @override
  _FriendsState createState() => _FriendsState(uid);
}

class _FriendsState extends State<Friends> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String addname;
  int done = 0;
  int pendingReq;
  final String uid;
  _FriendsState(this.uid);
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference _userRef = FirebaseFirestore.instance.collection('users');
  CollectionReference _friendsRef =
      FirebaseFirestore.instance.collection('friends');
  List<Map> info = [];
  String hehe;

  Future getDetails() async {
    await _firestore
        .collection('friends')
        .doc('lUb3VEzLQsqxxEhwO3nU')
        .collection('requests')
        .get()
        .then((QuerySnapshot querySnapshot) {
      pendingReq = querySnapshot.docs.length;
    });

    await _firestore
        .collection('friends')
        .doc('lUb3VEzLQsqxxEhwO3nU')
        .collection('friends')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        await _userRef.doc(element.id).get().then((value) {
          Map m = {'dname': value.data()['dname'], 'loc': value.data()['loc']};

          info.add(m);
        });
      });

      done = 1;
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final fpButton = TextButton(
      onPressed: () {
        setState(() {});
      },
      child: Text(
        "Tap to show Friends",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.cyan,
            fontSize: 11,
            decoration: TextDecoration.underline),
      ),
    );
    final friendField = TextFormField(
      validator: (value) {
        return value.isEmpty ? 'Please provide a valid name.' : null;
      },
      onSaved: (value) {
        addname = value;
      },
      obscureText: false,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Enter the exact name here",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final addFriendButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.amber,
        child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () {
            final _formState = _formKey.currentState;
            if (_formState.validate()) {
              _formState.save();

              ///CHECK NAME
            }
          },
          child: Text(
            "Send a Request",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ));

    showrequests() {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => Requests()));
    }

    return FutureBuilder(
        future: getDetails(),
        builder: (context, somedata) {
          if (done == 1) {
            return Scaffold(
              body: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            friendField,
                            SizedBox(
                              height: 10,
                            ),
                            addFriendButton
                          ],
                        )),
                  ),
                  Divider(),
                  ListTile(
                    onTap: () => pendingReq == 0 ? null : showrequests(),
                    enabled: true,
                    trailing: Icon(
                      Icons.list,
                      color: Colors.black,
                    ),
                    title: Text(
                      'Pending Requests(' + pendingReq.toString() + ')',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  ListTile(
                    tileColor: Colors.amber,
                    title: Center(
                        child: Text(
                      'Your Friends',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                  ),
                  info.isEmpty
                      ? fpButton
                      : Text(info.toString() + '  ' + uid.toString()),
                ],
              ),
            );
          } else
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
        });
  }
}
