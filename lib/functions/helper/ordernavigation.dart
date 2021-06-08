import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/chatwindow.dart';
import 'package:helpalapp/functions/distancecalculator.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/helper/helperorders.dart';
import 'package:helpalapp/functions/helper/orderafterarrived.dart';
import 'package:helpalapp/functions/locationmanager.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:location/location.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class OrderNavigation extends StatefulWidget {
  final QueryDocumentSnapshot currentOrder;

  const OrderNavigation({Key key, this.currentOrder}) : super(key: key);
  @override
  _OrderNavigationState createState() =>
      _OrderNavigationState(this.currentOrder);
}

class _OrderNavigationState extends State<OrderNavigation> {
  final QueryDocumentSnapshot currentOrder;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  //Chat window
  bool chatwindowShowing = false;
  final ref = FirebaseDatabase.instance;

  TextEditingController messageController = TextEditingController();

  ScrollController messagesScroll = ScrollController();
  //////////////////////////////////////////////////
  ///Google Maps Setup for this state
  //////////////////////////////////////////////////
  //Google maps instance variable
  GoogleMap myGoogleMap;
  //Google maps controller for this state
  GoogleMapController myMapController;
  //Initial Position for camera on map at start
  static LatLng initialCameraPosition = new LatLng(34.2402916, 72.2917112);
  //getting last position
  LatLng cameraLastPosition;
  //address
  String currentAddress = '';
  //initial zoom level for camera on map at start
  static double initialZoom = 8.25;
  //Markers for showing nearby helpers
  Set<Marker> nearbyMarkers = Set();
  //Distance for nearby helpers
  double distanceInKm = 5;
  //Current route polyline paths
  Set<Polyline> polylinesSet = {};
  //Polyline instance for current route coords set
  PolylinePoints polylinePoints = PolylinePoints();
  //route coords for drawing route on map
  List<LatLng> routeCoords;

  _OrderNavigationState(this.currentOrder);

