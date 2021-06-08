import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/helper/helperorders.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/helper/helperdashboard.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/widgets/custextfield.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

extension on Duration {
  String formatTime() => '$this'.split('.')[0].padLeft(8, '0');
}

class HelperArrived extends StatefulWidget {
  final QueryDocumentSnapshot currentOrder;
  final initialSeconds;

  const HelperArrived({Key key, this.currentOrder, this.initialSeconds = 0})
      : super(key: key);
  @override
  _HelperArrivedState createState() => _HelperArrivedState();
}

class _HelperArrivedState extends State<HelperArrived> {
  double bottomNavbarHeight = 150;

  bool completeBtn = false;
  bool showBottomContents = false;
  Timer _timer;
  int _seconds = 10;
  static String starttime = "00:00";
  BuildContext mycontext;
  //Confirmation complete
  bool showBillingDetails = false;
  TextEditingController feeController = TextEditingController();
  TextEditingController inventoryController = TextEditingController();

  void startTimer() {
    if (widget.initialSeconds > 0) _seconds = widget.initialSeconds;

    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_seconds == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _seconds--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    startCountDown();
    getstartTime();
  }

  void getstartTime() async {
    String st = HelpalStreams.prefs.getString("starttime");
    if (st == null || st == "") {
      if (widget.currentOrder.data().containsKey("starttime")) {
        st = widget.currentOrder.data()["starttime"];
      } else {
        st = "Unknown";
      }
    }
    starttime = st;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  startCountDown() {
    startTimer();
    int currentTimeOut = _seconds + 1;
    if (widget.initialSeconds > 0) {
      currentTimeOut = widget.initialSeconds;
    }
    Future.delayed(Duration(seconds: currentTimeOut), () {
      Size size = MediaQuery.of(mycontext).size;
      setState(() {
        completeBtn = true;
        bottomNavbarHeight = size.height / 2.5;
        showOtherContents();
      });
    });
  }

  showOtherContents() {
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        showBottomContents = true;
      });
    });
  }

  Widget _billingScreen() {
    Size size = MediaQuery.of(mycontext).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      height: size.height,
      width: size.width,
      color: Colors.white,
      child: Column(
        children: [
          Text(
            "Enter the amount to be collected",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          TextField(
            controller: feeController,
            decoration: new InputDecoration(labelText: "Plumbing fee"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
          SizedBox(height: 30),
          TextField(
            controller: inventoryController,
            decoration: new InputDecoration(labelText: "Inventory Used"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    mycontext = context;
    if (!showBillingDetails) {
      Appdetails.completingOrder = false;
    } else {
      Appdetails.completingOrder = true;
    }
    Size size = MediaQuery.of(context).size;
    String newTime = Duration(seconds: _seconds).formatTime().substring(3, 8);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        bottom: PreferredSize(
          child: SizedBox(height: 0),
          preferredSize: Size(size.width, size.height / 10),
        ),
      ),
      body: showBillingDetails
          ? _billingScreen()
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: Image.asset("assets/images/mainlogo.png").image,
                    fit: BoxFit.scaleDown),
              ),
              child: Container(
                alignment: Alignment.center,
                height: size.height / 2,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Work",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 40),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        "in",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 40),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        "Progress",
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 40),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: AnimatedContainer(
        height: bottomNavbarHeight,
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: showBottomContents && !showBillingDetails
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.currentOrder.data()["helpeename"]),
                              Container(
                                width: size.width / 4,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(Icons.message),
                                    Icon(Icons.call)
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Start Time"),
                              Container(child: Text(starttime)),
                            ],
                          ),
                        ],
                      ),
                    )
                  : SizedBox(height: 0),
            ),
            Container(
              child: _seconds == 0
                  ? SizedBox(height: 0)
                  : Text(
                      newTime,
                      style: TextStyle(fontSize: 30),
                    ),
            ),
            Container(
              child: showBillingDetails
                  ? GradButton(
                      child: Text("Complete Order"),
                      onPressed: () {
                        double fee = double.parse(
                            feeController.text.replaceAll(" ", "").trim());
                        double inven = double.parse(inventoryController.text
                            .replaceAll(" ", "")
                            .trim());
                        double totalBill = fee + inven;

                        DialogsHelpal.showYesNoBox(
                            "Confirmation",
                            "Please Confirm\nPlumbing fee : $fee\nInventory Used : $inven",
                            AlertType.info,
                            context, () {
                          //no pressed
                        }, () async {
                          DialogsHelpal.showLoadingDialog(context, false);
                          //yes pressed
                          String orderid =
                              widget.currentOrder.data()["orderid"];
                          dynamic result = await HelperOrdersUpdate()
                              .completeOrderPlumbers(orderid, fee.toString(),
                                  inven.toString(), totalBill.toString());
                          if (result == true) {
                            await AuthService().changeStatusOnline();
                            Navigator.pop(context);
                            Appdetails.loadScreen(context, HelperDash());
                          } else {
                            Navigator.pop(context);
                            DialogsHelpal.showMsgBox(
                                "Erro",
                                "Server is down\nPlease try again",
                                AlertType.error,
                                context,
                                Appdetails.appGreenColor);
                          }
                        });
                      },
                      width: size.width / 100 * 90,
                    )
                  : GradButton(
                      enabled: completeBtn,
                      onPressed: () {
                        DialogsHelpal.showYesNoBox(
                            "Confirmation",
                            "Have you done the work?",
                            AlertType.info,
                            context, () {
                          //no button pressed
                        }, () {
                          //yes pressed
                          setState(() {
                            Appdetails.completingOrder = true;
                            showBillingDetails = true;
                            bottomNavbarHeight = 90;
                          });
                        });
                      },
                      width: size.width / 100 * 90,
                      height: 40,
                      backgroundColor: Appdetails.appGreenColor,
                      child: Text(
                        "Inspection Complete",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
