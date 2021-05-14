import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String dname = '';
  String uid = FirebaseAuth.instance.currentUser.uid;
  String email = FirebaseAuth.instance.currentUser.email;

  @override
  Widget build(BuildContext context) {
    Future changeName() async {
      int f = 3;
      CollectionReference _userRef =
          FirebaseFirestore.instance.collection('users');
      Query q = _userRef.where('dname', isEqualTo: dname);
      await q.get().then((QuerySnapshot qs) {
        if (qs.docs.length > 1) {
          f = 0;
        } else
          f = 1;
      });
      if (f == 0) return 0;
      if (f == 1) {
        await _userRef.doc(uid).update({'dname': dname});
        return 1;
      }
    }

    Future<void> showDnameialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Enter a new Display Name for your profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            content: SingleChildScrollView(
              child: TextField(
                onChanged: (value) => dname = value,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    hintText: "Display Name*",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0))),
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
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
                  onPressed: () async {
                    Navigator.of(context).pop();
                    int status = await changeName();
                    if (status == 1) {
                      await showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Name changed successfully.',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            );
                          });
                    } else
                      await showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                  'That name already exists, please try again.',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            );
                          });
                  },
                  child: Text('OK', style: TextStyle(color: Colors.white)))
            ],
          );
        },
      );
    }

    final cnameButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.amber,
        child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () async {
            await showDnameialog();
          },
          child: Text(
            "Change Display Name",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ));
    final cpassButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.amber,
        child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () async {
            await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

            await showDialog(
                barrierDismissible: true,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                        'A link to change your password has been sent to your registered Email.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  );
                });
          },
          child: Text(
            "Change Password",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ));
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              cnameButton,
              SizedBox(
                height: 10,
              ),
              cpassButton
            ],
          ),
        ),
      ),
    );
  }
}