  BuildContext mycontext;
  double bottomNavbarHeight = 90;
  bool arrived = false;
  //////////////////////////////////////////////////
  ///Override Fucntions of this state
  //////////////////////////////////////////////////
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initGpsPosition();
    //Start Live Service
  }

  ///////////////////////////////////////////////////
  ///Getting my GPS location
  ///////////////////////////////////////////////////
  void initGpsPosition() async {
    //is the current status of location is null
    if (LocationManager.myLocation == null) {
      //starting service again
      bool isGps = await LocationManager.startLocationService();
      //if user denide the location service
      if (!isGps) {
        return;
      }
    }
    //changing variables data to current location
    setState(() {
      LocationData locData = LocationManager.myLocation;
      //setting initial position to current
      initialCameraPosition = new LatLng(locData.latitude, locData.latitude);
      initialZoom = 15;
      //Moving map camera to current location
      moveCameraToPosition(new LatLng(locData.latitude, locData.longitude));
    });
  }

  ///////////////////////////////////////////////////
  ///Moving Camera to Current Position
  ///////////////////////////////////////////////////
  void moveCameraToPosition(LatLng position) {
    //if map is currentlly not available in variable return empty
    if (myMapController == null) {
      return;
    }
    //if the controller is assigned
    //Animate camera to new position
    myMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        new CameraPosition(
          target: position,
          zoom: 15,
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////
  ///Setting polylines for selected helper to helpee
  ///////////////////////////////////////////////////
  drawNewRoute<bool>(PointLatLng orig, PointLatLng dest) async {
    try {
      print("Working on route");
      print("Helpee Position=$orig");
      print("Helper Position=$dest");
      //getting result for Helper to Helpee Map Route
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          Appdetails.mapsApiKey, orig, dest);
      print("Got the result for route");
      //Checking if result is valid for drawing waypoints
      if (result.points.isNotEmpty) {
        print("Route points are not empty");
        setState(() {
          //reserting current coords to 0
          routeCoords = new List<LatLng>();
          //Converting Pointslatlng to simple latlng
          result.points.forEach((PointLatLng point) {
            routeCoords.add(LatLng(point.latitude, point.longitude));
          });
        });
      }
      //Setting state to new changes
      setState(() {
        //reserting polylines set
        polylinesSet = new Set<Polyline>();
        //Creating polyline route and style
        Polyline poly = new Polyline(
          polylineId: PolylineId('mytouas'),
          width: 5,
          color: Appdetails.appGreenColor,
          points: routeCoords,
        );
        //Finally adding drawn polyline to set
        polylinesSet.add(poly);
        print("Route added to polylines");
      });
      //returning true to proceed with further
      return true;
    } catch (e) {
      print("error in route : \n" + e.toString());
      //return false there is an error
      return false;
    }
  }

  Widget _loadingScreen(double height, double width) {
    return Container(
      height: height,
      width: width,
      color: Colors.white,
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 30),
          Text("Waiting for gps Location"),
          SizedBox(height: 20),
          FlatButton(
            onPressed: () async => await LocationManager.startLocationService(),
            child: Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  BorderRadius helperBubble() {
    return BorderRadius.only(
        topRight: Radius.circular(100),
        bottomRight: Radius.circular(100),
        bottomLeft: Radius.circular(100));
  }

  BorderRadius helpeeBubble() {
    return BorderRadius.only(
        topLeft: Radius.circular(100),
        bottomRight: Radius.circular(100),
        bottomLeft: Radius.circular(100));
  }

  chatWindow() {
    Size size = MediaQuery.of(mycontext).size;
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        duration: Duration(minutes: 100),
        backgroundColor: new Color.fromARGB(240, 255, 255, 255),
        content: Container(
          height: size.height / 100 * 70,
          child: ChatWindow(
            orderId: widget.currentOrder.data()["orderid"],
          ),
        ),
      ),
    );
  }

  //End Setting Polylines for selected helper
  //End getting GPS Location
  @override
  Widget build(BuildContext context) {
    mycontext = context;
    Size size = MediaQuery.of(context).size;
    setState(() {
      myGoogleMap = GoogleMap(
        padding: EdgeInsets.only(right: 5),
        markers: nearbyMarkers,
        onMapCreated: onMapCreated,
        initialCameraPosition:
            CameraPosition(target: initialCameraPosition, zoom: initialZoom),
        mapType: MapType.normal,
        myLocationButtonEnabled: false,
        polylines: polylinesSet,
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        zoomGesturesEnabled: true,
        mapToolbarEnabled: false,
      );
    });
    return WillPopScope(
      onWillPop: () {
        DialogsHelpal.showMsgBoxCallback(
            "Info",
            "You are allowed to go back in testing version\nbut in final version helper cannot go back from here",
            AlertType.info,
            context, () {
          Navigator.pop(context);
        });

        return;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Appdetails.appGreenColor,
          title: Center(
            child: Text("Estimated Arrival Time "),
          ),
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
              child: Container(
                color: Colors.white,
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 20),
                      width: size.width / 100 * 90,
                      child: Text(
                        currentOrder
                            .data()["location"]
                            .toString()
                            .split("&&")[0]
                            .substring(
                              0,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              preferredSize: Size(size.width, 30)),
        ),
        body: Container(
          child: LocationManager.myLocation == null
              ? Container(
                  margin: EdgeInsets.only(top: size.height / 2 - 50),
                  child: _loadingScreen(size.height, size.width),
                )
              : myGoogleMap,
        ),
        bottomNavigationBar: AnimatedContainer(
          height: bottomNavbarHeight,
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (!chatwindowShowing) {
                        chatwindowShowing = true;
                        chatWindow();
                      } else {
                        chatwindowShowing = false;
                        _scaffoldKey.currentState.hideCurrentSnackBar();
                      }
                    },
                    child: Container(
                      height: 40,
                      width: size.width / 2,
                      color: Colors.white60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message,
                            color: Appdetails.appGreenColor,
                          ),
                          SizedBox(width: 15),
                          Text(
                            "Chat",
                            style: TextStyle(color: Colors.grey[600]),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        bottomNavbarHeight = 90;
                        arrived = false;
                      });
                    },
                    child: Container(
                      height: 40,
                      width: size.width / 2,
                      color: Colors.white60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone,
                            color: Appdetails.appGreenColor,
                          ),
                          SizedBox(width: 15),
                          Text(
                            "Call",
                            style: TextStyle(color: Colors.grey[600]),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Container(
                child: !arrived
                    ? SizedBox(height: 0)
                    : Container(
                        padding:
                            EdgeInsets.only(bottom: 20, left: 30, right: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Confirm Customer Name"),
                            SizedBox(height: 10),
                            Container(
                              color: Colors.grey[100],
                              child: ListTile(
                                leading: Icon(
                                  Icons.people,
                                  color: Colors.red[900],
                                ),
                                title: Text(
                                  currentOrder.data()["helpeename"],
                                  style: TextStyle(color: Colors.red[900]),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            GradButton(
                              onPressed: () async {
                                DialogsHelpal.showLoadingDialog(context, false);
                                dynamic result = await HelperOrdersUpdate()
                                    .startOrder(currentOrder.data()["orderid"]);
                                await HelpalStreams.prefs
                                    .setString("starttime", getStartTime());

                                Navigator.pop(context);
                                if (result == true) {
                                  Appdetails.loadScreen(
                                      context,
                                      HelperArrived(
                                        currentOrder: currentOrder,
                                      ));
                                } else {
                                  toast("Please try again");
                                }
                              },
                              width: size.width / 100 * 90,
                              height: 40,
                              backgroundColor: Appdetails.appGreenColor,
                              child: Text(
                                "Start Inspection",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          ],
                        ),
                      ),
              ),
              Container(
                child: !arrived
                    ? GradButton(
                        onPressed: () async {
                          if (LocationManager.myLocation == null) {
                            bool locSer =
                                await LocationManager.startLocationService();
                            if (!locSer) {
                              DialogsHelpal.showMsgBox(
                                  "Error",
                                  "Location error please try again",
                                  AlertType.error,
                                  context,
                                  Appdetails.appGreenColor);
                              return;
                            }
                          }
                          String dest = currentOrder
                              .data()["location"]
                              .toString()
                              .split("&&")[1];
                          double lat1 = double.parse(dest.split(',')[0]);
                          double lng1 = double.parse(dest.split(',')[1]);

                          double lat2 = LocationManager.myLocation.latitude;
                          double lng2 = LocationManager.myLocation.longitude;

                          double distance = await DistanceCalculator()
                              .getDistanceMeters(lat1, lng1, lat2, lng2);
                          print("Current distance is =$distance");
                          if (distance > 1500) {
                            DialogsHelpal.showMsgBox(
                                "Warning",
                                "Please arrive at the point before pressing arrived button",
                                AlertType.warning,
                                context,
                                Appdetails.appGreenColor);
                            return;
                          } else {
                            setState(() {
                              bottomNavbarHeight = size.height / 2.5;
                            });
                            Future.delayed(Duration(milliseconds: 200), () {
                              setState(() {
                                arrived = true;
                              });
                            });
                          }
                        },
                        //enabled: HelperOrdersUpdate().getArrivedDistance(start, end),
                        width: size.width / 100 * 90,
                        height: 40,
                        backgroundColor: Appdetails.appGreenColor,
                        child: Text(
                          "Arrived",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : SizedBox(height: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getStartTime() {
    String hour = DateTime.now().hour.toString().padLeft(2, '0');
    String minute = DateTime.now().minute.toString().padLeft(2, '0');

    return hour + ":" + minute;
  }

  void onMapCreated(GoogleMapController controller) async {
    DialogsHelpal.showLoadingDialog(mycontext, false);
    setState(() {
      myMapController = controller;
    });
    if (LocationManager.myLocation == null) {
      bool locSer = await LocationManager.startLocationService();
      if (!locSer) return;
    }

    LocationData locData = LocationManager.myLocation;
    if (locData == null) {
      return;
    }
    setState(() {
      initialCameraPosition = new LatLng(locData.latitude, locData.longitude);
      initialZoom = 15;
      moveCameraToPosition(initialCameraPosition);
    });
    //Getting my field
    String helperid = currentOrder.data()["helper"];
    dynamic myfield = await AuthService()
        .getDocuementFieldWhere("helpers", helperid, "myid", "field");
    if (myfield == null) {
      myfield = "general";
    }
    //own marker
    LatLng myLoc = new LatLng(locData.latitude, locData.longitude);

    String dest = currentOrder.data()["location"].toString().split("&&")[1];
    double lat = double.parse(dest.split(',')[0]);
    double lng = double.parse(dest.split(',')[1]);
    LatLng latLng = new LatLng(lat, lng);
    //Setting order destination
    Marker markerOwn = new Marker(
      markerId: MarkerId("own"),
      position: myLoc,
      icon: Appdetails.getCurrentMarkerIcon(myfield),
    );
    Marker markerDest =
        new Marker(markerId: MarkerId("dest"), position: latLng);
    nearbyMarkers.add(markerOwn);
    nearbyMarkers.add(markerDest);
    setState(() {});
    await drawNewRoute(new PointLatLng(myLoc.latitude, myLoc.longitude),
        new PointLatLng(lat, lng));
    Navigator.pop(mycontext);
    Future.delayed(
      Duration(milliseconds: 100),
      () => controller.animateCamera(
        CameraUpdate.newLatLngBounds(
            boundsFromLatLngList(
                nearbyMarkers.map((loc) => loc.position).toList()),
            100),
      ),
    );
    print('Map Created');
  }

  ////////////////////////////////////////////////////
  ///Bound the camera between online helpers
  ////////////////////////////////////////////////////
  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }
}
