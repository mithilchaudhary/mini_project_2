import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class NewSchedule extends StatefulWidget {
  final Set meetup;
  NewSchedule(this.meetup);
  @override
  _NewScheduleState createState() => _NewScheduleState(meetup);
}

class _NewScheduleState extends State<NewSchedule> {
  Set meetup;
  _NewScheduleState(this.meetup);
  Widget listoffriends() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
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
          Container(
            height: 30,
            child: ListTile(
              tileColor: Colors.white,
              title: Center(
                  child: Text(
                'Choose Friends',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              )),
            ),
          ),
          //listoffriends(),
          Divider(),
          Container(
            height: 30,
            child: ListTile(
              tileColor: Colors.white,
              title: Center(
                  child: Text(
                'Choose Restaurant',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              )),
            ),
          ),
          Container(
            child: DropdownButton(
              items: [
                DropdownMenuItem(child: Text('Restaurant1')),
                DropdownMenuItem(child: Text('Restaurant2'))
              ],
            ),
          ),
          Container(
            child: Center(
              child: TextButton(
                child: Text('Choose Time'),
                onPressed: () {
                  DatePicker.showDateTimePicker(context,
                      minTime: DateTime.now());
                },
              ),
            ),
          )
        ]),
      ),
    );
  }
}
