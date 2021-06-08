import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/distancecalculator.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/helper/helperorders.dart';
import 'package:location/location.dart';

class LocationManager {
  //instance of Location
  static Location instance = new Location();
  //Get current location
  static LocationData myLocation;
  static LocationData lastLocData;
  static StreamSubscription<LocationData> locationBg;

  //satus of permission
  static PermissionStatus _permissionGranted;
  static bool gpsEnabled;
  static bool workerAdded = false;
  static bool liveService = false;

  //Start location service
  static Future<bool> startLocationService() async {
    print("Location Service Req Received");
    //getting permission status on start
    bool per = await isPermissionGranted();
    //checing is user not granted permission
    if (!per) {
      //requesting again for permission
      bool perReq = await requestPermission();
      //if user declined the permission request
      if (perReq == false) return false;
    }
    //getting gps status
    bool ser = await isServiceEnabled();
    if (!ser) {
      bool serReq = await requestService();
      //if user cancelled enable gps
      if (!serReq) return false;
    }
    //proceed if permission and gps is enabled
    //setting location updater
    myLocation = await instance.getLocation();
    //returning true if eveything is working fine
    print("Location Updates Approved");
    return true;
  }

  ///////////////////////////////////////////
  ///DRYCLEANERS & TAILORS SHOP LOCATION
  ///////////////////////////////////////////
  static Future<dynamic> syncShopLocaitonAndStatus() async {
    final ref = FirebaseDatabase.instance;
    print("Shop Locaiton added to map");
    String myname = HelpalStreams.prefs.getString(Appdetails.nameKey);
    String myid = HelpalStreams.prefs.getString(Appdetails.myidKey);
    String mynum = HelpalStreams.prefs.getString(Appdetails.phoneKey);
    String myfield = HelpalStreams.prefs.getString(Appdetails.fieldKey);

    String shopLoc = HelperOrdersUpdate.myDetails["shoplatlng"];
    String mystatus = HelperOrdersUpdate.myDetails["status"];

    Map<String, dynamic> myonlinedetails = {
      "name": myname,
      "phone": mynum,
      "latlng": shopLoc,
      "field": myfield,
      "myid": myid,
      "status": mystatus
    };
    await ref
        .reference()
        .child("onlineworkers")
        .child(myid)
        .set(myonlinedetails);
    workerAdded = true;
  }

  ///////////////////////////////////////////
  ///LOCATION TO SERVER AREA
  //////////////////////////////////////////
  static Future<dynamic> startLiveLocation() async {
    //getting permission status on start
    bool per = await isPermissionGranted();
    //checing is user not granted permission
    if (!per) {
      //requesting again for permission
      bool perReq = await requestPermission();
      //if user declined the permission request
      if (perReq == false) return false;
    }
    //getting gps status
    bool ser = await isServiceEnabled();
    if (!ser) {
      bool serReq = await requestService();
      //if user cancelled enable gps
      if (!serReq) return false;
    }
    await instance.enableBackgroundMode(enable: true);
    await instance.changeSettings(interval: 100, distanceFilter: 5);
    if (locationBg != null && locationBg.isPaused) {
      locationBg.resume();
      if (!workerAdded) {
        addOnlineWorker();
      }
      liveService = true;
    } else {
      locationBg = instance.onLocationChanged.listen(
        (LocationData currentLocation) {
          // Use current location
          if (!workerAdded) {
            addOnlineWorker();
          } else {
            sendLocationToServer(currentLocation);
            liveService = true;
          }
        },
        onDone: () {
          print("Location Service Closed Manually");
        },
      );
    }
  }

  static void addOnlineWorker() async {
    final ref = FirebaseDatabase.instance;
    print("Added to online workers");
    String myname = HelpalStreams.prefs.getString(Appdetails.nameKey);
    String myid = HelpalStreams.prefs.getString(Appdetails.myidKey);
    String mynum = HelpalStreams.prefs.getString(Appdetails.phoneKey);
    String myfield = HelpalStreams.prefs.getString(Appdetails.fieldKey);

    LocationData dl = await LocationManager.instance.getLocation();
    Map<String, dynamic> myonlinedetails = {
      "name": myname,
      "phone": mynum,
      "latlng": dl.latitude.toString() + "," + dl.longitude.toString(),
      "field": myfield,
      "myid": myid
    };
    await ref
        .reference()
        .child("onlineworkers")
        .child(myid)
        .set(myonlinedetails);
    workerAdded = true;
  }

  static void removeOnlineWorker() async {
    final ref = FirebaseDatabase.instance;
    print("Remove from online workers");
    String myid = HelpalStreams.prefs.getString(Appdetails.myidKey);
    await ref.reference().child("onlineworkers").child(myid).remove();
    workerAdded = false;
  }

  static void sendLocationToServer(LocationData locData) async {
    //if (lastLocData == null) lastLocData = locData;
    final ref = FirebaseDatabase.instance;
    String myid = HelpalStreams.prefs.getString(Appdetails.myidKey);
    //double dis = await DistanceCalculator().getDistanceMeters(locData.latitude,
    //    locData.longitude, lastLocData.latitude, lastLocData.longitude);
    //if (dis < 1) return;
    print("Worker Position Updated");
    //lastLocData = locData;
    myLocation = locData;
    Map<String, dynamic> latlng = {
      "status": HelperOrdersUpdate.myDetails["status"],
      "latlng": locData.latitude.toString() + "," + locData.longitude.toString()
    };
    await ref.reference().child("onlineworkers").child(myid).update(latlng);
    if (HelpalStreams.prefs.getString(Appdetails.signinKey) == "false") {
      await stopBackgroundLocation();
    }
  }

  static Future<void> stopBackgroundLocation() async {
    try {
      liveService = false;
      await instance.enableBackgroundMode(enable: false);
      locationBg.pause();
      print("Listening Cancelled");
      removeOnlineWorker();
    } catch (e) {
      print("Error:\n" + e.toString());
    }
  }

  //////////////////////////////////////////
  ///END LOCATION TO SERVER AREA
  //////////////////////////////////////////
  static void updatingLocaion(LocationData locData) {
    if (myLocation == null) print("Location Updates Receiving");
    myLocation = locData;
  }

  //this will return the status for location permission
  static Future<bool> isPermissionGranted() async {
    _permissionGranted = await instance.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      return false;
    } else {
      return true;
    }
  }

  //if user not accepted the permission
  static Future<bool> requestPermission() async {
    _permissionGranted = await instance.requestPermission();
    if (_permissionGranted == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  //getting the GPS status if available
  static Future<bool> isServiceEnabled() async {
    gpsEnabled = await instance.serviceEnabled();
    return gpsEnabled;
  }

  //requeting use to enable the gps
  static Future<bool> requestService() async {
    gpsEnabled = await instance.requestService();
    return gpsEnabled;
  }
}
