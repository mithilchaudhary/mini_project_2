import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:miniproj2/authentication_services.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _email, _password, _dname;
  int status = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    Future<void> showErrorDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Alert',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Text(
                'That Display Name already exists or an account already exists for that email. Please try again.',
                style: TextStyle(fontSize: 14),
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.amber),
                  ))
            ],
          );
        },
      );
    }

    Future<void> showDnameialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Enter a Display Name for your profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            content: SingleChildScrollView(
              child: TextField(
                onChanged: (value) => _dname = value,
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
                    status = await context.read<AuthenticationService>().signUp(
                        email: _email,
                        password: _password,
                        dname: _dname.trim());
                    print(status);

                    if (status == 0) {
                      showErrorDialog();
                    }
                  },
                  child: Text('OK', style: TextStyle(color: Colors.white)))
            ],
          );
        },
      );
    }

    final emailField = TextFormField(
      validator: (value) {
        return value.isEmpty ? 'Please provide a valid Email.' : null;
      },
      onSaved: (value) {
        _email = value;
      },
      obscureText: false,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email*",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextFormField(
      validator: (value) {
        if (value.length < 6) {
          return 'Password must be atleast 6 characters';
        } else
          return null;
      },
      onSaved: (value) => _password = value,
      obscureText: true,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password*",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    Future<void> showaDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Alert',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Text('Wrong password provided for that user.'),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.amber),
                  ))
            ],
          );
        },
      );
    }

    final loginButton = Material(
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
              int x = await context
                  .read<AuthenticationService>()
                  .signIn(email: _email, password: _password);
              if (x == 1) {
                showaDialog();
              }
            }
          },
          child: Text(
            "Login",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ));

    final fpButton = TextButton(
      onPressed: () {
        final _formState = _formKey.currentState;

        _formState.save();

        context.read<AuthenticationService>().forgotpass(_email);
      },
      child: Text(
        "Forgot Password?",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.amber,
            fontSize: 11,
            decoration: TextDecoration.underline),
      ),
    );

    final signupButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.cyan,
        child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () {
            final _formState = _formKey.currentState;
            if (_formState.validate()) {
              _formState.save();
              showDnameialog();
            }
          },
          child: Text(
            "Sign-Up",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ));
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            centerTitle: true,
            title: Text(
              'Social Meetup',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.cyan,
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              color: Colors.white,
              child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 155.0,
                          child: Image.asset(
                            "assets/loc.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 45.0),
                        emailField,
                        SizedBox(height: 25.0),
                        passwordField,
                        SizedBox(
                          height: 35.0,
                        ),
                        loginButton,
                        SizedBox(
                          height: 15.0,
                        ),
                        signupButton,
                        SizedBox(
                          height: 15.0,
                        ),
                        fpButton,
                        SizedBox(
                          height: 45,
                        )
                      ],
                    ),
                  )),
            ),
          ),
        ));
  }
}
