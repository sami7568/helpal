import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:intl/intl.dart';

class CompletedOrderTile extends StatelessWidget {
  final QueryDocumentSnapshot order;

  const CompletedOrderTile({Key key, this.order}) : super(key: key);

  Widget newOrderTile(String time, String title, String bill, String orderid) {
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
                  "$time",
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
                      orderid,
                      style: TextStyle(color: Colors.grey[800], fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = order.data()['helpername'].toString().capitalize();
    String field = order.data()["helperfield"].toString().capitalize();
    int date = int.parse(order.data()['date']);
    //Dates
    DateTime cdate = DateTime.fromMillisecondsSinceEpoch(date);
    String times = DateFormat("dd MMM yyyy, hh:mm a").format(cdate);

    String totalbill =
        order.data()['totalbill'].toString().split(".")[0] + " PKR";

    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[400]),
        ),
      ),
      margin: EdgeInsets.only(bottom: 20),
      child: newOrderTile(times, title, totalbill, field),
    );
  }
}
