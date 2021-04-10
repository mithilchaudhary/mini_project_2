import 'package:flutter/material.dart';

import 'category_selector.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {},
        ),
        title: Text('Chat'),
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          CategorySelector(),
        ],
      ),
    );
  }
}
