import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:helpalapp/functions/helpee/helpeeorders.dart';
import 'package:helpalapp/functions/helper/helperorders.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/helper/helpernavbar.dart';
import 'package:helpalapp/screens/helper/helperwalletdrawer.dart';
import 'package:helpalapp/screens/helper/orderpage.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/helper/helperdrawer.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/screens/others/orderdetailsview.dart';

class HelperRecents extends StatefulWidget {
  final String workerId;

  const HelperRecents({Key key, this.workerId}) : super(key: key);

  @override
  _HelperRecentsState createState() => _HelperRecentsState(workerId);
}

class _HelperRecentsState extends State<HelperRecents>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _phone = '';
  bool isPlaying = false;
  //final AuthService _auth = AuthService();
  final ref = FirebaseDatabase.instance;
  final String workerId;
  OurServices _field;

  BuildContext mycontext;

  /*  PageController _pageController;
  int currentIndex = 0;
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease; */

  _HelperRecentsState(this.workerId);

  @override
  void initState() {
    getMyField();
    super.initState();
    _controller = AnimationController(vsync: this);
    //_pageController = PageController();
    HelperOrdersUpdate().setCallBack(refreshState);
  }

  void refreshState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getMyField() async {
    _phone = await AuthService().getLocalString(Appdetails.phoneKey);
    setState(() {});

    print("Checking for field with user $_phone");
    String myField = await AuthService()
        .getDocuementFieldWhere("helpers", _phone, "phone", "field");
    print("Got Field is = $myField");
    setState(() {
      if (myField == "tailor") {
        _field = OurServices.Tailors;
      } else if (myField == "drycleaner") {
        _field = OurServices.Drycleaners;
      } else if (myField == "plumber") {
        _field = OurServices.Plumbers;
      } else if (myField == "electrician") {
        _field = OurServices.Electricians;
      } else if (myField == "deliveryservice") {
        _field = OurServices.DeliveryService;
      } else if (myField == "helpalbike") {
        _field = OurServices.HelpalBike;
      } else if (myField == "helpalcab") {
        _field = OurServices.HelpalCab;
      }
    });
  }

  _walletBtn() {
    return Container(
      margin: EdgeInsets.only(right: 10),
      height: 20,
      width: 20,
      color: Colors.transparent,
      child: InkWell(
        child: Image(
          image: Image.asset("assets/images/icons/wallet.png").image,
          color: Colors.white,
        ),
        onTap: () {
          _scaffoldKey.currentState.openEndDrawer();
        },
      ),
    );
  }

  AppBar myappbar() {
    return AppBar(
      backgroundColor: Appdetails.appGreenColor,
      title: Container(
        alignment: Alignment.center,
        child: _helpal(),
      ),
      actions: [
        _walletBtn(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    mycontext = context;
    Size size = MediaQuery.of(context).size;
    print("Current Field is =" + _field.toString());
    if (_field == null)
      return loadingScreen(size, context);
    else if (_field == OurServices.Plumbers ||
        _field == OurServices.Electricians)
      return plumbersHome(size, context);
    else
      return tailorsHome(size, context);
  }

  Widget loadingScreen(Size size, BuildContext context) {
    return Scaffold(
      drawerScrimColor: Colors.transparent,
      key: _scaffoldKey,
      appBar: myappbar(),
      bottomNavigationBar: HelperBottomNavbar().getnewnavbar(context, 1),
      drawer: HelperDrawer(),
      endDrawer: HelperWalletDrawer(phone: _phone),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Please Wait")
          ],
        ),
      ),
    );
  }

  Widget tailorsHome(Size size, BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawerScrimColor: Colors.transparent,
        key: _scaffoldKey,
        bottomNavigationBar: HelperBottomNavbar().getnewnavbar(context, 1),
        drawer: HelperDrawer(),
        endDrawer: HelperWalletDrawer(phone: _phone),
        appBar: AppBar(
          title: Container(
            alignment: Alignment.center,
            child: _helpal(),
          ),
          actions: [
            _walletBtn(),
          ],
          bottom: TabBar(
            indicatorColor: Colors.black,
            indicatorWeight: 1.0,
            labelColor: Colors.grey[800],
            labelStyle: TextStyle(fontSize: 20),
            onTap: (index) {
              // Tab index when user select it, it start from zero
            },
            tabs: [
              Tab(text: "In Progress"),
              Tab(text: "Completed"),
            ],
          ),
          backgroundColor: Appdetails.appGreenColor,
        ),
        body: TabBarView(
          children: [
            Container(
              child: newListOrdersInprogress(),
            ),
            Container(
              child: newListOrders(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _helpal() {
    AssetImage assetImage = AssetImage('assets/images/mainlogo.png');
    Image image = Image(
      image: assetImage,
      color: Colors.white,
      height: 25,
    );
    return Hero(tag: "helpal", child: image);
  }

  Widget plumbersHome(Size size, BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        drawerScrimColor: Colors.transparent,
        key: _scaffoldKey,
        bottomNavigationBar: HelperBottomNavbar().getnewnavbar(context, 1),
        drawer: HelperDrawer(),
        endDrawer: HelperWalletDrawer(phone: _phone),
        appBar: AppBar(
          title: Container(
            alignment: Alignment.center,
            child: _helpal(),
          ),
          actions: [
            _walletBtn(),
          ],
          backgroundColor: Appdetails.appGreenColor,
        ),
        body: Container(
          child: newListOrders(),
        ),
      ),
    );
  }

  Widget notAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.list,
            size: 50,
            color: Appdetails.appGreenColor,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "No orders at the moment",
            style: TextStyle(fontSize: 25),
          ),
        ],
      ),
    );
  }

  Widget newListOrders() {
    Iterable<QueryDocumentSnapshot> ordersList = HelperOrdersUpdate
        .allOrders.values
        .where((element) => element.data()["status"] == "completed");

    return ordersList.length > 0
        ? MediaQuery.removePadding(
            context: mycontext,
            removeTop: true,
            child: ListView.builder(
              itemCount: ordersList.length,
              itemBuilder: (BuildContext context, int index) {
                String title = ordersList.elementAt(index).data()['helpeename'];
                String orderid = ordersList.elementAt(index).data()['orderid'];
                int timeStamp =
                    int.parse(ordersList.elementAt(index).data()['date']);
                DateTime dt = DateTime.fromMillisecondsSinceEpoch(timeStamp);
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
                            builder: (context) => OrderDetailsView(
                              currentOrder: ordersList.elementAt(index),
                              ishelper: true,
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
                      '  ' + dt.toString(),
                      style: TextStyle(
                          color: Appdetails.grey4,
                          fontStyle: FontStyle.italic,
                          fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          )
        : notAvailable();
  }

  Widget newListOrdersInprogress() {
    Iterable<QueryDocumentSnapshot> ordersList = HelperOrdersUpdate
        .allOrders.values
        .where((element) => element.data()["status"] == "inprogress");

    return ordersList.length > 0
        ? MediaQuery.removePadding(
            context: mycontext,
            removeTop: true,
            child: ListView.builder(
              itemCount: ordersList.length,
              itemBuilder: (BuildContext context, int index) {
                String title = ordersList.elementAt(index).data()['helpeename'];
                String orderid = ordersList.elementAt(index).data()['orderid'];
                int timeStamp =
                    int.parse(ordersList.elementAt(index).data()['date']);
                DateTime dt = DateTime.fromMillisecondsSinceEpoch(timeStamp);
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
                            builder: (context) => OrderDetailsView(
                              currentOrder: ordersList.elementAt(index),
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
                      '  ' + dt.toString(),
                      style: TextStyle(
                          color: Appdetails.grey4,
                          fontStyle: FontStyle.italic,
                          fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          )
        : notAvailable();
  }
  /* Widget ordersList() {
    return FirebaseAnimatedList(
      query: ref
          .reference()
          .child('orders')
          .orderByChild("helper")
          .equalTo("HLP00012"),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        int timeStamp = int.parse(snapshot.value['date']);
        DateTime dt = DateTime.fromMillisecondsSinceEpoch(timeStamp);
        if (DateTime.now().millisecondsSinceEpoch <
            timeStamp + (86400 * 60 * 1000)) {
          if (Appdetails.lastOrderStamp == 0) {
            Appdetails.lastOrderStamp = timeStamp;
            updateListAgain();
          } else if (Appdetails.lastOrderStamp > timeStamp) {
            Appdetails.lastOrderStamp = timeStamp;
            print(Appdetails.lastOrderStamp);
            updateListAgain();
          }
          return new Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey[300])),
            margin: EdgeInsets.only(bottom: 20),
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
                  /* showOrder(
                                        _scaffoldKey.currentContext, snapshot); */
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderPage(
                        orderId: snapshot.key,
                      ),
                    ),
                  );
                },
              ),
              title: Text(
                '  ' + snapshot.value['helpeename'],
                style: TextStyle(color: Colors.grey[800], fontSize: 18),
              ),
              subtitle: Text(
                '  ' + dt.toString(),
                style: TextStyle(
                    color: Appdetails.grey4,
                    fontStyle: FontStyle.italic,
                    fontSize: 16),
              ),
            ),
          );
        } else {
          return new SizedBox(
            height: 0,
          );
        }
      },
      sort: (a, b) {
        int va = int.parse(a.value['date']);
        int vb = int.parse(b.value['date']);

        if (va > vb) {
          print('A ORDER');
          return -1;
        } else {
          print('D ORDER');
          return 1;
        }
      },
    );
  }*/
}

/*
Row(
              children: [
                Container(
                  height: screenHeight / 4,
                  width: screenWidth,
                  color: Appdetails.appGreenColor,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 70,
                      ),
                      _myDivider(),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                              width: screenWidth / 2,
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  InkWell(
                                    child: _workerIcon(),
                                    onTap: () {
                                      createChangeStatusDialog(context);
                                    },
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  InkWell(
                                    child: ShadowText(
                                      text: 'CHANGE STATUS',
                                      fontColor: Colors.white,
                                      shadowColor: Colors.black38,
                                      shadowBlur: 5,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onTap: () {
                                      createChangeStatusDialog(context);
                                    },
                                  )
                                ],
                              )),
                          Container(
                            width: screenWidth / 2,
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                InkWell(
                                  child: _callIcon(),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ContactUsPage()));
                                  },
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                InkWell(
                                  child: ShadowText(
                                    text: 'CONTACT US',
                                    fontColor: Colors.white,
                                    shadowColor: Colors.black38,
                                    shadowBlur: 5,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ContactUsPage()));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
*/
