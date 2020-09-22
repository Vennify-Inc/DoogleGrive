import 'package:flutter/material.dart';

import 'package:amplify_core/amplify_core.dart';

import 'login.dart';

class Confirm extends StatefulWidget {
  final String username;

  const Confirm({Key key, @required this.username}) : super(key: key);

  @override
  ConfirmState createState() => ConfirmState();
}

class ConfirmState extends State<Confirm> {
  String code;

  confirmUser() async {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Stack(children: <Widget>[
        Center(
            child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                onChanged: (text) {
                  code = text;
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                    hintText: 'Enter your confirm code here...'),
              ),
            ),
            RaisedButton(onPressed: confirmUser, child: Text("Submit Code")),
            RaisedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => Login()));
              },
              child: Text("Go Back"),
            ),
          ],
        )),
      ])),
    );
  }
}
