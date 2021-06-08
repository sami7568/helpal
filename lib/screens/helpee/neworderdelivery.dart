import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/helpee/helpeeorders.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:helpalapp/screens/helpee/helpeedashboard.dart';
import 'package:helpalapp/screens/helpee/locationpickfield.dart';
import 'package:helpalapp/screens/helpee/voicenote.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/widgets/ShadowText.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/screens/helpee/picklocation.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class NewOrderDelivery extends StatefulWidget {
  final String workerName;
  final String workerPhone;
  final String workerID;
  final String workerField;

  const NewOrderDelivery(
      {Key key,
      this.workerName,
      this.workerPhone,
      this.workerID,
      this.workerField})
      : super(key: key);

  @override
  _NewOrderDeliveryState createState() => _NewOrderDeliveryState();
}

class _NewOrderDeliveryState extends State<NewOrderDelivery>
    with SingleTickerProviderStateMixin {
  BuildContext myContext;

  AnimationController _controller;

  TextEditingController comment = new TextEditingController();

  //Order related variables
  bool _fragile = false;
  //Order related variables
  String lastPath = '';
  String filename = '';
  String pickupAdd = '';
  String dropoffAdd = '';
  String pickupLatlng = '';
  String dropoffLatlng = '';

  Duration _duration;

  TextStyle headingStyle() => TextStyle(color: Colors.grey[800], fontSize: 23);
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

  void onRecDone(String path, Duration duration) {
    print("Path is=$path\nDuration is=$duration");
    setState(() {
      lastPath = path;
      _duration = duration;
    });
  }

  void submitOrder() async {
    DialogsHelpal.showLoadingDialog(myContext, false);

    if (_duration == null || _duration.inSeconds > 0) {
      await StorageHandler.upload(
          lastPath, () => print("voice note uploaded"), UploadTypes.VoiceNote);
    }
    //bool serviceStatus = await Location().serviceEnabled();

    String myId = HelpalStreams.prefs.getString(Appdetails.myidKey);
    String myName = HelpalStreams.prefs.getString(Appdetails.nameKey);
    String myPhone = HelpalStreams.prefs.getString(Appdetails.phoneKey);
    String _date = DateTime.now().millisecondsSinceEpoch.toString();

    String orderId = myId + _date;
    //getting filename only
    dynamic locationPickup = pickupAdd + "&&" + pickupLatlng;
    dynamic locationDropoff = dropoffAdd + "&&" + dropoffLatlng;

    dynamic message = comment.text;
    dynamic contactNumber = myPhone;
    dynamic voicenote = filename;
    dynamic helperId = widget.workerID;
    dynamic helpername = widget.workerName;
    dynamic helperphone = widget.workerPhone;
    dynamic helperField = widget.workerField;
    dynamic helpeeID = myId;
    dynamic helpeeName = myName;
    dynamic orderdate = _date;
    dynamic isFragile = _fragile;

    dynamic result = await HelpeeOrdersUpdate().sendNewOrderDelivery(
      locationPickup,
      locationDropoff,
      message,
      isFragile,
      contactNumber,
      voicenote,
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
                hintText: 'Explain through message',
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

  Widget getfragileArea() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: fieldsBgColor(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Checkbox(
              activeColor: Appdetails.appBlueColor,
              value: _fragile,
              onChanged: (newVal) {
                setState(() {
                  _fragile = newVal;
                });
              },
            ),
          ),
          Text(
            'Fragile (Handle with care)',
            style: TextStyle(
              fontSize: 22,
              color: Colors.grey[600].withAlpha(230),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (myContext == null) myContext = context;
    //Getting screen height
    final height = MediaQuery.of(context).size.height;
    //Getting screen height
    final width = MediaQuery.of(context).size.width;
    print('Returned To New Order');
    return Scaffold(
      extendBodyBehindAppBar: false,
     // resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
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
      ),

      //Body
      body: Container(
        child: Column(
          children: <Widget>[
            //Text Fields Scrollable on focus
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    LocationPickField(
                      placeHolder: "Select Pickup Location",
                      onPicked: (address, latlng) {
                        pickupAdd = address;
                        pickupLatlng = latlng;
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 10),
                    LocationPickField(
                      placeHolder: "Select Dropoff Location",
                      onPicked: (address, latlng) {
                        dropoffAdd = address;
                        dropoffLatlng = latlng;
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 10),
                    getfragileArea(),
                    SizedBox(height: 10),
                    getCommentArea(),
                    //getContactArea(),
                    Text(
                      'Audio Instructions',
                      style: headingStyle(),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    VoiceNote(
                      barsColor: Appdetails.appBlueColor,
                      backgroundColor: Appdetails.appBlueColor.withAlpha(40),
                      iconsColor: Colors.grey[500],
                      onDone: onRecDone,
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: 20),
                child: GradButton(
                  onPressed: () {
                    submitOrder();
                  },
                  backgroundColor: Appdetails.appBlueColor,
                  width: width / 2 - (75),
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
