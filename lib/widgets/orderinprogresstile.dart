import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/helpee/inprogressorder.dart';
import 'package:intl/intl.dart';

class InprogressOrderTile extends StatelessWidget {
  final QueryDocumentSnapshot order;
  final BuildContext context;

  const InprogressOrderTile({Key key, this.order, this.context})
      : super(key: key);

  Widget newOrderTile(String time, String title, String bill, String orderid) {
    bool isrejected = bill == "Rejected" ? true : false;
    return Container(
      child: InkWell(
        onTap: () {
          Appdetails.loadScreen(
            context,
            OrderInProgressHelpee(
              currentOrder: this.order,
            ),
          );
        },
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
                    "$time",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    bill,
                    style: TextStyle(
                        fontSize: 16,
                        color: isrejected ? Colors.red[600] : Colors.grey[800],
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            //Center Ro
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage:
                          Appdetails.getLogo(order.data()["helperfield"]),
                      maxRadius: 20,
                    ),
                  ),
                  SizedBox(width: 10),
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
                        orderid,
                        style: TextStyle(color: Colors.grey[800], fontSize: 12),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = order.data()['helpername'].toString().capitalize();
    String field = order.data()["helperfield"].toString().capitalize();
    String status = order.data()['status'];
    int date = int.parse(order.data()['date']);
    //checking if start time is exist
    if (order.data().containsKey("starttime"))
      date = int.parse(order.data()['starttime']);
    //Dates
    DateTime cdate = DateTime.fromMillisecondsSinceEpoch(date);

    String times = DateFormat("dd MMM yyyy, hh:mm a").format(cdate);

    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[400]),
        ),
      ),
      margin: EdgeInsets.only(bottom: 20),
      child:
          newOrderTile(times, title, status.capitalize(), field.capitalize()),
    );
  }
}
