import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
//import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helpalapp/functions/distancecalculator.dart';
import 'package:helpalapp/functions/locationmanager.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/nearbyhelpers.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:helpalapp/screens/helpee/workermodel.dart';
import 'package:helpalapp/screens/helpee/workermodelvehicle.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:location/location.dart';
import 'package:overlay_support/overlay_support.dart';

class SearchForHelper extends StatefulWidget {
  final String currentField;

  const SearchForHelper({Key key, this.currentField}) : super(key: key);

  @override
  _SearchForHelperState createState() =>
      _SearchForHelperState(this.currentField);
}

class _SearchForHelperState extends State<SearchForHelper> {
  final String currentField;
  _SearchForHelperState(this.currentField);
  //////////////////////////////////////////////////
  ///Variables
  //////////////////////////////////////////////////
  //Auth Database Services
  final AuthService _auth = AuthService();
  BuildContext mycontext;
  //static dispose object
  static bool isDisposed = true;
  //Database ref of realtime database
  final ref = FirebaseDatabase.instance;
  //Global key for scaffold
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  //Realtime database reference for nearby helpers sync
  final dbRef = FirebaseDatabase.instance;
  //User details (helpee details)
  //User name and user logo
  String username = 'Loading...';
  String userlogourl = '';

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

  //last opened worker position
  LatLng workerLoc;
  //////////////////////////////////////////////////
  ///Override Fucntions of this state
  //////////////////////////////////////////////////
  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
    NearbyWorkers().disposeRef();
  }

  @override
  void initState() {
    super.initState();
    isDisposed = false;
    initGpsPosition();
    //Start Live Service
    NearbyWorkers().initDatabase(syncOnlineHelpers);
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
      cameraLastPosition = new LatLng(locData.latitude, locData.longitude);
      getAddress();
      print("Moving camera to new location");
    });
  }
  //End getting GPS Location

  ///////////////////////////////////////////////////
  ///Moving Camera to Current Position
  ///////////////////////////////////////////////////
  getAddress() async {
    if (cameraLastPosition == null) return;

    final coordinates = new Coordinates(
        cameraLastPosition.latitude, cameraLastPosition.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      currentAddress = first.addressLine;
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

  //End moting camera to new position
  ///////////////////////////////////////////////////
  ///Show Worker Model When On Click Marker
  ///////////////////////////////////////////////////
  void showWorkerModel(BuildContext context, String workerID) async {
    //Getting details
    var worker = await _auth.firestoreRef
        .collection('helpers')
        .where('myid', isEqualTo: workerID)
        .get();

    //Vehicles worker model cover img array
    var imgArray;
    //getting ratings
    var rating = await _auth.getMyRating(worker.docs[0].data()["phone"]);
    if (rating.toString().contains("Error")) {
      toast("Error Getting User's Rating");
      rating = "0";
    }
    Map<String, dynamic> tailorServices;
    if (worker.docs[0].data()["field"] == "tailor") {
      tailorServices = worker.docs[0].data()["services"];
    }

    //get distance
    double mylat = LocationManager.myLocation.latitude;
    double mylng = LocationManager.myLocation.longitude;

    dynamic dis = await DistanceCalculator()
        .getDistance(mylat, mylng, workerLoc.latitude, workerLoc.longitude);

    String workerField = worker.docs[0].data()["field"];
    if (workerField == "helpalbike" ||
        workerField == "deliverypickup" ||
        workerField == "deliverybike" ||
        workerField == "helpalcab") {
      imgArray = await myMapController.takeSnapshot();
      //Image coverImg = Image.memory(imgArray);

      Navigator.pop(context);
      WorkerModelVehicle(worker, context, dis.toString(), "5-6 mins", rating);
    } else {
      //Getting cover image
      var shopcoverFilename = worker.docs[0].data()['shopphoto'];

      dynamic imgUrl = await StorageHandler.getDownloadUrl(
          shopcoverFilename, UploadTypes.Covers);
      Image coverImg = Image.network(imgUrl);

      Navigator.pop(context);
      WorkerModel(worker, context, coverImg, rating, dis.toString(), "6-8 mins",
          tailorServices);
    }
  }
  //End show worker model

  ///////////////////////////////////////////////////
  ///Worker marker tap function
  ///////////////////////////////////////////////////
  Future<void> onMarkerTap(String workerId, LatLng workerPos) async {
    workerLoc = workerPos;
    DialogsHelpal.showLoadingDialog(context, true);
    //Getting latlng points from latlng
    PointLatLng pointsWorker =
        new PointLatLng(workerPos.latitude, workerPos.longitude);
    PointLatLng pointsHelpee = new PointLatLng(
        LocationManager.myLocation.latitude,
        LocationManager.myLocation.longitude);
    //Drawing route
    await drawNewRoute(pointsHelpee, pointsWorker);
    showWorkerModel(context, workerId);
  }

  //End worker model tap function

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
          color: Appdetails.appBlueColor,
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

  //End Setting Polylines for selected helper

  //////////////////////////////////////////////////
  ///Sync Online Helper
  //////////////////////////////////////////////////
  void syncOnlineHelpers() async {
    if (isDisposed) return;
    print("Looking for =$currentField");
    //is the current status of location is null
    if (LocationManager.myLocation == null) {
      //starting service again
      bool isGps = await LocationManager.startLocationService();
      //if user denide the location service
      if (!isGps) {
        //return;
      }
    }
    //return if selected field in not recognized
    if (currentField == null) return;
    //Getting my location data
    LocationData locData = LocationManager.myLocation;
    if (LocationManager.myLocation == null)
      print("My Location Manager is null");
    //MyGps Location on map
    LatLng myLatLng = new LatLng(locData.latitude, locData.longitude);
    //Connecting to Realtime Database
    await ref.reference().child('onlineworkers').once().then((element) {
      //Making a map of online workers
      Map<dynamic, dynamic> onlineWorkers = element.value;
      //printing to console for online workers
      print('Sync Online Workers = ' + onlineWorkers.length.toString());
      //clear last cached workers data
      setState(() {
        if (nearbyMarkers.length > 0) nearbyMarkers.clear();
      });
      //Getting nearby workers
      onlineWorkers.forEach((workerid, value) async {
        //getting current worker details from loop
        Map<dynamic, dynamic> saperateField = value;
        double _lat = double.parse(
            saperateField['latlng'].split(',')[0].toString().trim());
        double _lng = double.parse(
            saperateField['latlng'].split(',')[1].toString().trim());
        //getting name of helper
        String workerName = saperateField['name'];
        //position of current worker
        LatLng position = new LatLng(_lat, _lng);
        //Getting distance between my position and worker
        double distance = await DistanceCalculator().getDistance(
            myLatLng.latitude,
            myLatLng.longitude,
            position.latitude,
            position.longitude);
        //checking if worker is near by 5km
        if (distance < 25) {
          print('Nearby Info($workerid , $position');
          //Getting field of this worker
          String workerField = saperateField['field'].toString();

          print("The current looking for is = " + currentField.toLowerCase());
          //Checking if user searched matched with any field
          if (workerField == currentField.toLowerCase()) {
            Marker marker = new Marker(
              icon: Appdetails.getCurrentMarkerIcon(workerField),
              position: position,
              markerId: new MarkerId(workerid),
              infoWindow: InfoWindow(title: workerName),
              onTap: () => onMarkerTap(workerid, position),
            );
            //moveCameraToPosition(position);
            setState(() {
              //Add marker to map
              nearbyMarkers.add(marker);
              if (nearbyMarkers.length < 2) return;
              if (myMapController != null) {
                print("Animating camera to bounds");
                myMapController.animateCamera(
                  CameraUpdate.newLatLngBounds(
                      boundsFromLatLngList(
                          nearbyMarkers.map((loc) => loc.position).toList()),
                      100),
                );
              }
            });
          }
        }
      });
    });
  }

  //////////////////////////////////////////////////
  ///Build main widget
  //////////////////////////////////////////////////
  Widget _closeBtn() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.transparent,
        ),
        child: InkWell(
          onTap: () {
            if (isSearching) {
              isSearching = false;
              setState(() {});
              return;
            }

            Navigator.pop(mycontext);
          },
          child: Icon(
            Icons.close,
            size: 25,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
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

  void onCameraMove(CameraPosition pos) {
    setState(() {
      cameraLastPosition = pos.target;
    });
  }

  //Animated search box
  TextEditingController _searchQueryController = TextEditingController();
  //Animated search box
  bool isSearching = false;
  Widget _buildSearchField(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.only(bottom: 2, left: 8),
            child: TextField(
              controller: _searchQueryController,
              autofocus: false,
              onEditingComplete: () {
                setState(() {
                  isSearching = false;
                });
              },
              decoration: InputDecoration(
                hintText: "Search Location...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
              style: TextStyle(color: Colors.grey[700], fontSize: 18.0),
              onChanged: (query) => {},
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 5, right: 5),
          child: InkWell(
            child: Icon(
              Icons.search,
              color: Colors.grey,
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    mycontext = context;
    double screenHeight = (MediaQuery.of(context).size.height);
    double screenWidth = (MediaQuery.of(context).size.width);

    setState(() {
      myGoogleMap = GoogleMap(
        onCameraIdle: () {
          getAddress();
        },
        onCameraMove: (position) {
          onCameraMove(position);
          if (currentAddress != '') {
            setState(() {
              currentAddress = '';
            });
          }
        },

         onTap: (argument) async {
          Marker marker = new Marker(
            position: argument,
            markerId: new MarkerId('tappedLocation'),
          );
          setState(() {
            nearbyMarkers.add(marker);
          });
        },
        padding: EdgeInsets.symmetric(vertical: 75, horizontal: 10),
        markers: nearbyMarkers,
        onMapCreated: onMapCreated,
        initialCameraPosition:
            CameraPosition(target: initialCameraPosition, zoom: initialZoom),
        mapType: MapType.normal,
        myLocationButtonEnabled: false,
        polylines: polylinesSet,
        myLocationEnabled: true,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        zoomGesturesEnabled: true,
      );
    });
    return Scaffold(
      backgroundColor: Colors.transparent,
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: _closeBtn(),
      ),
      floatingActionButton: Container(
        height: 160,
        alignment: Alignment.topRight,
        padding: EdgeInsets.only(right: 3),
        child: Container(
          height: 40,
          width: 40,
          //padding: EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: Color.fromARGB(200, 255, 255, 255),
            border: Border.all(color: Colors.grey[350], width: 1),
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          child: IconButton(
            icon:
                Icon(Icons.gps_fixed, size: 23, color: Appdetails.appBlueColor),
            onPressed: () {
              if (myGoogleMap != null && LocationManager.myLocation != null) {
                LatLng latLng = new LatLng(LocationManager.myLocation.latitude,
                    LocationManager.myLocation.longitude);
                moveCameraToPosition(latLng);
              }
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            height: screenHeight,
            width: screenWidth,
            child: LocationManager.myLocation == null
                ? Container(
                    margin: EdgeInsets.only(top: screenHeight / 2 - 50),
                    child: _loadingScreen(screenHeight, screenWidth),
                  )
                : myGoogleMap,
          ),
          Positioned(
            bottom: 0,
            top: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 30,
                width: 30,
                child: Center(child: Icon(Icons.location_on)),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.linearToEaseOut,
            top: isSearching ? 30 : screenHeight - 70,
            left: isSearching ? 55 : 15,
            right: isSearching ? 10 : 15,
            child: Container(
              padding: isSearching ? EdgeInsets.all(5) : EdgeInsets.all(10),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[500],
                    blurRadius: 0,
                    offset: Offset(0, 1),
                  )
                ],
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
              height: isSearching ? 45 : 55,
              child: isSearching
                  ? _buildSearchField(context)
                  : currentAddress == ''
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 30,
                                    width: 30,
                                    margin: EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.location_on,
                                      size: 30,
                                      color: Appdetails.appBlueColor,
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        isSearching = true;
                                        setState(() {});
                                      },
                                      child: Text(
                                        currentAddress,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.grey[600]),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    child: InkWell(
                                      child: Icon(
                                        Icons.bookmark_border,
                                        size: 30,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  /*
  currentAddress == ''
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 30,
                                      margin: EdgeInsets.only(right: 6),
                                      child: Icon(
                                        Icons.location_on,
                                        size: 30,
                                        color: Appdetails.appBlueColor,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        currentAddress,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.grey[600]),
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      width: 30,
                                      child: InkWell(
                                        child: Icon(
                                          Icons.bookmark_border,
                                          size: 30,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
  */
  void onMapCreated(GoogleMapController controller) async {
    String mapStyle = await rootBundle.loadString("assets/mapstyle.txt");
    setState(() {
      myMapController = controller;
      myMapController.setMapStyle(mapStyle);
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
    Marker myMarker = new Marker(
        markerId: MarkerId("myloc"), position: initialCameraPosition);
    setState(() {
      nearbyMarkers.add(myMarker);
    });
    Future.delayed(Duration(milliseconds: 1000), () {
      if (nearbyMarkers.length < 2) return;

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
            boundsFromLatLngList(
                nearbyMarkers.map((loc) => loc.position).toList()),
            100),
      );
    });
    print('Map Created');
    //getAddress();
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
