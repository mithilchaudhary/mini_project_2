import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String valueText;
  int pendingReq = 0;
  final String uid;
  _FriendsState(this.uid);
  Future getFrendetails() async {
    List<Map<String, dynamic>> m = await DataService(uid).getFriends();

    return m;
  }

  @override
  Widget build(BuildContext context) {
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
            onTap: () {},
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
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )),
          ),
          FutureBuilder(
              future: getFrendetails(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.toString());
                } else {
                  return CircularProgressIndicator();
                }
              }),
        ],
      ),
    );
  }
}
