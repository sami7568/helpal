import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/chatwindow.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:helpalapp/functions/voicenoteplayer.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class OrderInProgressHelpee extends StatefulWidget {
  final QueryDocumentSnapshot currentOrder;

  const OrderInProgressHelpee({Key key, this.currentOrder}) : super(key: key);
  @override
  _OrderInProgressHelpeeState createState() =>
      _OrderInProgressHelpeeState(this.currentOrder);
}

class _OrderInProgressHelpeeState extends State<OrderInProgressHelpee> {
  final QueryDocumentSnapshot currentOrder;
  bool isrejected = false;

  BuildContext mycontext;
  //voice note
  //Chat window
  bool chatwindowShowing = false;
  final ref = FirebaseDatabase.instance;

  TextEditingController messageController = TextEditingController();

  ScrollController messagesScroll = ScrollController();

  _OrderInProgressHelpeeState(this.currentOrder);
  TextStyle headingStyle() => TextStyle(color: Colors.grey[800], fontSize: 26);

  Color fieldsBgColor() => Appdetails.appBlueColor.withAlpha(40);

  getMyDp() async {
    await AuthService()
        .getLocalString(Appdetails.photoidKey)
        .then((value) async {
      print("my photo id is=$value");
      if (value == null || value.length == 0) return;

      String url = await StorageHandler.getDownloadUrl(
          value, UploadTypes.DisplayPicture);
      Appdetails.myDp = Image.network(url);
    });
  }

  PanelController panelController = PanelController();
  @override
  Widget build(BuildContext context) {
    mycontext = context;
    //getting current status
    if (currentOrder.data()["status"] == "rejected") isrejected = true;

    //getting size
    Size size = MediaQuery.of(context).size;
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(15.0),
      topRight: Radius.circular(15.0),
    );
    //setting services list
    if (currentOrder.data().containsKey("services")) {
      servicesList = currentOrder.data()["services"];
    }

    return WillPopScope(
      onWillPop: () {
        if (chatwindowShowing)
          panelController.close();
        else if (!chatwindowShowing) Navigator.pop(context);
        return;
      },
      child: isrejected
          ? getScaffold(size)
          : SlidingUpPanel(
              controller: panelController,
              onPanelOpened: () => chatwindowShowing = true,
              onPanelClosed: () => chatwindowShowing = false,
              panel: Scaffold(
                body: ChatWindow(
                  orderId: currentOrder.data()["orderid"],
                ),
              ),
              maxHeight: size.height / 100 * 90,
              collapsed: Material(
                color: Colors.transparent,
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: radius, color: Colors.white),
                  child: Column(
                    children: [
                      //Small line in header
                      Container(
                        height: 5,
                        width: 60,
                        margin: EdgeInsets.only(top: 10, bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withAlpha(100),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      //
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                "Contact Helper",
                                style: headingStyle(),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      print("show Calling");
                                      panelController.open();
                                    },
                                    child: Icon(
                                      Icons.chat,
                                      color: Appdetails.appBlueColor,
                                      size: 25,
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    height: 40,
                                    width: 2,
                                    color: Colors.grey[200],
                                  ),
                                  Icon(
                                    Icons.call,
                                    color: Appdetails.appBlueColor,
                                    size: 25,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              body: getScaffold(size),
              borderRadius: radius,
              isDraggable: true,
              backdropEnabled: true,
              backdropTapClosesPanel: false,
            ),
    );
  }

  getScaffold(Size size) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.grey[600],
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(right: 50),
          child: Text(
            "Order Details".toUpperCase(),
            style: TextStyle(color: Colors.grey[800], fontSize: 23),
          ),
        ),
      ),
      bottomNavigationBar: isrejected
          ? PreferredSize(
              child: Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: GradButton(
                          child: Text(
                            "Remove Order",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          backgroundColor: Appdetails.appBlueColor,
                          height: 40,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        child: GradButton(
                          child: Text(
                            "Live Again",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          backgroundColor: Appdetails.appBlueColor,
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              preferredSize: Size(size.width, 50),
            )
          : Container(height: 0),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    //Helpee DP
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: Appdetails.getLogo(
                            currentOrder.data()["helperfield"]),
                        maxRadius: 25,
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Helpee Name
                        Text(
                          currentOrder.data().length > 0
                              ? currentOrder.data()["helpername"]
                              : "Loading...",
                          style: headingStyle(),
                        ),
                        SizedBox(height: 5),
                        Text(
                          currentOrder.data().length > 0
                              ? currentOrder
                                  .data()["helperfield"]
                                  .toString()
                                  .capitalize()
                              : "Loading...",
                          style:
                              TextStyle(fontSize: 22, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
                child: Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                ),
              ),
              isrejected
                  ? Container(
                      child: Text(
                        "Order Rejected",
                        style: TextStyle(color: Colors.red[600], fontSize: 20),
                      ),
                    )
                  : Container(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: getPlumbersOrderDetails(size),
              ),
              //View Details Button
            ],
          ),
        ),
      ),
    );
  }

  getPlumbersOrderDetails(Size size) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradButton(
              backgroundColor: Appdetails.appBlueColor,
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          "View On Map",
                          style: TextStyle(fontSize: 23, color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            widget.currentOrder.data().containsKey("isfragile")
                ? widget.currentOrder.data()["isfragile"] == true
                    ? Container(
                        height: 50,
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                            color: Colors.red.withAlpha(40),
                            borderRadius: BorderRadius.circular(6)),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Fragile",
                              style: headingStyle(),
                            ),
                            Icon(
                              Icons.check,
                              color: Colors.grey[600],
                            )
                          ],
                        ),
                      )
                    : Container()
                : Container(),
            //Voice note
            Text(
              "Audio Instructions",
              style: headingStyle(),
            ),
            SizedBox(height: 10),

            VoiceNotePlayer(
              firestoreFilename: currentOrder.data()["voice"],
              activeColor: Appdetails.appBlueColor,
            ),
            SizedBox(height: 20),
            Text(
              "Message Explanation",
              style: headingStyle(),
            ),
            SizedBox(height: 13),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: fieldsBgColor(),
              ),
              height: 150,
              width: size.width,
              padding: EdgeInsets.all(10),
              child: Text(
                currentOrder.data()["message"],
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> servicesList = {};
  getTailorsOrderDetails(Size size) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: size.height / 100 * 40,
                child: servicesList.length == 0
                    ? SizedBox(
                        height: 0,
                      )
                    : MediaQuery.removePadding(
                        context: mycontext,
                        removeTop: true,
                        child: ListView.builder(
                          itemCount: servicesList.length,
                          itemBuilder: (BuildContext context, int index) {
                            String serviceT =
                                servicesList.keys.elementAt(index);
                            String serviceP =
                                servicesList.values.elementAt(index);

                            return Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)),
                              margin: EdgeInsets.only(bottom: 5),
                              child: ListTile(
                                title: Text(serviceT.capitalize()),
                                subtitle: Text("Charges:" + serviceP),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double getheight() {
    double lnt = double.parse(servicesList.length.toString());
    return lnt * 80;
  }
}
