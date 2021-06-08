import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class DialogsHelpal {
  final AuthService _auth = AuthService();

  static void showLoadingDialog(BuildContext context, bool closable) {
    Alert(
      context: context,
      title: "",
      desc: "Please Wait",
      buttons: [],
      style: AlertStyle(
        isCloseButton: closable,
        isOverlayTapDismiss: false,
      ),
      content: Container(
        padding: EdgeInsets.all(5),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    ).show();
  }

  //Show message box
  static void showMsgBox(String title, String desc, AlertType typeof,
      BuildContext context, Color btnColor) {
    Alert(
      context: context,
      title: title,
      type: typeof,
      desc: desc,
      buttons: [
        DialogButton(
            color: btnColor,
            child: Text(
              "OK",
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context))
      ],
      content: Container(),
    ).show();
  }

  //Show message box
  static void showMsgBoxCallback(String title, String desc, AlertType typeof,
      BuildContext context, Function callback) {
    Alert(
      context: context,
      title: title,
      type: typeof,
      desc: desc,
      buttons: [
        DialogButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              callback();
            })
      ],
      content: Container(),
      style: AlertStyle(
        isOverlayTapDismiss: false,
        isCloseButton: false,
      ),
    ).show();
  }

  //Show message box
  static void showYesNoBox(String title, String desc, AlertType typeof,
      BuildContext context, Function callbackNo, Function callbackYes) {
    Alert(
      context: context,
      title: title,
      type: typeof,
      desc: desc,
      buttons: [
        DialogButton(
            child: Text("Yes"),
            color: Appdetails.appGreenColor,
            onPressed: () {
              Navigator.pop(context);
              callbackYes();
            }),
        DialogButton(
            child: Text("No"),
            color: Appdetails.grey4,
            onPressed: () {
              Navigator.pop(context);
              callbackNo();
            })
      ],
      content: Container(),
      style: AlertStyle(
        isOverlayTapDismiss: false,
        isCloseButton: false,
      ),
    ).show();
  }

  createChangeStatusDialog(BuildContext context, dynamic scaffoldKey,
      Function getstatusCallback) async {
    var _phone = await _auth.getLocalString(Appdetails.phoneKey);
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Text('Change Status'),
            ),
            content: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(
                    color: Colors.red,
                    child: Text(
                      'Go Offline',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      dynamic result = await _auth.updateDocumentField(
                          'helpers', _phone, 'status', 'offline');
                      if (result == 'Data Updated Successfully') {
                        scaffoldKey.currentState.showSnackBar(
                            new SnackBar(content: Text('Status Changed')));
                        getstatusCallback();
                      } else {
                        scaffoldKey.currentState.showSnackBar(new SnackBar(
                            content:
                                Text('There is an error, Please Try Again!')));
                      }
                    },
                  ),
                  MaterialButton(
                    color: Colors.blue,
                    child: Text(
                      'Go Online',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      dynamic result = await _auth.updateDocumentField(
                          'helpers', _phone, 'status', 'online');
                      if (result == 'Data Updated Successfully') {
                        scaffoldKey.currentState.showSnackBar(
                            new SnackBar(content: Text('Status Changed')));
                        getstatusCallback();
                      } else {
                        scaffoldKey.currentState.showSnackBar(new SnackBar(
                            content:
                                Text('There is an error, Please Try Again!')));
                      }
                    },
                  )
                ],
              ),
              height: 50,
            ),
          );
        });
  }

  Widget getHelpalAnimation() {
    return Container(
      height: 200,
      width: 200,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            height: 100,
            width: 100,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
