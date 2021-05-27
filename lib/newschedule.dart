import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewSchedule extends StatefulWidget {
  final Set meetup;
  final List matrix;
  final List result;
  NewSchedule(this.meetup, this.matrix, this.result);
  @override
  _NewScheduleState createState() => _NewScheduleState(meetup, matrix, result);
}

class _NewScheduleState extends State<NewSchedule> {
  Set meetup;
  List restaurants = [];
  DateTime fixeddate;
  List matrix;
  List result;
  String restovalue;
  List<String> selectedfriends = [];
  List<String> selecteduids = [];
  _NewScheduleState(this.meetup, this.matrix, this.result);
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < result.length; i++) {
      String s = result[i]['name'] +
          " " +
          matrix[0]['elements'][i]['distance']['text'];
      restaurants.add(s);
    }
    restovalue = restaurants[0];
  }

  Widget listoffriends() {
    return ListView.builder(
        itemCount: meetup.length,
        itemBuilder: (context, index) => Container(
              color: selectedfriends.contains(meetup.elementAt(index)['dname'])
                  ? Colors.blue.withOpacity(0.5)
                  : Colors.transparent,
              child: ListTile(
                onTap: () {
                  if (selectedfriends
                      .contains(meetup.elementAt(index)['dname'])) {
                    setState(() {
                      selecteduids.remove(meetup.elementAt(index)['uid']);
                      selectedfriends.removeWhere((element) =>
                          element == meetup.elementAt(index)['dname']);
                    });
                  }
                },
                onLongPress: () {
                  if (!selectedfriends
                      .contains(meetup.elementAt(index)['dname'])) {
                    setState(() {
                      selecteduids.add(meetup.elementAt(index)['uid']);
                      selectedfriends.add(meetup.elementAt(index)['dname']);
                    });
                  }
                },
                title: Text(meetup.elementAt(index)['dname']),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final finalNewButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.cyan,
        child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () async {
            int i = restaurants.indexOf(restovalue);

            await FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser.uid)
                .collection('meets')
                .add({
              'creator': true,
              'rname': result[i]['name'],
              'address': result[i]['vicinity'],
              'invited': selectedfriends,
              'date': fixeddate
            });
            selecteduids.forEach((frienduid) async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(frienduid)
                  .collection('meets')
                  .add({
                'creator': false,
                'rname': result[i]['name'],
                'address': result[i]['vicinity'],
                'invited': selectedfriends,
                'date': fixeddate
              });
            });
            await showDialog(
                barrierDismissible: true,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Meetup Scheduled sucessfully',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  );
                });
            Navigator.of(context).pop();
          },
          child: Text(
            "Done",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ));
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            title: Text(
              'New Meetup',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.amber,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(children: [
            ListTile(
              tileColor: Colors.white,
              title: Center(
                  child: Text(
                'Choose Friends',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              )),
            ),
            Expanded(child: listoffriends()),
            Divider(),
            ListTile(
              tileColor: Colors.white,
              title: Center(
                  child: Text(
                'Choose Restaurant',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              )),
            ),
            Flexible(
              child: Container(
                child: DropdownButton<String>(
                  isExpanded: true,
                  onChanged: (String newValue) {
                    setState(() {
                      restovalue = newValue;
                    });
                  },
                  value: restovalue,
                  items: restaurants.map<DropdownMenuItem<String>>((var value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: Center(
                child: TextButton(
                  child: Text('Choose Date and Time'),
                  onPressed: () {
                    DatePicker.showDateTimePicker(context, onConfirm: (date) {
                      setState(() {
                        fixeddate = date;
                      });
                    }, onChanged: (date) {
                      fixeddate = date;
                    }, minTime: DateTime.now());
                  },
                ),
              ),
            ),
            Container(
                color: Colors.white,
                child: Center(
                  child: Text("Date and Time-" +
                      (fixeddate == null ? "" : fixeddate.toString())),
                )),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: finalNewButton,
            )
          ]),
        ));
  }
}
