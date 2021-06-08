import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/helpalstreams.dart';

class HelpeeOrdersUpdate {
  final ref = FirebaseDatabase.instance;
  final fs = FirebaseFirestore.instance;

  static StreamSubscription<QuerySnapshot> ordersStream;
  static StreamSubscription<DocumentSnapshot> myStream;

  static Map<int, QueryDocumentSnapshot> allOrders = Map();
  static Map<String, dynamic> myDetails = Map();

  static bool isInit = false;

  static Function calbacktoState;

  void setCallBack(Function callbackFunction) {
    print("Got callback in helpee orders");
    calbacktoState = callbackFunction;
  }

  void callback() {
    print("refreshing state from helpee orders");
    if (calbacktoState != null) {
      calbacktoState.call();
    } else {
      print("refreshing state from helpee failed its null");
    }
  }

  void initDatabase() async {
    String myphone = HelpalStreams.prefs.getString(Appdetails.phoneKey);
    String myid = HelpalStreams.prefs.getString(Appdetails.myidKey);
    ordersStream = fs
        .collection("orders")
        .where("helpee", isEqualTo: myid)
        .snapshots()
        .listen((event) {
      isInit = true;
      allOrders = event.docs.asMap();
      //send call to dashboard and recents to update the status
      callback();
    });

    myStream =
        fs.collection("helpees").doc(myphone).snapshots().listen((event) {
      print("User Details Received");
      myDetails = event.data();
    });
    print('$isInit Current status of db updater at Last');
  }

  void databaseError(dynamic error) {
    print("There is a error while connecting to firestore");
    isInit = false;
  }

  void databaseDisconnect() {
    print("Disconnected to firestore");
    isInit = true;
  }

  void orderAccepted(String orderPath) {}
  Future sendNewOrder(
      message,
      contactNumber,
      voicenote,
      location,
      helperId,
      helpername,
      helperphone,
      helperField,
      helpeeID,
      helpeeName,
      orderdate,
      orderid) async {
    try {
      Map<String, dynamic> orderData = {
        'orderid': orderid,
        'message': message,
        'voice': voicenote,
        'helpee': helpeeID,
        'helpeename': helpeeName,
        'contact': contactNumber,
        'helper': helperId,
        'helpername': helpername,
        'helperfield': helperField,
        'location': location,
        'date': orderdate,
        'totalbill': '0.00',
        'status': 'waiting',
      };
      await fs.collection("orders").doc(orderid).set(orderData);

      print('order posted');

      return true;
    } catch (e) {
      return e.toString();
    }
  }

  //Bike and cab and delivery
  Future sendNewOrderDelivery(
    locationPickup,
    locationDropoff,
    message,
    isFragile,
    contactNumber,
    voicenote,
    helperId,
    helpername,
    helperphone,
    helperField,
    helpeeID,
    helpeeName,
    orderdate,
    orderId,
  ) async {
    try {
      Map<String, dynamic> orderData = {
        'pickuplocation': locationPickup,
        'dropofflocation': locationDropoff,
        'orderid': orderId,
        'message': message,
        'isfragile': isFragile,
        'voice': voicenote,
        'helpee': helpeeID,
        'helpeename': helpeeName,
        'contact': contactNumber,
        'helper': helperId,
        'helpername': helpername,
        'helperfield': helperField,
        'date': orderdate,
        'totalbill': '0.00',
        'status': 'waiting',
      };
      await fs.collection("orders").doc(orderId).set(orderData);

      print('order posted');

      return true;
    } catch (e) {
      return e.toString();
    }
  }

  //Bike and cab and delivery
  Future sendNewOrderVehicle(
    addressPickup,
    addressDropoff,
    pickupLocation,
    dropoffLocation,
    message,
    contactNumber,
    voicenote,
    helperId,
    helpername,
    helperphone,
    helperField,
    helpeeID,
    helpeeName,
    orderdate,
    orderId,
  ) async {
    try {
      Map<String, dynamic> orderData = {
        'pickupLoc': pickupLocation,
        'pickupAdd': addressPickup,
        'dropoffLoc': dropoffLocation,
        'dropoffAdd': addressDropoff,
        'orderid': orderId,
        'message': message,
        'voice': voicenote,
        'helpee': helpeeID,
        'helpeename': helpeeName,
        'contact': contactNumber,
        'helper': helperId,
        'helpername': helpername,
        'helperfield': helperField,
        'date': orderdate,
        'totalbill': '0.00',
        'status': 'waiting',
      };
      await fs.collection("orders").doc(orderId).set(orderData);

      print('order posted');

      return true;
    } catch (e) {
      return e.toString();
    }
  }

  //send new order drycleaner and tailors
  Future sendNewOrderWithServices(
      totalbill,
      services,
      message,
      contactNumber,
      voicenote,
      location,
      helperId,
      helpername,
      helperphone,
      helperField,
      helpeeID,
      helpeeName,
      orderdate,
      orderid) async {
    try {
      Map<String, dynamic> orderData = {
        'orderid': orderid,
        'services': services,
        'message': message,
        'voice': voicenote,
        'helpee': helpeeID,
        'helpeename': helpeeName,
        'contact': contactNumber,
        'helper': helperId,
        'helpername': helpername,
        'helperfield': helperField,
        'location': location,
        'date': orderdate,
        'totalbill': totalbill,
        'status': 'waiting',
      };
      await fs.collection("orders").doc(orderid).set(orderData);

      print('order posted');

      return true;
    } catch (e) {
      return e.toString();
    }
  }
}
