import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:helpalapp/functions/voicenoteplayer.dart';
import 'package:intl/intl.dart';

class OrderDetailsView extends StatefulWidget {
  final QueryDocumentSnapshot currentOrder;
  final bool ishelper;

  const OrderDetailsView({Key key, this.currentOrder, this.ishelper = false})
      : super(key: key);
  @override
  _OrderDetailsViewState createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  BuildContext mycontext;

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
    if (widget.currentOrder.data().containsKey("services")) {
      servicesList = widget.currentOrder.data()["services"];
    }
    int date = int.parse(widget.currentOrder.data()['date']);
    //Dates
    DateTime cdate = DateTime.fromMillisecondsSinceEpoch(date);
    String times = DateFormat("dd MMM yyyy, hh:mm a").format(cdate);

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
                          widget.currentOrder.data().length > 0
                              ? widget.currentOrder.data()[
                                  widget.ishelper ? "helpername" : "helpeename"]
                              : "Loading...",
                          style:
                              TextStyle(fontSize: 24, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.currentOrder.data().length > 0
                              ? times
                              : "Loading...",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Voice note
                Text(
                  "Voice Message",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                //Voice note player here
                VoiceNotePlayer(
                  activeColor: widget.ishelper
                      ? Appdetails.appBlueColor
                      : Appdetails.appGreenColor,
                  firestoreFilename: widget.currentOrder.data()["voice"],
                ),
                SizedBox(height: 20),
                Text(
                  "Message",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Container(
                  child: Text(
                    widget.currentOrder.data()["message"],
                  ),
                ),
                Container(
                  child: widget.currentOrder.data().containsKey("inventory")
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Text(
                              "Billing Info",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Inventory Used",
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(height: 10),
                            Container(
                              child: Text(
                                widget.currentOrder.data()["inventory"],
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Helper Fee",
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(height: 10),
                            Container(
                              child: Text(
                                widget.currentOrder.data()["fee"],
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Total Bill",
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(height: 10),
                            Container(
                              child: Text(
                                widget.currentOrder.data()["totalbill"],
                              ),
                            ),
                          ],
                        )
                      : SizedBox(height: 0),
                )
              ],
            )),
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
