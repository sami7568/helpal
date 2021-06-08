import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/helper/orderdetailspopup.dart';
import 'package:helpalapp/functions/locationmanager.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/main.dart';
import 'package:helpalapp/screens/helper/neworderslist.dart';
import 'package:latlong/latlong.dart';
import 'package:overlay_support/overlay_support.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';

class HelperOrdersUpdate {
  final ref = FirebaseDatabase.instance;
  final fs = FirebaseFirestore.instance;
  static StreamSubscription<QuerySnapshot> ordersStream;
  static StreamSubscription<DocumentSnapshot> myStream;

  static bool isOrderStream = false;
  static bool isMyStream = false;

  static Map<int, QueryDocumentSnapshot> allOrders = Map();
  static Map<String, dynamic> myDetails = Map();

  static bool showingNoti = false;
  //static bool isInit = false;

  static Function calbacktoState;

  void setCallBack(Function callbackFunction) {
    print("Got callback in helper orders");
    calbacktoState = callbackFunction;
  }

  void refreshCallback() {
    if (calbacktoState != null) {
      print("refreshing state from helper orders");
      calbacktoState.call();
    } else {
      print("refreshing state from helper failed its null");
    }
  }

  /////////////////////////////////////
  ///Sync ORDERS AND HELPER DATABASE
  /////////////////////////////////////
  void initDatabase() async {
    String myphone = HelpalStreams.prefs.getString(Appdetails.phoneKey);
    String myid = HelpalStreams.prefs.getString(Appdetails.myidKey);
    print("MyPhone is = $myphone and My ID is=$myid");
    //Sync ORDERS DATABASE STREAM
    if (isOrderStream == false) {
      ordersStream = fs
          .collection("orders")
          .where("helper", isEqualTo: myid)
          .snapshots()
          .listen((docs) {
        print("Orders Database Updated");

        allOrders = docs.docs.asMap();
        refreshCallback();
      }, onError: onError);
      isOrderStream = true;
    }
    //Sync HELPER DATABASE STREAM
    if (isMyStream == false) {
      myStream =
          fs.collection("helpers").doc(myphone).snapshots().listen((event) {
        print("User Details Received");
        myDetails = event.data();
        if (event.data()["status"] == "offline") {
          if (LocationManager.liveService)
            LocationManager.stopBackgroundLocation();
        } else if (event.data()["status"] == "online") {
          if (!LocationManager.liveService) LocationManager.startLiveLocation();
        }
        refreshCallback();
      }, onError: onError);
      isMyStream = true;
    }
  }

  ////////////////////////////////
  ///ON DATABASE CONNECTING ERROR
  ////////////////////////////////
  void onError(sss) {
    Future.delayed(Duration(seconds: 3), () {
      print("Orders Database Error, Connecting again in 3 seconds");
      initDatabase();
    });
  }

  ////////////////////////////////
  ///Cancel Streams
  ////////////////////////////////
  void cancelOrderStream() {
    ordersStream.cancel();
    isOrderStream = false;
  }

  void cancelHelperStream() {
    myStream.cancel();
    isMyStream = false;
  }

  ///////////////////////////////////
  ///GETTING ORDER BY ID FROM CACHED
  ///////////////////////////////////
  getOrderByIdLocal(String orderid) {
    QueryDocumentSnapshot order;
    allOrders.values.forEach((element) {
      if (element.data()["orderid"] == orderid) {
        order = element;
      }
    });
    if (order == null)
      return false;
    else
      return order;
  }

  ////////////////////////////////
  ///ACCEPTING A ORDER
  ////////////////////////////////
  Future acceptOrder(orderid) async {
    try {
      String acceptedTime = DateTime.now().millisecondsSinceEpoch.toString();
      Map<String, dynamic> orderdetailsNew = {
        "acceptedtime": acceptedTime,
        "status": "accepted"
      };
      await fs.collection("orders").doc(orderid).update(orderdetailsNew);
      await AuthService().changeStatusAccepted();
      return true;
    } catch (e) {
      return e.toString();
    }
  }

  ////////////////////////////////////
  ///When helper arrived at the point
  ////////////////////////////////////
  Future helperArrived(orderid) async {
    try {
      String arrivedTime = DateTime.now().millisecondsSinceEpoch.toString();
      Map<String, dynamic> orderdetailsNew = {
        "arrivedtime": arrivedTime,
        "status": "arrived"
      };
      await fs.collection("orders").doc(orderid).update(orderdetailsNew);
      return true;
    } catch (e) {
      return e.toString();
    }
  }

  ////////////////////////////////
  ///Start working on order
  ////////////////////////////////
  Future startOrder(orderid) async {
    try {
      String startTime = DateTime.now().millisecondsSinceEpoch.toString();
      Map<String, dynamic> orderdetailsNew = {
        "starttime": startTime,
        "status": "inprogress"
      };
      await fs.collection("orders").doc(orderid).update(orderdetailsNew);
      await AuthService().changeStatusWorking();
      return true;
    } catch (e) {
      return e.toString();
    }
  }

  ////////////////////////////////////////////
  ///Plumbers and electrician order completed
  ////////////////////////////////////////////
  Future completeOrderPlumbers(orderid, fee, inventory, totalbill) async {
    try {
      Map<String, dynamic> orderdetailsNew = {
        "status": "completed",
        "fee": fee,
        "inventory": inventory,
        "totalbill": totalbill
      };
      await fs.collection("orders").doc(orderid).update(orderdetailsNew);
      await AuthService().changeStatusOnline();
      return true;
    } catch (e) {
      return e.toString();
    }
  }

  ////////////////////////////////////////////
  ///Drycleaner and tailors order completed
  ////////////////////////////////////////////
  Future completeOrderTailors(orderid, fee, inventory, totalbill) async {
    try {
      Map<String, dynamic> orderdetailsNew = {"status": "completed"};
      await fs.collection("orders").doc(orderid).update(orderdetailsNew);
      await AuthService().changeStatusOnline();
      return true;
    } catch (e) {
      return e.toString();
    }
  }
  /* int getArrivedDistance(LatLng start, LatLng end) {
    final Distance distance = new Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  } */

  Future rejectOrder(orderid) async {
    try {
      Map<String, dynamic> orderdetailsNew = {"status": "rejected"};
      await fs.collection("orders").doc(orderid).update(orderdetailsNew);
      //await AuthService().changeStatusWorking();
      return true;
    } catch (e) {
      return e.toString();
    }
  }
}
