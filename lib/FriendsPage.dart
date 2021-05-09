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
  String myname;
  String addname;
  int flag = 0;
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
    await _userRef.doc(uid).get().then((value) => myname = value['dname']);
    await _firestore
        .collection('friends')
        .doc(uid)
        .collection('requests')
        .get()
        .then((QuerySnapshot querySnapshot) {
      pendingReq = querySnapshot.docs.length;
    });

    await _firestore
        .collection('friends')
        .doc(uid)
        .collection('friends')
        .get()
        .then((querySnapshot) async {
      querySnapshot.docs.forEach((element) async {
        print(element.id);
        await _userRef.doc(element.id).get().then((value) {
          print(value.data()['dname']);
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
          onPressed: () async {
            final _formState = _formKey.currentState;
            if (_formState.validate()) {
              _formState.save();
              Query q = _userRef.where('dname', isEqualTo: addname.trim());
              await q.get().then((QuerySnapshot qs) async {
                if (qs.docs.isNotEmpty) {
                  await _friendsRef
                      .doc(qs.docs[0].id)
                      .collection('requests')
                      .doc(uid)
                      .set({'dname': myname});
                  await showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Request sent successfully',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                        );
                      });
                }
              });

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

    Future<void> confirmFriendDelete() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Are you sure you want to delete this friend?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    flag = 0;
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  )),
              TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    flag = 1;
                  },
                  child: Text('Yes', style: TextStyle(color: Colors.white)))
            ],
          );
        },
      );
    }

    listofriends() {
      return ListView.separated(
          itemCount: info.length,
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
                onDismissed: (direction) async {
                  Map m = info.removeAt(index);

                  Query q = _userRef.where('dname', isEqualTo: m['dname']);
                  await q.get().then((QuerySnapshot qsnap) async {
                    await _friendsRef
                        .doc(uid)
                        .collection('friends')
                        .doc(qsnap.docs[0].id)
                        .delete();
                    //friend who got deleted
                    await _friendsRef
                        .doc(qsnap.docs[0].id)
                        .collection('friends')
                        .doc(uid)
                        .delete();
                  });
                },
                confirmDismiss: (direction) async {
                  await confirmFriendDelete();
                  if (flag == 1) return true;
                  return false;
                },
                background: Container(
                  color: Colors.red,
                ),
                key: ValueKey<Map>(info[index]),
                child: Container(
                  height: 40,
                  child: ListTile(
                    onLongPress: () {},
                    enabled: true,
                    title: Text(
                      info[index]['dname'],
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ));
          },
          separatorBuilder: (BuildContext context, int index) => Divider());
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
                  info.isEmpty ? fpButton : Expanded(child: listofriends()),
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
