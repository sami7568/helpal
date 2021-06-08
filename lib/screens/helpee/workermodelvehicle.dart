import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:helpalapp/screens/helpee/neworder.dart';
import 'package:helpalapp/screens/helpee/newordercabbike.dart';
import 'package:helpalapp/screens/helpee/neworderdelivery.dart';
import 'package:helpalapp/screens/others/alertcustom.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class WorkerModelVehicle {
  final BuildContext context;
  final QuerySnapshot workerQuery;
  final String distance;
  final String time;
  //final Image coverImg;
  final String rating;

  WorkerModelVehicle(
      this.workerQuery, this.context, this.distance, this.time, this.rating) {
    Size screenSize = MediaQuery.of(context).size;
    DocumentSnapshot doc = workerQuery.docs[0];

    String workername = doc.data()['name'];
    String workerId = doc.data()['myid'];
    String workerfield = doc.data()['field'];
    String workerphone = doc.data()['phone'];
    print(
        "Name:$workername\nID:$workerId\nField:$workerfield\nPhone:$workerphone");
    //Vehicle info
    String maker = workerQuery.docs[0].data()["maker"];
    String vehicle = workerQuery.docs[0].data()["vehicle"];
    if (vehicle == null) vehicle = "";
    String vehicleNumber = workerQuery.docs[0].data()["regnum"];
    String model = workerQuery.docs[0].data()["model"];
    String color = workerQuery.docs[0].data()["color"];
    if (color == null) color = "RED";
    //distance and time
    String distance = this.distance + " KM";
    String time = this.time;
    var linesColor = Colors.grey[300];
    //var workeraddress = doc.data()['shopadd'];
    var detailsStyle = TextStyle(
        color: Colors.grey[800], fontSize: 22, fontWeight: FontWeight.normal);

    Alert(
      context: context,
      title: "",
      style: AlertStyle(
        isOverlayTapDismiss: false,
        titleStyle: TextStyle(color: Colors.grey[800], fontSize: 35),
      ),
      closeIcon: Icon(
        Icons.close,
        color: Colors.grey[800],
      ),
      image: CircleAvatar(
        maxRadius: 50,
        backgroundImage: Image.asset("assets/images/avatar.png").image,
      ),
      /* image: Container(
        height: 120,
        decoration: BoxDecoration(
            image: DecorationImage(image: coverImg.image, fit: BoxFit.cover)),
      ), */
      content: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 0),
        margin: EdgeInsets.only(top: 0),
        width: screenSize.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              workername,
              style: TextStyle(color: Colors.grey[800], fontSize: 30),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  rating,
                  style: TextStyle(color: Colors.grey[800], fontSize: 24),
                ),
                Icon(
                  Icons.star,
                  color: Colors.yellow[600],
                  size: 20,
                )
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: linesColor,
                  ),
                  bottom: BorderSide(
                    color: linesColor,
                  ),
                ),
              ),
              width: screenSize.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        maker.toUpperCase(),
                        style: detailsStyle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0, 0.5),
                                blurRadius: 3)
                          ]),
                      child: Container(
                        color: Appdetails.appBlueColor.withAlpha(40),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          vehicleNumber.toUpperCase(),
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: linesColor,
                  ),
                ),
              ),
              width: screenSize.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "$model Model",
                        style: detailsStyle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: linesColor,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        color,
                        style: detailsStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: linesColor,
                  ),
                ),
              ),
              width: screenSize.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        distance,
                        style: detailsStyle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: linesColor,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        time,
                        style: detailsStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: linesColor,
                  ),
                ),
              ),
              width: screenSize.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Use Wallet Balance",
                        style: detailsStyle,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: CupertinoSwitch(
                      value: true,
                      onChanged: (val) {},
                      activeColor: Appdetails.appBlueColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      buttons: getbuttons(workername, workerphone, workerfield, workerId),
    ).show();
  }
  getbuttons(workername, workerphone, workerfield, workerid) {
    List<DialogButton> btns2 = [
      DialogButton(
        color: Appdetails.appBlueColor,
        margin: EdgeInsets.symmetric(horizontal: 0),
        child: Text(
          "REQUEST",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        onPressed: () {
          if (workerfield == "helpalbike" || workerfield == "helpalcab") {
            Appdetails.loadScreen(
              this.context,
              NewOrderCabBike(
                workerName: workername,
                workerField: workerfield,
                workerID: workerid,
                workerPhone: workerphone,
              ),
            );
          } else {
            Appdetails.loadScreen(
              this.context,
              NewOrderDelivery(
                workerName: workername,
                workerField: workerfield,
                workerID: workerid,
                workerPhone: workerphone,
              ),
            );
          }
        },
      ),
    ];

    return btns2;
  }
}
