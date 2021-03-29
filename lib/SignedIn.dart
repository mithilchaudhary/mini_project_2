import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:miniproj2/authentication_services.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:miniproj2/MapsPage.dart';
import 'package:miniproj2/AddFriendsPage.dart';
import 'package:miniproj2/ChatPage.dart';
import 'package:miniproj2/SettingsPage.dart';

class SignedIn extends StatefulWidget {
  final String uid;

  SignedIn(this.uid);
  @override
  _SignedInState createState() => _SignedInState();
}

class _SignedInState extends State<SignedIn> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    //Tablist for Pages.
    final tabs = [Maps(), AddFriends(), Chat(), Settings()];
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            centerTitle: true,
            title: Text(
              'Meetup',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red[800],
            actions: [
              IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthenticationService>().signOut();
                  })
            ],
          )),
      //Displaying Tab based on index.
      body: tabs[_index],

      //Bottom Navigation Bar.
      bottomNavigationBar: FloatingNavbar(
        iconSize: 15,
        backgroundColor: Colors.red[800],
        onTap: (int val) => setState(() => _index = val),
        currentIndex: _index,
        //Content for Bottom Navigation Bar.
        items: [
          FloatingNavbarItem(icon: Icons.map_sharp, title: 'Maps'),
          FloatingNavbarItem(icon: Icons.person_add, title: 'Friends'),
          FloatingNavbarItem(icon: Icons.chat_bubble, title: 'Chat'),
          FloatingNavbarItem(icon: Icons.settings, title: 'Settings'),
        ],
      ),
    );
  }
}
