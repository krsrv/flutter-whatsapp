import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'ConversationsPage.dart';
import 'Create.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
//  Widget _default = new LoginPage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatASap',
      home: new LoginPage(),
      routes: <String, WidgetBuilder>{
        // Set routes for using the Navigator.
        '/chats': (BuildContext context) => new ConversationsPage(),
        '/login': (BuildContext context) => new LoginPage(),
        '/create': (BuildContext context) => new Create()
      },
    );
  }
}