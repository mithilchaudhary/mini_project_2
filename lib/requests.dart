import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Requests extends StatefulWidget {
  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  QuerySnapshot querySnapshot;
  int done = 0;
  Future getDetails() async {
    await FirebaseFirestore.instance
        .collection('friends')
        .doc('lUb3VEzLQsqxxEhwO3nU')
        .collection('requests')
        .get()
        .then((QuerySnapshot querSnapshot) {
      querySnapshot = querSnapshot;
      done = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget listofreq() {
      return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemCount: querySnapshot.docs.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
              direction: DismissDirection.endToStart,
              onDismissed: (DismissDirection dismissDirection) {
                querySnapshot.docs.removeAt(index);
                FirebaseFirestore.instance
                    .collection('friends')
                    .doc('lUb3VEzLQsqxxEhwO3nU')
                    .collection('requests')
                    .doc(querySnapshot.docs[index].id)
                    .delete();
              },
              background: Container(
                color: Colors.red,
              ),
              key: ValueKey<DocumentSnapshot>(querySnapshot.docs[index]),
              child: Container(
                  height: 40,
                  child: ListTile(
                    onTap: () => setState(() {
                      FirebaseFirestore.instance
                          .collection('friends')
                          .doc('lUb3VEzLQsqxxEhwO3nU')
                          .collection('requests')
                          .doc(querySnapshot.docs[index].id)
                          .delete();
                    }),
                    enabled: true,
                    title: Text(
                      querySnapshot.docs[index].data()['dname'],
                      style: TextStyle(fontSize: 15),
                    ),
                    trailing: Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                  )));
        },
      );
    }

    return FutureBuilder(
        future: getDetails(),
        builder: (BuildContext context, somedata) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(40),
              child: AppBar(
                centerTitle: true,
                title: Text(
                  'Friend Requests',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.amber,
              ),
            ),
            body: done == 1
                ? (Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text('Tap to accept, swipe left to decline.'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(child: listofreq())
                    ],
                  ))
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          );
        });
  }
}
