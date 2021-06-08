import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/helpee/helpeeorders.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:helpalapp/screens/helpee/helpeedashboard.dart';
import 'package:helpalapp/screens/helpee/locationpickfield.dart';
import 'package:helpalapp/screens/helpee/picklocation.dart';
import 'package:helpalapp/screens/helpee/voicenote.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/widgets/ShadowText.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class NewOrder extends StatefulWidget {
  final String workerName;
  final String workerPhone;
  final String workerID;
  final String workerField;

  const NewOrder(
      {Key key,
      this.workerID,
      this.workerField,
      this.workerName,
      this.workerPhone})
      : super(key: key);

  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder>
    with SingleTickerProviderStateMixin {
  //Build context
  BuildContext myContext;
  //Animation controller
  AnimationController _controller;

  //Order controllers
  TextEditingController comment = new TextEditingController();
  String _currentAddress = 'Select Your Location';
  //Recorder
  Duration _duration = new Duration(minutes: 0, seconds: 0);
  String lastPath = '';
  String filename = '';
  //variables colors
  Color containersBackgroundColor() => Appdetails.appBlueColor.withAlpha(40);
  Color bodyBackgroundColor() => Colors.white;

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

  void setDuration(Duration dur) {
    setState(() {
      _duration = dur;
    });
  }

  void submitOrder() async {
    DialogsHelpal.showLoadingDialog(myContext, false);

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
    dynamic message = comment.text;
    dynamic contactNumber = myPhone;
    dynamic voicenote = filename;
    dynamic location = addressForOrder;
    dynamic helperId = widget.workerID;
    dynamic helpername = widget.workerName;
    dynamic helperphone = widget.workerPhone;
    dynamic helperField = widget.workerField;
    dynamic helpeeID = myId;
    dynamic helpeeName = myName;
    dynamic orderdate = _date;

    dynamic result = await HelpeeOrdersUpdate().sendNewOrder(
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
              color: Appdetails.appBlueColorWithAlpha,
            ),
            child: TextField(
              keyboardType: TextInputType.name,
              style: TextStyle(
                fontSize: fontSize,
              ),
              controller: comment,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Explain through message (optional)',
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

  @override
  Widget build(BuildContext context) {
    myContext = context;
    //Getting screen height
    final height = MediaQuery.of(context).size.height;
    //Getting screen height
    final width = MediaQuery.of(context).size.width;
    print('Returned To New Order');
    return Scaffold(
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
        color: bodyBackgroundColor(),
        child: Column(
          children: <Widget>[
            //Text Fields Scrollable on focus
            Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      //height: height / 100 * 60,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          LocationPickField(
                            onPicked: (address, latlng) {
                              print("Call back received in order create");
                              _currentAddress = "$address&&$latlng";
                            },
                          ),
                          SizedBox(height: 10),
                          getCommentArea(),
                          SizedBox(height: 10),
                          Text(
                            'Explain your problem through the voice note',
                            style: TextStyle(
                                color: Colors.grey[800], fontSize: 20),
                          ),
                          SizedBox(height: 10),
                          VoiceNote(
                            backgroundColor: containersBackgroundColor(),
                            iconsColor: Colors.grey[600],
                            barsColor: Appdetails.appBlueColor,
                            onDone: (path, duration) {
                              //after recording voice note call back
                              lastPath = path;
                              _duration = duration;
                              filename =
                                  StorageHandler.pathToFilename(lastPath);
                              setState(() {});
                            },
                            onDelete: () {
                              lastPath = '';
                              _duration = new Duration();
                              filename = '';
                              setState(() {});
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: 20),
                child: GradButton(
                  onPressed: () => submitOrder(),
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
