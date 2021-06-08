import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/helpee/neworder.dart';
import 'package:helpalapp/screens/helpee/newordercabbike.dart';
import 'package:helpalapp/screens/helpee/neworderdelivery.dart';
import 'package:helpalapp/screens/helpee/neworderdrycleaner.dart';
import 'package:helpalapp/screens/helpee/neworderdrycleaneradditem.dart';
import 'package:helpalapp/screens/helpee/newordertailors.dart';
import 'package:helpalapp/screens/others/alertcustom.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class WorkerModel {
  final BuildContext context;
  final QuerySnapshot workerQuery;
  final String distance;
  final String time;
  final Image coverImg;
  final String rating;
  final Map<String, dynamic> tailorServices;

  WorkerModel(this.workerQuery, this.context, this.coverImg, this.rating,
      this.distance, this.time, this.tailorServices) {
    Size screenSize = MediaQuery.of(context).size;

    DocumentSnapshot doc = workerQuery.docs[0];

    String workerId = doc.data()["myid"];
    String workername = doc.data()['name'];
    String workerphone = doc.data()['phone'];
    String workershop = doc.data()['shopname'];
    String workerfield = doc.data()['field'].toString().toLowerCase();
    String workeraddress = doc.data()['shopadd'];
    //distance and time
    String distance = this.distance + " Km";
    String time = this.time;
    print("current selected model is = $workerfield");
    //Setting styles
    var linesColor = Colors.grey[300];
    var detailsStyle = TextStyle(
        color: Colors.grey[800], fontSize: 22, fontWeight: FontWeight.normal);
    var detailsStyleBold = TextStyle(
        color: Colors.grey[800], fontSize: 22, fontWeight: FontWeight.bold);

    AlertAz(
      context: context,
      title: workername,
      style: AlertStyle(
        isOverlayTapDismiss: false,
        alertPadding: EdgeInsets.all(15),
        alertAlignment: Alignment.center,
        titleStyle: TextStyle(color: Colors.grey[800], fontSize: 35),
      ),
      closeIcon: Icon(
        Icons.close,
        color: Colors.grey,
      ),
      image: coverImg,
      content: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          width: screenSize.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Shop: $workershop",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], fontSize: 22),
                  ),
                  SizedBox(height: 10),
                  Text(
                    workeraddress,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: linesColor,
                    ),
                    top: BorderSide(
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Distance ",
                              style: detailsStyleBold,
                            ),
                            Text(
                              "$distance",
                              style: detailsStyle,
                            ),
                          ],
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Ratings ",
                                style: detailsStyleBold,
                              ),
                              Icon(
                                Icons.star,
                                color: Colors.yellow[600],
                              ),
                              Text(
                                rating,
                                style: detailsStyle,
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
              //-------------------DRYCLEANER-----------------//
              workerfield == "drycleaner" || workerfield == "tailor"
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: linesColor,
                          ),
                        ),
                      ),
                      width: screenSize.width,
                      child: ExpansionTile(
                        title: Text(
                          "Service List",
                          style: detailsStyle,
                        ),
                        children: workerfield == "drycleaner"
                            ? laundryList()
                            : tailorList(),
                      ),
                    )
                  : SizedBox(),
              workerfield == "drycleaner" || workerfield == "tailor"
                  ? Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 17),
                      width: screenSize.width,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Urgent Service",
                                style: detailsStyle,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Icon(Icons.check_box,
                                color: Appdetails.appBlueColor),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              //-------------------DRYCLEANER-----------------//
            ],
          ),
        ),
      ),
      buttons: getbuttons(workername, workerphone, workerfield, workerId),
    ).show();
  }
  getbuttons(workername, workerphone, workerfield, workerId) {
    List<DialogButton> btns1 = [
      DialogButton(
        color: Appdetails.appBlueColor,
        margin: EdgeInsets.symmetric(horizontal: 0),
        child: Text(
          "REQUEST",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        onPressed: () {
          switch (workerfield) {
            case "tailor":
              //tailor
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewOrderTailors(
                    workerID: workerId,
                    workerName: workername,
                    workerPhone: workerphone,
                    workerField: workerfield,
                  ),
                ),
              );
              break;
            case "drycleaner":
              //drycleaner
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewOrderDryCleaner(
                    workerID: workerId,
                    workerName: workername,
                    workerPhone: workerphone,
                    workerField: workerfield,
                  ),
                ),
              );
              break;
            case "plumber":
              //plumber
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewOrder(
                    workerID: workerId,
                    workerName: workername,
                    workerPhone: workerphone,
                    workerField: workerfield,
                  ),
                ),
              );
              break;
            case "electrician":
              //electrician
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewOrder(
                    workerID: workerId,
                    workerName: workername,
                    workerPhone: workerphone,
                    workerField: workerfield,
                  ),
                ),
              );
              break;
            case "helpalbike":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewOrderCabBike(
                    workerID: workerId,
                    workerName: workername,
                    workerPhone: workerphone,
                    workerField: workerfield,
                  ),
                ),
              );
              break;
            case "helpalcab":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewOrderCabBike(
                    workerID: workerId,
                    workerName: workername,
                    workerPhone: workerphone,
                    workerField: workerfield,
                  ),
                ),
              );
              break;
            case "deliverybike":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewOrderDelivery(
                    workerID: workerId,
                    workerName: workername,
                    workerPhone: workerphone,
                    workerField: workerfield,
                  ),
                ),
              );
              break;
            case "deliverypickup":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewOrderDelivery(
                    workerID: workerId,
                    workerName: workername,
                    workerPhone: workerphone,
                    workerField: workerfield,
                  ),
                ),
              );
              break;
          }
        },
      ),
    ];

    return btns1;
  }

  List<Widget> tailorList() {
    List<Widget> lndryList = new List();
    this.tailorServices.forEach((element, prices) {
      String serviceName = element;
      double price = double.parse(prices.toString());

      var con = Container(
        height: 35,
        decoration: BoxDecoration(
          color: Appdetails.appBlueColor.withAlpha(20),
          border: Border(bottom: BorderSide(width: 1, color: Colors.white)),
        ),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        serviceName.capitalize(),
                        style: TextStyle(fontSize: 23, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              /* Container(
                height: 50,
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 10),
                child: Text(
                  "Rs " + price.toString(),
                  style: TextStyle(fontSize: 20, color: Colors.grey[500]),
                ),
              ), */
            ],
          ),
        ),
      );
      lndryList.add(con);
    });

    return lndryList;
  }

  List<Widget> laundryList() {
    List<Widget> lndryList = new List();
    int index = 0;
    Appdetails.gentsList.forEach((element) {
      var con = Container(
        height: 35,
        decoration: BoxDecoration(
          color: Appdetails.appBlueColor.withAlpha(20),
          border: Border(bottom: BorderSide(width: 1, color: Colors.white)),
        ),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Appdetails.gentsList.elementAt(index).capitalize(),
                        style: TextStyle(fontSize: 23, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 50,
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 10),
                child: Text(
                  "Rs " + Appdetails.washPrices.elementAt(index).toString(),
                  style: TextStyle(fontSize: 20, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
        ),
      );
      lndryList.add(con);
      index++;
    });

    return lndryList;
    /* return Container(
      margin: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
          itemCount: Appdetails.gentsList.length - 1,
          itemBuilder: (BuildContext context, int index) {
            String serviceT = Appdetails.gentsList.elementAt(index);
            String serviceP = Appdetails.gentsPrices
                .elementAt(index)
                .toString()
                .split('.')[0];

            return Container(
              height: 35,
              decoration: BoxDecoration(
                color: Appdetails.appBlueColor.withAlpha(20),
                borderRadius: BorderRadius.circular(5),
              ),
              margin: EdgeInsets.only(bottom: 5),
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              serviceT.capitalize(),
                              style: TextStyle(
                                  fontSize: 23, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 10),
                      child: Text(
                        "Rs " + serviceP,
                        style: TextStyle(fontSize: 20, color: Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ); */
  }
}
