import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpalStreams {
  final fs = FirebaseFirestore.instance;
  static SharedPreferences prefs;

  static Future initSharedPrefs() async {
    try {
      prefs = await SharedPreferences.getInstance();
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<String> getStatus() {

    String phone = prefs.getString(Appdetails.phoneKey);
    if (phone == "" || phone == null) return null;
    return fs
        .collection("helpers")
        .doc(phone)
        .snapshots()
        .map((event) => event.data()['status'].toString());
  }

  Stream<String> getBalance() {
    String phone = prefs.getString(Appdetails.phoneKey);
    return fs
        .collection("helpers")
        .doc(phone)
        .snapshots()
        .map((event) => event.data()['balance'].toString());
  }

  Stream<String> getFulname() {
    String phone = prefs.getString(Appdetails.phoneKey);
    return fs
        .collection("helpers")
        .doc(phone)
        .snapshots()
        .map((event) => event.data()['name'].toString());
  }
}

///////////////////////////////////////////////
///STREAMS WIDGETS
///////////////////////////////////////////////

//Status Widget
class MyStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String mysts = Provider.of<String>(context);
    return Container(
      child: Text("$mysts".capitalize()),
    );
  }
}

//Status Widget
class MyName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String myname = Provider.of<String>(context);
    return Container(
      child: Text("$myname".capitalizeFirstofEach),
    );
  }
}

//Balance Widget
class MyBalance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String mybalance = Provider.of<String>(context);
    return Text(
      mybalance == null || mybalance == '' ? " Loading..." : mybalance,
      style: TextStyle(fontSize: 50),
    );
  }
}
