import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'easypaisa.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package.dart';
//import 'consultation.dart';

class easypaisa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remedium',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
        title: 'Welcome to Remedium',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String greetings = '';

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: new PreferredSize(
        child: new Container(
          padding: new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: new Padding(
              padding:
              const EdgeInsets.only(left: 30.0, top: 20.0, bottom: 20.0),
              child: Row(
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: CupertinoColors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => package()),
                        );
                      }),
                  Column(
                    children: [
                      Text("Billing Through Mobile Carrier                   ",
                          style: TextStyle(
                              fontSize: 20, color: CupertinoColors.white)),
                      Text(" Enter Your Mobile number below",
                          style:
                          TextStyle(fontSize: 13, color: Colors.white70)),
                    ],
                  ),
                ],
              )),
          decoration: new BoxDecoration(color: Color(0xFF202125), boxShadow: [
            new BoxShadow(
              color: Colors.blue,
              blurRadius: 20.0,
              spreadRadius: 1.0,
            ),
          ]),
        ),
        preferredSize: new Size(MediaQuery.of(context).size.width, 80.0),
      ),
      body: Container(
        decoration: const BoxDecoration(
          //color: Color(0xFF202125),
          color: Color(0xFF202125),
        ),
        child: Center(
          child: Column(
            children: [
              Text(greetings, style: TextStyle(fontSize: 23.0)),
              SizedBox(
                height: 70,
              ),
              Expanded(
                  flex: 1,
                  child: Center(
                    child: Container(
                        height: 55,
                        child: Text(
                          "To start your membership, we'll text a code to verify \nyour number for payment. SMS fees may apply",
                          style: TextStyle(fontSize: 19, color: Colors.white),
                        )),
                  )),
              Expanded(
                flex: 3,
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: new InputDecoration(
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(50.0),
                              ),
                            ),
                            filled: true,
                            hintStyle: new TextStyle(color: Color(0XFFDCDDE1)),
                            hintText: "Postpaid Mobile Number",
                            fillColor: Color(0xFF3C4043),
                          ),
                        ),
                      ),
                      Container(
                          height: 55,
                          child: Text(
                            " Rs1,500/month  ",
                            style: TextStyle(
                                fontSize: 19,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          )),
                      Container(
                        child: RaisedButton(
                            padding: EdgeInsets.fromLTRB(80, 20, 80, 20),
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            child: Text(" Send Code",
                                style: TextStyle(color: Colors.white))),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}