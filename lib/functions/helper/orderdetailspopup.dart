//import 'package:audioplayer/audioplayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/helper/helperorders.dart';
import 'package:helpalapp/functions/helper/ordernavigation.dart';
import 'package:helpalapp/functions/helper/ordernavigationvehicles.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:helpalapp/functions/voicenoteplayer.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class OrderDetailsPopup extends StatefulWidget {
  final QueryDocumentSnapshot currentOrder;

  const OrderDetailsPopup({Key key, this.currentOrder}) : super(key: key);
  @override
  _OrderDetailsPopupState createState() =>
      _OrderDetailsPopupState(this.currentOrder);
}

class _OrderDetailsPopupState extends State<OrderDetailsPopup> {
  final QueryDocumentSnapshot currentOrder;

  BuildContext mycontext;
  //voice note
  bool isplaying = false;
  //AudioPlayer audioPlugin = new AudioPlayer();

  _OrderDetailsPopupState(this.currentOrder);

  ImageProvider _userlogo() {
    AssetImage assetImage = AssetImage('assets/images/avatar.png');
    Image image = Image(
      image: Appdetails.myDp == null ? assetImage : Appdetails.myDp.image,
      height: 70,
    );
    return image.image;
  }

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

  @override
  Widget build(BuildContext context) {
    mycontext = context;
    Size size = MediaQuery.of(context).size;
    //setting services list
    if (currentOrder.data().containsKey("services")) {
      servicesList = currentOrder.data()["services"];
    }
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
        title: Text(
          "Order Details",
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: [
                    //Helpee DP
                    CircleAvatar(
                      backgroundImage: _userlogo(),
                      maxRadius: 25,
                    ),
                    SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Helpee Name
                        Text(
                          currentOrder.data().length > 0
                              ? currentOrder.data()["helpeename"]
                              : "Loading...",
                          style:
                              TextStyle(fontSize: 24, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 5),
                        /* Text(
                          currentOrder.data().length > 0
                              ? currentOrder.data()["orderid"]
                              : "Loading...",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ), */
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                color: Colors.grey[100],
                child: getPlumbersOrderDetails(size),
              ),

              Spacer(),
              /* Container(
                padding: EdgeInsets.all(10),
                color: Colors.grey[200],
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Bill",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      currentOrder.data().length > 0
                          ? currentOrder.data()["totalbill"]
                          : "Loading...",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ), */
              SizedBox(height: 20),
              //View Details Button
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GradButton(
                    onPressed: () async {
                      //Accept Order Popup
                      DialogsHelpal.showYesNoBox(
                          "Confirmation",
                          "Are you sure want to accecpt this order?",
                          AlertType.info,
                          mycontext, () {
                        print("Cancelled");
                      }, () async {
                        DialogsHelpal.showLoadingDialog(context, false);
                        print("Accepted");
                        dynamic result = await HelperOrdersUpdate()
                            .acceptOrder(currentOrder.data()["orderid"]);
                        Navigator.pop(context);

                        if (result == true) {
                          if (currentOrder
                                  .data()["helperfield"]
                                  .toString()
                                  .startsWith("delivery") ||
                              currentOrder
                                  .data()["helperfield"]
                                  .toString()
                                  .startsWith("helpal")) {
                            Appdetails.loadScreen(
                                mycontext,
                                OrderNavigationVehicles(
                                    currentOrder: currentOrder));
                          } else {
                            Appdetails.loadScreen(mycontext,
                                OrderNavigation(currentOrder: currentOrder));
                          }
                        } else {
                          toast("Please try again",
                              duration: Toast.LENGTH_LONG);
                        }
                      });
                    },
                    width: size.width / 2.5,
                    child: Text(
                      "Accept",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    backgroundColor: Appdetails.appGreenColor,
                  ),
                  GradButton(
                    onPressed: () async {
                      //Reject order popup
                      DialogsHelpal.showYesNoBox(
                          "Warning",
                          "Are you sure want to reject this order?",
                          AlertType.warning,
                          mycontext, () {
                        //Navigator.pop(context);
                      }, () async {
                        DialogsHelpal.showLoadingDialog(context, false);
                        dynamic result = await HelperOrdersUpdate()
                            .rejectOrder(currentOrder.data()["orderid"]);
                        Navigator.pop(context);
                        if (result == true) {
                          Navigator.pop(context);
                        } else {
                          toast("Please try again",
                              duration: Toast.LENGTH_LONG);
                        }
                      });
                    },
                    width: size.width / 2.5,
                    child: Text(
                      "Reject",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    backgroundColor: Colors.redAccent,
                  )
                ],
              ),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }

  getPlumbersOrderDetails(Size size) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                  height: size.height / 100 * 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Fragile, handle with care",
                                        style: TextStyle(fontSize: 20),
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
                        "Voice Message",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      //voice note player here
                      VoiceNotePlayer(
                        activeColor: Appdetails.appGreenColor,
                        firestoreFilename: widget.currentOrder.data()["voice"],
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Message",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      Container(child: Text(currentOrder.data()["message"])),
                    ],
                  )),
            ],
          ),
        ],
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
