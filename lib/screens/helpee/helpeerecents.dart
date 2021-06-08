import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/helpee/helpeeorders.dart';
import 'package:helpalapp/functions/helpee/inprogressorder.dart';
import 'package:helpalapp/functions/helper/orderdetailspopup.dart';
import 'package:helpalapp/screens/helpee/helpeeWalletDrawer.dart';
import 'package:helpalapp/screens/helpee/helpeebottomnavbar.dart';
import 'package:helpalapp/screens/helpee/helpeedrawer.dart';
import 'package:helpalapp/screens/others/notavailable.dart';
import 'package:helpalapp/screens/others/orderdetailsview.dart';
import 'package:helpalapp/widgets/completedordertile.dart';
import 'package:helpalapp/widgets/orderinprogresstile.dart';

class RecentHistory extends StatefulWidget {
  @override
  _RecentHistoryState createState() => _RecentHistoryState();
}

class _RecentHistoryState extends State<RecentHistory> {
  //Pages control
  PageController _pageConRecent;
  int currentIndex = 0;
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;
  BuildContext mycontext;

  @override
  void dispose() {
    super.dispose();
    _pageConRecent.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageConRecent = PageController();
    HelpeeOrdersUpdate().setCallBack(refreshState);
  }

  void refreshState() {
    if (mounted) {
      setState(() {});
    }
  }

  onChangedFunction(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    mycontext = context;
    Size size = MediaQuery.of(context).size;

    return getScaffold(size, context);
  }

  Widget getScaffold(Size size, BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(size.width, 50),
          child: Center(
            child: Container(
              color: Colors.white,
              child: TabBar(
                indicatorColor: Appdetails.appBlueColor,
                unselectedLabelColor: Colors.grey[800],
                labelColor: Appdetails.appBlueColor,
                labelStyle: TextStyle(fontSize: 20),
                onTap: (index) {
                  // Tab index when user select it, it start from zero
                },
                tabs: [
                  Tab(text: "In Progress"),
                  Tab(text: "Completed"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              child: listOrders(),
            ),
            Container(
              child: listHistory(),
            ),
          ],
        ),
      ),
    );
  }

  Widget listOrders() {
    Iterable<QueryDocumentSnapshot> ongoing =
        HelpeeOrdersUpdate.allOrders.values.where((element) =>
            element.data()["status"] == "waiting" ||
            element.data()["status"] == "inprogress" ||
            element.data()["status"] == "rejected" ||
            element.data()["status"] == "accepted");
    print("Ongoing orders = " + ongoing.length.toString());
    return ongoing.length == 0
        ? NotAvailable(
            color: Appdetails.appBlueColor,
            title: "There is nothing to show",
          )
        : MediaQuery.removePadding(
            context: mycontext,
            removeTop: true,
            child: ListView.builder(
              itemCount: ongoing.length,
              itemBuilder: (BuildContext context, int index) {
                return InprogressOrderTile(
                  order: ongoing.elementAt(index),
                  context: mycontext,
                );
              },
            ),
          );
  }

  Widget listHistory() {
    Iterable<QueryDocumentSnapshot> history = HelpeeOrdersUpdate
        .allOrders.values
        .where((element) => element.data()["status"] == "completed");

    return history.length == 0
        ? NotAvailable(
            color: Appdetails.appBlueColor,
            title: "History not found",
          )
        : MediaQuery.removePadding(
            context: mycontext,
            removeTop: true,
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (BuildContext context, int index) {
                return CompletedOrderTile(
                  order: history.elementAt(index),
                );
              },
            ),
          );
  }

  /* //this will be used like list tile
  Widget orderTileInProgress(String startdate, String starttime, String title,
      String bill, String orderstatus) {
    return Container(
      child: Column(
        children: [
          //top Row
          Container(
            height: 40,
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Time format 12 hours only
                Text(
                  startdate + ", $starttime",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  bill,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          //Center Ro
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          Image.asset("assets/images/avatar.png").image,
                      maxRadius: 20,
                    ),
                  ],
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    //Helper Field instead of order id
                    Text(
                      orderstatus,
                      style: TextStyle(color: Colors.grey[800], fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  } */

  //this will be used like list tile

  Widget loadingScreen(Size size, BuildContext context) {
    return Scaffold(
      drawerScrimColor: Colors.transparent,
      drawer: HelpeeDrawer(),
      endDrawer: HelpeeWalletDrawer(),
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
}
