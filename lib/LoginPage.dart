import 'package:flutter/material.dart';
import 'session.dart';
import 'dart:convert';

import 'GlobalDetails.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext build) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WhatASap'),
        backgroundColor: Colors.teal,
      ),
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  LoginFormState createState() => new LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  /* Form for login */
  final _formKey = GlobalKey<FormState>();

  /* Controllers for retrieving input credentials */
  final userControl = TextEditingController();
  final passControl = TextEditingController();

  /* Associated login URL */
  final url = ServerDetails.server + "LoginServlet";

  Session session = new Session();
  /* Reference: https://github.com/putraxor/flutter-login-ui */
  @override
  Widget build(BuildContext context) {
    final logo = Padding(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Hero(
        tag: 'hero',
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/whatasap.png'),
        ),
      ),
    );
    final whatasap = Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.0),
        child: Text(
          'WhatASap',
          style: TextStyle(
              fontSize: 28.0, color: Colors.teal,
              fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    final copyright = Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.0),
        child: Text(
            "160050057 , 160050029",
            style: TextStyle(color: Colors.grey),
        ),
      )
    );
    final username = Padding(
      padding: EdgeInsets.all(6.0),
      child: TextFormField(
        controller: userControl,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Username',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
        validator: (value) {
          if(value.isEmpty){
            return 'Empty username not allowed';
          }
        },
      )
    );

    final password = Padding(
      padding: EdgeInsets.all(6.0),
        child: TextFormField(
        controller: passControl,
        autofocus: false,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Password',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
        validator: (value) {
          if(value.isEmpty){
            return 'Empty password not allowed';
          }
        },
      )
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(32.0),
        color: Colors.teal,
        shadowColor: Colors.tealAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: () {
            if(_formKey.currentState.validate()){
              var userId = userControl.text;
              var pass = passControl.text;
              var data = {"userid": userId, "password": pass};
              session.post(url, data).then((response) {
                final resp = json.decode(response);
                if (resp['status']) {
                  User.setUid(userId);
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('Success!')));
                  Navigator.of(context).pushReplacementNamed('/chats');
                }
                else {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Login Failed!')));
                }
              }).catchError((error) => Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('Connection Error!')))
              );
            }
          },
          child: Text('Login', style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.all(0.0),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: new SingleChildScrollView(
              reverse: true,
              child: new Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(left: 24.0, top: 48.0, right: 24.0),
                  children: <Widget>[
                    logo,
                    whatasap,
                    copyright,
                    username,
                    password,
                    loginButton
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}