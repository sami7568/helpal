import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/helpee/helpeedashboard.dart';
import 'package:helpalapp/screens/helpee/helpeesignup.dart';
import 'package:helpalapp/screens/helper/helperdashboard.dart';
import 'package:helpalapp/screens/helper/helpersignin.dart';
import 'package:helpalapp/screens/helper/helpersignup.dart';
import 'package:helpalapp/screens/helper/helpersignupdetails.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/screens/others/welcome.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HelperOtpScreen extends StatefulWidget {
  final String phonNumber;
  final Function callBack;

  const HelperOtpScreen({Key key, this.phonNumber, this.callBack})
      : super(key: key);

  @override
  _HelperOtpScreenState createState() =>
      new _HelperOtpScreenState(this.phonNumber, callBack);
}

class _HelperOtpScreenState extends State<HelperOtpScreen>
    with SingleTickerProviderStateMixin {
  final phoneNumber;
  final Function callBack;

  _HelperOtpScreenState(this.phoneNumber, this.callBack);
  // Constants
  final int time = 60;
  AnimationController _controller;

  // Variables
  Size _screenSize;
  int _currentDigit;
  int _firstDigit;
  int _secondDigit;
  int _thirdDigit;
  int _fourthDigit;
  int _fifthDigit;
  int _sixthDigit;

  Timer timer;
  int totalTimeInSeconds;
  bool _hideResendButton;

  // Returns "Appbar"
  get _getAppbar {
    return new AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: new InkWell(
        borderRadius: BorderRadius.circular(30.0),
        child: new Icon(
          Icons.arrow_back,
          color: Colors.black,
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
    );
  }

  // Return "Verification Code" label
  get _getVerificationCodeLabel {
    return new Text(
      "Verification Code",
      textAlign: TextAlign.center,
      style: new TextStyle(
        fontSize: 28.0,
        color: Colors.grey[600],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Return "phone" label
  get _getCodeLabel {
    return new Text(
      "Please enter the code you received via SMS on\n$phoneNumber",
      textAlign: TextAlign.center,
      style: new TextStyle(
        fontSize: 18.0,
        color: Colors.grey,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Return "OTP" input field
  get _getInputField {
    double distance = 8;
    return new Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _otpTextField(_firstDigit),
          SizedBox(width: distance),
          _otpTextField(_secondDigit),
          SizedBox(width: distance),
          _otpTextField(_thirdDigit),
          SizedBox(width: distance),
          _otpTextField(_fourthDigit),
          SizedBox(width: distance),
          _otpTextField(_fifthDigit),
          SizedBox(width: distance),
          _otpTextField(_sixthDigit),
        ],
      ),
    );
  }

  // Returns "Otp custom text field"
  Widget _otpTextField(int digit) {
    return new Container(
      width: 40.0,
      height: 40.0,
      alignment: Alignment.center,
      child: new Text(
        digit != null ? digit.toString() : "",
        style: new TextStyle(
          fontSize: 30.0,
          color: Colors.grey[800],
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
      ),
    );
  }

  // Returns "OTP" input part
  get _getInputPart {
    return new Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _getVerificationCodeLabel,
        _getCodeLabel,
        _getInputField,
        _hideResendButton ? _getTimerText : _getResendButton,
        _getOtpKeyboard
      ],
    );
  }

  // Returns "Timer" label
  get _getTimerText {
    return Container(
      height: 32,
      child: new Offstage(
        offstage: !_hideResendButton,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Icon(Icons.access_time),
            new SizedBox(
              width: 5.0,
            ),
            OtpTimer(_controller, 15.0, Colors.black)
          ],
        ),
      ),
    );
  }

  // Returns "Resend" button
  get _getResendButton {
    return new InkWell(
      child: new Container(
        height: 32,
        width: 280,
        decoration: BoxDecoration(
            color: Appdetails.appGreenColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5)),
        alignment: Alignment.center,
        child: new Text(
          "RESEND CODE",
          style: new TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
      ),
      onTap: () async{

        // Resend you OTP via API or anything
        setState(() {});
      },
    );
  }

  // Returns "Otp" keyboard
  get _getOtpKeyboard {
    return new Container(
        height: _screenSize.width - 80,
        child: new Column(
          children: <Widget>[
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "1",
                      onPressed: () {
                        _setCurrentDigit(1);
                      }),
                  _otpKeyboardInputButton(
                      label: "2",
                      onPressed: () {
                        _setCurrentDigit(2);
                      }),
                  _otpKeyboardInputButton(
                      label: "3",
                      onPressed: () {
                        _setCurrentDigit(3);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "4",
                      onPressed: () {
                        _setCurrentDigit(4);
                      }),
                  _otpKeyboardInputButton(
                      label: "5",
                      onPressed: () {
                        _setCurrentDigit(5);
                      }),
                  _otpKeyboardInputButton(
                      label: "6",
                      onPressed: () {
                        _setCurrentDigit(6);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "7",
                      onPressed: () {
                        _setCurrentDigit(7);
                      }),
                  _otpKeyboardInputButton(
                      label: "8",
                      onPressed: () {
                        _setCurrentDigit(8);
                      }),
                  _otpKeyboardInputButton(
                      label: "9",
                      onPressed: () {
                        _setCurrentDigit(9);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new SizedBox(
                    width: 80.0,
                  ),
                  _otpKeyboardInputButton(
                      label: "0",
                      onPressed: () {
                        _setCurrentDigit(0);
                      }),
                  _otpKeyboardActionButton(
                      label: new Icon(
                        Icons.backspace,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_sixthDigit != null) {
                            _sixthDigit = null;
                          } else if (_fifthDigit != null) {
                            _fifthDigit = null;
                          } else if (_fourthDigit != null) {
                            _fourthDigit = null;
                          } else if (_thirdDigit != null) {
                            _thirdDigit = null;
                          } else if (_secondDigit != null) {
                            _secondDigit = null;
                          } else if (_firstDigit != null) {
                            _firstDigit = null;
                          }
                        });
                      }),
                ],
              ),
            ),
          ],
        ));
  }

  // Overridden methods
  @override
  void initState() {
    totalTimeInSeconds = time;
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: time))
          ..addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              setState(() {
                _hideResendButton = !_hideResendButton;
              });
            }
          });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
    _startCountdown();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  final AuthService _auth = AuthService();
  TextEditingController phone = TextEditingController();
  @override
  Widget build(BuildContext context) {

    _screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: _getAppbar,
      backgroundColor: Colors.white,
      body: new Container(
        padding: EdgeInsets.only(top: 20),
        width: _screenSize.width,
//        padding: new EdgeInsets.only(bottom: 16.0),
        child: _getInputPart,
      ),
    );
  }

  // Returns "Otp keyboard input Button"
  Widget _otpKeyboardInputButton({String label, VoidCallback onPressed}) {
    return new Material(
      color: Colors.transparent,
      child: new InkWell(
        onTap: onPressed,
        borderRadius: new BorderRadius.circular(5.0),
        child: new Container(
          height: 80.0,
          width: 80.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: new Center(
            child: new Text(
              label,
              style: new TextStyle(
                fontSize: 30.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Returns "Otp keyboard action Button"
  _otpKeyboardActionButton({Widget label, VoidCallback onPressed}) {
    return new InkWell(
      onTap: onPressed,
      borderRadius: new BorderRadius.circular(40.0),
      child: new Container(
        height: 80.0,
        width: 80.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: new Center(
          child: label,
        ),
      ),
    );
  }

  // Current digit
  void _setCurrentDigit(int i) {
    setState(() {
      _currentDigit = i;
      if (_firstDigit == null) {
        _firstDigit = _currentDigit;
      } else if (_secondDigit == null) {
        _secondDigit = _currentDigit;
      } else if (_thirdDigit == null) {
        _thirdDigit = _currentDigit;
      } else if (_fourthDigit == null) {
        _fourthDigit = _currentDigit;
      } else if (_fifthDigit == null) {
        _fifthDigit = _currentDigit;
      } else if (_sixthDigit == null) {
        _sixthDigit = _currentDigit;

        var otp = _firstDigit.toString() +
            _secondDigit.toString() +
            _thirdDigit.toString() +
            _fourthDigit.toString() +
            _fifthDigit.toString() +
            _sixthDigit.toString();

        // Verify your otp by here. API call
        print('OTP Entered');
        otpEntered(otp);
      }
    });
  }

  void returnToCallBack() {
    print("otp has a return call");
    Navigator.pop(context);
    callBack();
  }

  void otpEntered(String otp) async {
    DialogsHelpal.showLoadingDialog(context, true);
    dynamic isCorrect = await AuthService().verifyCode(otp, context);
    if (isCorrect == true) {
      print("Correct OTP");
      if (callBack != null) {
        Navigator.pop(context);
        returnToCallBack();
        return;
      }
      //after auth checking if account exist in database
      dynamic isExist =
          await AuthService().ifDetailsExists('helpers', phoneNumber);
      //if exist
      if (isExist == true) {
        dynamic isSignedup = await AuthService().ifHelperSignedup(phoneNumber);
        if (isSignedup == true) {
          await AuthService().saveDefaultLocalKeys(phoneNumber, 'helpers');
          await AuthService().saveLocalString(Appdetails.signinKey, "true");
          await AuthService().saveLocalString(
              Appdetails.accountTypeKey, Appdetails.accountTypeValue_helper);
          Navigator.pop(context);
          //Pushing otp screen to display for entering the code manually
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HelperDash(),
            ),
          );
        } else {
          final myField = await AuthService()
              .getDocuementField("helpers", phoneNumber, 'field');
          OurServices _field = OurServices.Plumbers;
          if (myField == null) {
            Navigator.pop(context);
            //Pushing otp screen to display for entering the code manually
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HelperSignup(),
              ),
            );
          } else {
            if (myField == "drycleaner")
              _field = OurServices.Drycleaners;
            else if (myField == "tailor") {
              _field = OurServices.Tailors;
            } else if (myField == "plumber") {
              _field = OurServices.Plumbers;
            } else if (myField == "electrician") {
              _field = OurServices.Electricians;
            } else if (myField == "deliveryservice") {
              _field = OurServices.DeliveryService;
            } else if (myField == "helpalbike") {
              _field = OurServices.HelpalBike;
            } else if (myField == "helpalcab") {
              _field = OurServices.HelpalCab;
            }

            Navigator.pop(context);
            //Pushing otp screen to display for entering the code manually
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HelperSignupDetails(myField: _field, myPhone: phoneNumber),
              ),
            );
          }
        }
      }
      //if not exist in database
      else if (isExist == false) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HelperSignup(),
          ),
        );
      } else {
        DialogsHelpal.showMsgBoxCallback(
            "Error",
            isExist + "\nPlease Contect Providers",
            AlertType.error,
            context,
            onErrorCalback);
      }
    } else {
      print("Wrong OTP");
      DialogsHelpal.showMsgBox("OPT Failed", "Please Enter a Valid OTP Code",
          AlertType.error, context, Appdetails.appGreenColor);
    }
  }

  void onErrorCalback() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WelcomeScreen(),
      ),
    );
  }

  Future<Null> _startCountdown() async {
    setState(() {
      _hideResendButton = true;
      totalTimeInSeconds = time;
    });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
  }

  void clearOtp() {
    _fourthDigit = null;
    _thirdDigit = null;
    _secondDigit = null;
    _firstDigit = null;
    setState(() {});
  }
}

class OtpTimer extends StatelessWidget {
  final AnimationController controller;
  double fontSize;
  Color timeColor = Colors.black;

  OtpTimer(this.controller, this.fontSize, this.timeColor);

  String get timerString {
    Duration duration = controller.duration * controller.value;
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Duration get duration {
    Duration duration = controller.duration;
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget child) {
          return new Text(
            timerString,
            style: new TextStyle(
                fontSize: fontSize,
                color: timeColor,
                fontWeight: FontWeight.w600),
          );
        });
  }
}
