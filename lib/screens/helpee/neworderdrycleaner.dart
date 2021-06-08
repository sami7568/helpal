import 'dart:ui';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/helpee/helpeeorders.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:helpalapp/screens/helpee/drycleanerlisttile.dart';
import 'package:helpalapp/screens/helpee/helpeedashboard.dart';
import 'package:helpalapp/screens/helpee/locationpickfield.dart';
import 'package:helpalapp/screens/helpee/neworderdrycleaneradditem.dart';
import 'package:helpalapp/screens/helpee/newordertailorsadditem.dart';
import 'package:helpalapp/screens/helpee/tailorslisttile.dart';
import 'package:helpalapp/screens/helpee/voicenote.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/widgets/ShadowText.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class NewOrderDryCleaner extends StatefulWidget {
  final String workerName;
  final String workerPhone;
  final String workerID;
  final String workerField;

  const NewOrderDryCleaner(
      {Key key,
      this.workerID,
      this.workerName,
      this.workerPhone,
      this.workerField})
      : super(key: key);

  @override
  _NewOrderDryCleanerState createState() => _NewOrderDryCleanerState();
}

class _NewOrderDryCleanerState extends State<NewOrderDryCleaner>
    with SingleTickerProviderStateMixin {
  List<DrycleanerListTile> basketList = List();
  BuildContext myContext;

  AnimationController _controller;

  TextEditingController comment = new TextEditingController();
  String _currentAddress = 'Select Your Location';
  bool isRecording = false;
  bool isPlaying = false;
  Duration _duration = new Duration(minutes: 0, seconds: 0);
  String lastPath = '';
  String filename = '';
  int minutes = 0;
  int seconds = 0;

  TextStyle headingStyle() => TextStyle(color: Colors.grey[800], fontSize: 22);
  Color fieldsBgColor() => Appdetails.appBlueColor.withAlpha(40);

  @override
  initState() {
    //getAddresses();
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void submitOrder() async {
    DialogsHelpal.showLoadingDialog(myContext, false);
    final Map<String, dynamic> services = Map();

    basketList.forEach((element) async {
      String index = basketList.indexOf(element).toString();
      String title = element.title;
      String price = element.price.toString();
      String imgPath = element.imgFile.path;
      String imgFile = StorageHandler.pathToFilename(element.imgFile.path);
      await StorageHandler.upload(imgPath, () {}, UploadTypes.ServicesImgs);
      Map<String, dynamic> tileMap = {
        "title": title,
        "price": price,
        "imgfile": imgFile,
      };
      services[index] = tileMap;
      print("map added = $index");
    });
    if (_duration.inSeconds > 0) {
      await StorageHandler.upload(
          lastPath, () => print("voice note uploaded"), UploadTypes.VoiceNote);
    }
    //bool serviceStatus = await Location().serviceEnabled();
    String addressForOrder = _currentAddress;
    String myId = HelpalStreams.prefs.getString(Appdetails.myidKey);
    String myName = HelpalStreams.prefs.getString(Appdetails.nameKey);
    String myPhone = HelpalStreams.prefs.getString(Appdetails.phoneKey);
    String _date = DateTime.now().millisecondsSinceEpoch.toString();

    String orderId = myId + _date;
    //getting filename only
    dynamic totalBill = getTotalBill();
    dynamic servicesMap = services;
    dynamic message = comment.text;
    dynamic contactNumber = myPhone;
    dynamic voicenote = StorageHandler.pathToFilename(lastPath);
    dynamic location = addressForOrder;
    dynamic helperId = widget.workerID;
    dynamic helpername = widget.workerName;
    dynamic helperphone = widget.workerPhone;
    dynamic helperField = widget.workerField;
    dynamic helpeeID = myId;
    dynamic helpeeName = myName;
    dynamic orderdate = _date;

    dynamic result = await HelpeeOrdersUpdate().sendNewOrderWithServices(
      totalBill,
      servicesMap,
      message,
      contactNumber,
      voicenote,
      location,
      helperId,
      helpername,
      helperphone,
      helperField,
      helpeeID,
      helpeeName,
      orderdate,
      orderId,
    );
    Navigator.pop(myContext);
    if (result == true) {
      //Loading bar
      DialogsHelpal.showMsgBoxCallback(
          "Success",
          "Submitted Successfully\nPlease wait \nwe are connecting you with helper",
          AlertType.success,
          myContext, () {
        Appdetails.loadScreen(myContext, HelpeeDashboard());
      });
    } else {
      DialogsHelpal.showMsgBox(
          "Error", result, AlertType.error, myContext, Appdetails.appBlueColor);
    }
  }

  Widget getCommentArea() {
    double fontSize = 22;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: fieldsBgColor()),
            child: TextField(
              keyboardType: TextInputType.name,
              style: TextStyle(
                fontSize: fontSize,
              ),
              controller: comment,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Explain through message...',
                hintStyle: TextStyle(fontSize: fontSize),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
              maxLines: 4,
            ),
          )
        ],
      ),
    );
  }

  //Snackbar Laundry Basket
  Widget tailorBasketContent() {
    return Container(
      margin: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
          itemCount: basketList.length,
          itemBuilder: (BuildContext context, int index) {
            var lt = DrycleanerListTile(
              title: basketList.elementAt(index).title,
              imgFile: basketList.elementAt(index).imgFile,
              number: index + 1,
              onRemoved: (int i) {
                basketList.removeAt(i);
                setState(() {});
              },
            );

            return lt;
          },
        ),
      ),
    );
  }

  getBasketCount() {
    return Container(
      height: 25,
      width: 25,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Appdetails.appBlueColor,
      ),
      child: Text(
        basketList.length.toString(),
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }

  getTotalBill() {
    double bill = 0.0;
    basketList.forEach((element) {
      bill += element.price;
    });
    return bill;
  }

  @override
  Widget build(BuildContext context) {
    myContext = context;
    Size size = MediaQuery.of(context).size;
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(15.0),
      topRight: Radius.circular(15.0),
    );
    return SlidingUpPanel(
      panel: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
          ),
          child: Column(
            children: [
              //Small line in header
              Container(
                height: 5,
                width: 60,
                margin: EdgeInsets.only(top: 10, bottom: 20),
                decoration: BoxDecoration(
                  color: Appdetails.appBlueColor,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              //
              Text(
                "LAUNDRY BASKET",
                style: TextStyle(color: Colors.grey[700], fontSize: 24),
              ),

              SizedBox(height: 15),
              Expanded(
                  child: Container(
                color: Colors.grey[100],
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: tailorBasketContent(),
              ))
            ],
          ),
        ),
      ),
      maxHeight: size.height / 100 * 90,
      collapsed: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(borderRadius: radius, color: Colors.white),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "LAUNDRY BASKET",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 5),
                  getBasketCount(),
                ],
              ),
              Spacer(),
              Container(
                height: 25,
                width: 30,
                child: Image(
                  image: Image.asset("assets/images/icons/basket.png").image,
                  color: Appdetails.appBlueColor,
                ),
              ),
              Spacer()
            ],
          ),
        ),
      ),
      body: getScaffold(size.height, size.width),
      borderRadius: radius,
      isDraggable: true,
      backdropEnabled: true,
      backdropTapClosesPanel: false,
    );
  }

  getAppbar(double height, double width) {
    return PreferredSize(
      child: Container(
        padding: EdgeInsets.only(top: 20),
        width: width,
        height: height / 100 * 12,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset("assets/images/bluebg.png").image,
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              child: BackButton(
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Container(
                  alignment: Alignment.center,
                  child: Center(
                    child: Container(
                      child: ShadowText(
                        text: "REQUEST " + widget.workerField.toUpperCase(),
                        fontColor: Colors.white,
                        fontSize: 23,
                        shadowColor: Colors.black.withAlpha(100),
                        shadowBlur: 5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
            ),
            Container(
              width: 60,
            ),
          ],
        ),
      ),
      preferredSize: Size(width, height / 100 * 12),
    );
  }

  getScaffold(double height, double width) {
    return Scaffold(
      appBar: getAppbar(height, width),
      //Body
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    LocationPickField(
                      placeHolder: "Select Pickup Location",
                      onPicked: (address, latlng) {
                        _currentAddress = "$address&&$latlng";
                      },
                    ),
                    SizedBox(height: 20),
                    getCommentArea(),
                    SizedBox(height: 20),
                    Text(
                      'Audio Instructions',
                      style: headingStyle(),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    VoiceNote(
                      backgroundColor: fieldsBgColor(),
                      iconsColor: Colors.grey[600],
                      barsColor: Appdetails.appBlueColor,
                      onDone: (path, duration) {
                        //after recording voice note call back
                        lastPath = path;
                        _duration = duration;
                        filename = StorageHandler.pathToFilename(lastPath);
                        setState(() {});
                      },
                      onDelete: () {
                        lastPath = '';
                        _duration = new Duration();
                        filename = '';
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 20, top: 20),
                margin: EdgeInsets.only(
                  bottom: height / 100 * 20,
                  right: 30,
                  left: 30,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GradButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            myContext,
                            new MaterialPageRoute(
                              builder: (context) => NewOrderDryCleanerAddItem(),
                            ),
                          );
                          if (result != null) {
                            List<DrycleanerListTile> dlt = result;
                            basketList.addAll(dlt);
                            setState(() {});
                          }
                        },
                        backgroundColor: Appdetails.appBlueColor,
                        height: 40,
                        child: Text(
                          'Select Services',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: GradButton(
                        onPressed: () {
                          submitOrder();
                        },
                        backgroundColor: Appdetails.appBlueColor,
                        height: 40,
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
