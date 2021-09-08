import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:helpalapp/functions/helper/orderafterarrived.dart';
import 'package:helpalapp/functions/helper/orderdetailspopup.dart';
import 'package:helpalapp/functions/locationmanager.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/functions/helper/helperorders.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:helpalapp/screens/helpee/workermodel.dart';
import 'package:helpalapp/screens/helper/helperdrawer.dart';
import 'package:helpalapp/screens/helper/helpernavbar.dart';
import 'package:helpalapp/screens/helper/helperwalletdrawer.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/others/notapproved.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HelperDash extends StatefulWidget {
  @override
  _HelperDashState createState() => _HelperDashState();
}

class _HelperDashState extends State<HelperDash>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String myStatus = 'Loading..';
  String _phone = '';
  String _name = '';
  OurServices _field;
  bool _status = false;
  bool _working = false;
  String approved = "";

  String firstTitle = "New Requests";
  String secondTitle = "Dues";

  final AuthService _auth = AuthService();
  final ref = FirebaseDatabase.instance;
  BuildContext mycontext;

  int availableOrders = 0;
  void registerEventsForFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message while set in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();
    print('Handling a background message ${message.messageId}');
  }

  @override
  void initState() {
    super.initState();
    getMyDp();
    getMyField();
    _controller = AnimationController(vsync: this);
    HelperOrdersUpdate().setCallBack(refreshState);
    HelperOrdersUpdate().initDatabase();
    //BgLoc.startLocationBackground();
    startLocationService();
    notificationsettings();
    registerEventsForFCM();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  void startLocationService() async {
    //Requesting location service
    await LocationManager.startLocationService();
  }

  void refreshState() {
    if (mounted) {
      print("details refreshed");
      setState(() {});
      updateApprovel();
    }
  }

  Future<void> updateApprovel() async {
    if (approved == "false" || approved == "") {
      String myapprovel = await AuthService()
          .getDocuementFieldWhere("helpers", _phone, "phone", "approved");
      approved = myapprovel;
      setState(() {});
    }
  }

  getMyField() async {
    _phone = await AuthService().getLocalString(Appdetails.phoneKey);
    _name = await AuthService().getLocalString(Appdetails.nameKey);
    setState(() {});
    print("Checking for field");
    String myField = await AuthService()
        .getDocuementFieldWhere("helpers", _phone, "phone", "field");
    String mystatus = await AuthService()
        .getDocuementFieldWhere("helpers", _phone, "phone", "status");
    String myapprovel = await AuthService()
        .getDocuementFieldWhere("helpers", _phone, "phone", "approved");
    approved = myapprovel;

    print("Got Field is = $myField");
    setState(() {
      if (mystatus == "offline") {
        _status = false;
        _working = false;
      } else if (mystatus == "working") {
        _status = true;
        _working = true;
      } else if (mystatus == "accepted") {
        _status = true;
        _working = false;
      } else {
        _status = true;
        _working = false;
      }

      if (myField == "tailor") {
        _field = OurServices.Tailors;
      } else if (myField == "drycleaner") {
        _field = OurServices.Drycleaners;
      } else if (myField == "plumber") {
        _field = OurServices.Plumbers;
      } else if (myField == "electrician") {
        _field = OurServices.Electricians;
      } else if (myField == "deliverybike" || myField == "deliverypickup") {
        _field = OurServices.DeliveryService;
      } else if (myField == "helpalbike") {
        _field = OurServices.HelpalBike;
      } else if (myField == "helpalcab") {
        _field = OurServices.HelpalCab;
      }
    });
    if (approved == "false") return;

    if (!_status) {
      DialogsHelpal.showMsgBox(
          "Warning!",
          "Your status is offline\nyou will not receive any order\nto be visible to everyone go online",
          AlertType.warning,
          mycontext,
          Appdetails.appGreenColor);
      return;
    }
    if (_field == OurServices.Drycleaners || _field == OurServices.Tailors) {
      print("live location not compatiable with this field");
    } else {
      dynamic ll = await LocationManager.startLiveLocation();
      if (ll == true) {
        print("Live location started");
      }
    }
  }


  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void notificationsettings()async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  Widget _helpal() {
    AssetImage assetImage = AssetImage('assets/images/mainlogo.png');
    Image image = Image(
      image: assetImage,
      height: 80,
    );
    return Hero(tag: "helpal", child: image);
  }

  getMyDp() async {
    await _auth.getLocalString(Appdetails.photoidKey).then((value) async {
      print("my photo id is=$value");
      if (value == null || value.length == 0) return;

      String url = await StorageHandler.getDownloadUrl(
          value, UploadTypes.DisplayPicture);
      Appdetails.myDp = Image.network(url);
    });
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => SystemNavigator.pop(),
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String getWelcomeNote() {
    String welcome = "Welcome Back";
    var hour = DateTime.now().hour;
    if (hour < 12) {
      welcome = 'Good Morning';
    } else if (hour > 11 && hour < 17) {
      welcome = 'Good Afternoon';
    } else if (hour > 17 && hour < 23) {
      welcome = 'Good Evening';
    }

    return welcome + " $_name!";
  }


  @override
  Widget build(BuildContext context) {
    mycontext = context;
    Size size = MediaQuery.of(context).size;
    if (approved == "") {
      return WillPopScope(
        onWillPop: _onBackPressed,
        child: Material(
          child: loading(""),
        ),
      );
    } else if (approved == "false") {
      return WillPopScope(
        onWillPop: _onBackPressed,
        child: Material(
          child: NotApproved(),
        ),
      );
    } else {
      return WillPopScope(
        //onWillPop: _onBackPressed,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: Appdetails.appGreenColor,
              ),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
            actions: [
              Container(
                height: 20,
                width: 20,
                margin: EdgeInsets.only(right: 20),
                child: InkWell(
                  child: Image(
                    image: Image.asset("assets/images/icons/wallet.png").image,
                    color: Appdetails.appGreenColor,
                  ),
                  onTap: () {
                    _scaffoldKey.currentState.openEndDrawer();
                  },
                ),
              ),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          bottomNavigationBar: HelperBottomNavbar().getnewnavbar(context, 0),
          drawer: HelperDrawer(),
          endDrawer: HelperWalletDrawer(
            phone: _phone,
          ),
          drawerScrimColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: Container(
            height: size.height,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                //Header
                Container(
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      Container(
                        child: _helpal(),
                      ),
                      SizedBox(height: 20),
                      Text(
                        getWelcomeNote(),
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width / 100 * 8),
                        child: ListTile(
                          leading: Icon(
                            Icons.blur_circular,
                            color: Appdetails.appGreenColor,
                          ),
                          trailing: CupertinoSwitch(
                              value: _status,
                              activeColor: _working
                                  ? Colors.orangeAccent
                                  : Appdetails.appGreenColor,
                              onChanged: (newvalue) async {
                                if (newvalue) {
                                  await _auth.updateDocumentField(
                                      "helpers", _phone, "status", "online");
                                  _status = newvalue;
                                } else {
                                  await _auth.updateDocumentField(
                                      "helpers", _phone, "status", "offline");
                                  _status = newvalue;
                                }
                                setState(() {});
                              }),
                          title: Transform.translate(
                            offset: Offset(-20, 0),
                            child: _phone == null ||
                                    _phone == '' ||
                                    _phone == 'error' ||
                                    !HelperOrdersUpdate.myDetails
                                        .containsKey("status")
                                ? Text(
                                    "Loading...",
                                    style: TextStyle(fontSize: 25),
                                  )
                                : Text(
                                    HelperOrdersUpdate.myDetails["status"]
                                        .toString()
                                        .capitalize(),
                                    style: TextStyle(fontSize: 25),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                //Contents
                //Homescreen

                Expanded(
                  child: _field == null
                      ? loading("")
                      : _field == OurServices.Drycleaners ||
                              _field == OurServices.Tailors
                          ? drycleanersTailors(size)
                          : plumbersElectricians(size),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget newListOrdersTailorsDry() {
    //Getting inprogress list
    Iterable<QueryDocumentSnapshot> ordersList = HelperOrdersUpdate
        .allOrders.values
        .where((element) => element.data()["status"] != "rejected");
    //getting accepted list

    return MediaQuery.removePadding(
      context: mycontext,
      removeTop: true,
      child: ListView.builder(
        itemCount: ordersList.length,
        itemBuilder: (BuildContext context, int index) {
          String title = ordersList.elementAt(index).data()['helpeename'];
          String orderid = ordersList.elementAt(index).data()['orderid'];
          int timeStamp = int.parse(ordersList.elementAt(index).data()['date']);
          DateTime dt = DateTime.fromMillisecondsSinceEpoch(timeStamp);
          return listTile(ordersList.elementAt(index), title, dt.toString());
        },
      ),
    );
  }

  Widget newListOrdersPlumberElect() {
    //Getting inprogress list
    Iterable<QueryDocumentSnapshot> ordersListInProgress = HelperOrdersUpdate
        .allOrders.values
        .where((element) => element.data()["status"] == "inprogress");
    //getting accepted list
    Iterable<QueryDocumentSnapshot> ordersListAccepted = HelperOrdersUpdate
        .allOrders.values
        .where((element) => element.data()["status"] == "accepted");
    //getting waiting list
    Iterable<QueryDocumentSnapshot> ordersListWaiting = HelperOrdersUpdate
        .allOrders.values
        .where((element) => element.data()["status"] == "waiting");

    //general order list
    Iterable<QueryDocumentSnapshot> ordersList;

    //if there is any order in progress for plumber and electricians
    //take them to working screen
    if (ordersListInProgress.length > 0) {
      ordersList = ordersListInProgress;
      if (!Appdetails.completingOrder) {
        if (_field == OurServices.Electricians ||
            _field == OurServices.Plumbers) {
          Future.delayed(Duration(milliseconds: 400), () {
            Appdetails.loadScreen(
              mycontext,
              HelperArrived(
                currentOrder: ordersListInProgress.elementAt(0),
                initialSeconds: 3,
              ),
            );
          });
        }
      }
    } else if (ordersListAccepted.length > 0) {
      ordersList = ordersListAccepted;
    } else {
      ordersList = ordersListWaiting;
    }
    return MediaQuery.removePadding(
      context: mycontext,
      removeTop: true,
      child: ListView.builder(
        itemCount: ordersList.length,
        itemBuilder: (BuildContext context, int index) {
          String title = ordersList.elementAt(index).data()['helpeename'];
          String orderid = ordersList.elementAt(index).data()['orderid'];
          int timeStamp = int.parse(ordersList.elementAt(index).data()['date']);
          DateTime dt = DateTime.fromMillisecondsSinceEpoch(timeStamp);
          return listTile(ordersList.elementAt(index), title, dt.toString());
        },
      ),
    );
  }

  Widget listTile(currentOrder, title, datetime) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey[300]),
      ),
      margin: EdgeInsets.only(bottom: 5),
      child: ListTile(
        trailing: MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: Appdetails.appGreenColor,
          child: Text(
            'VIEW',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPopup(
                  currentOrder: currentOrder,
                ),
              ),
            );
            print("order clicked");
          },
        ),
        title: Text(
          '  ' + title,
          style: TextStyle(color: Colors.grey[800], fontSize: 18),
        ),
        subtitle: Text(
          '  ' + datetime,
          style: TextStyle(
              color: Appdetails.grey4,
              fontStyle: FontStyle.italic,
              fontSize: 16),
        ),
      ),
    );
  }

  Widget drycleanersTailors(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "New Requests",
                  style: TextStyle(fontSize: 22),
                ),
                SizedBox(height: 5),
                Container(
                  //padding: EdgeInsets.all(20),
                  height: 150,
                  color: Colors.grey[200],
                  width: size.width,
                  child: HelperOrdersUpdate.allOrders.length == 0
                      ? notAvailable()
                      : newListOrdersTailorsDry(),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dues",
                  style: TextStyle(fontSize: 22),
                ),
                SizedBox(height: 5),
                Container(
                  //padding: EdgeInsets.all(20),
                  height: 150,
                  color: Colors.grey[200],
                  width: size.width,
                  child: notAvailable(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget plumbersElectricians(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: size.width,
          color: Colors.white,
          height: 30,
          child: _working
              ? Text(
                  "In Progress",
                  style: TextStyle(fontSize: 22),
                )
              : Text(
                  "Pending Requests",
                  style: TextStyle(fontSize: 22),
                ),
        ),
        SizedBox(height: 5),
        Expanded(
          child: Container(
            color: Colors.grey[200],
            child: HelperOrdersUpdate.allOrders.length == 0
                ? notAvailable()
                : newListOrdersPlumberElect(),
          ),
        ),
      ],
    );
  }

  Widget notAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(
            Icons.list,
            size: 25,
            color: Appdetails.appGreenColor,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "No orders at the moment",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget loading(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          CircularProgressIndicator(),
          SizedBox(
            height: 15,
          ),
          Text(
            "Please Wait\n$title",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
