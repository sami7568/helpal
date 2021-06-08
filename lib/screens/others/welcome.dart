import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/helpee/helpeedashboard.dart';
import 'package:helpalapp/screens/helpee/helpeeotpscreen.dart';
import 'package:helpalapp/screens/helpee/helpeephonsignin.dart';
import 'package:helpalapp/screens/helpee/helpeesignin.dart';
import 'package:helpalapp/screens/helpee/helpeesignup.dart';
import 'package:helpalapp/screens/helper/helpersignin.dart';
import 'package:helpalapp/screens/helper/helpersignup.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:overlay_container/overlay_container.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  TextEditingController numberController = new TextEditingController();
  final AuthService _auth = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  BuildContext mycontext;

  //Settings
  BoxDecoration btnDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(5),
      boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
    );
  }

  Widget _logo(height) {
    //getting font size
    final logoSize = height / 100 * 20;

    AssetImage assetImage = AssetImage('assets/images/services/logo3.png');
    Image image = Image(
      image: assetImage,
      height: height == 0 ? 30 : logoSize,
    );
    return image;
  }

  Image google() {
    AssetImage assetImage = AssetImage('assets/images/google.png');
    Image image = Image(
      image: assetImage,
      height: 20,
    );
    return image;
  }

  Image facebook() {
    AssetImage assetImage = AssetImage('assets/images/facebook.png');
    Image image = Image(
      image: assetImage,
      height: 20,
    );
    return image;
  }

  Image helpal() {
    AssetImage assetImage = AssetImage('assets/images/services/logo3.png');
    Image image = Image(
      image: assetImage,
      height: 20,
    );
    return image;
  }

  continueWithPhone() {
    if (numberController.text.length < 10) {
      Alert(
          context: context,
          type: AlertType.error,
          title: "Invalid Phone",
          content: Text("Please enter a valid phone number"),
          style: AlertStyle(alertAlignment: Alignment.bottomCenter),
          buttons: [
            DialogButton(
              child: Text(
                "Try again",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              onPressed: () => Navigator.pop(context),
              color: Appdetails.appBlueColor,
            ),
          ]).show();
    } else {
      _auth.loginUserWithPhone(numberController.text.trim(), context,
          phonAutoVerified, phonOtpScreen);
    }
  }

  phonAutoVerified(String phone) async {
    await AuthService().saveLocalString(Appdetails.signinKey, "true");
    await AuthService().saveLocalString(
        Appdetails.accountTypeKey, Appdetails.accountTypeValue_helpee);
    await _auth.saveDefaultLocalKeys(phone, "helpees");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpeeDashboard(),
      ),
    );
  }

  phonOtpScreen(String phoneNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpeeOtpScreen(
          phonNumber: phoneNumber,
        ),
      ),
    );
  }

  continueWithGoogle() async {
    final result = await AuthService().signInWithGoogle(context);
    print(result);
    if (result == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HelpeeSignup(),
        ),
      );
    }
  }

  continueWithFacebook() {}
  signupAsHelper() {
    Appdetails.loadScreen(mycontext, HelperSignup());
  }

  signinAsHelper() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => HelperSignin(),
        transitionDuration: Duration(seconds: 0),
      ),
    );
    //Appdetails.loadScreen(mycontext, HelperSignin());
  }

  becomeHelperEmptyFunction() {
    becomeHelperPopups();
  }

  getButton(String btnTitle, Image btnIcon, Function callback) {
    //Style for title of button
    TextStyle titleStyle = new TextStyle(fontSize: 20, color: Colors.grey[600]);
    //button structer
    return Container(
      height: 50,
      decoration: btnDecoration(),
      child: MaterialButton(
        onPressed: () => callback(),
        child: ListTile(
          title: Transform.translate(
            offset: Offset(-27, -2.5),
            child: Text(
              btnTitle,
              style: titleStyle,
            ),
          ),
          leading: Transform.translate(
            offset: Offset(-16, -2),
            child: btnIcon,
          ),
        ),
      ),
    );
  }

  getButtonHelpers(String btnTitle, Image btnIcon, Function callback) {
    //Style for title of button
    TextStyle titleStyle = new TextStyle(fontSize: 20, color: Colors.grey[600]);
    //button structer
    return Container(
      height: 50,
      decoration: btnDecoration(),
      child: MaterialButton(
        onPressed: () => callback(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            btnIcon,
            SizedBox(width: 15),
            Text(
              btnTitle,
              style: titleStyle,
            ),
          ],
        ),
      ),
    );
  }

  //Styling phone field
  getPhoneField(bool isText) {
    TextStyle titleStyle = new TextStyle(fontSize: 20, color: Colors.grey[600]);
    //button structer
    return Container(
      height: 50,
      decoration: btnDecoration(),
      child: ListTile(
        onTap: () {
          if (isText) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    HelpeePhonSignin(),
                transitionDuration: Duration(seconds: 0),
              ),
            );
          }
        },
        title: Transform.translate(
          offset: Offset(-15, -2.5),
          child: isText
              ? Text(
                  "Mobile Number",
                  style: titleStyle,
                )
              : IgnorePointer(
                  child: TextField(
                    style: titleStyle,
                    controller: numberController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Mobile Number",
                      hintStyle: TextStyle(
                        fontStyle: FontStyle.normal,
                        color: Appdetails.grey4,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
        ),
        leading: Transform.translate(
          offset: Offset(-10, -2.5),
          child: Container(
            padding: EdgeInsets.only(right: 6),
            height: 50,
            width: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  width: 1,
                  color: Appdetails.grey2,
                ),
              ),
            ),
            child: Text(
              "+92",
              style: titleStyle,
            ),
          ),
        ),
      ),
    );
  }

  becomeHelperPopups() {
    Size size = MediaQuery.of(mycontext).size;

    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        duration: Duration(seconds: 20),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        content: Container(
          alignment: Alignment.bottomCenter,
          height: size.height,
          child: Column(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    _scaffoldKey.currentState.hideCurrentSnackBar();
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              Container(
                width: size.width,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 70,
                      height: 5,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20),
                    getButtonHelpers(
                        "Sign in as Helper", helpal(), signinAsHelper),
                    SizedBox(
                      height: 20,
                    ),
                    getButtonHelpers(
                        "Sign up as Helper", helpal(), signupAsHelper),
                    SizedBox(
                      height: 20,
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

  Future<bool> _onBackPressed() async {
    return await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => SystemNavigator.pop(),
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  bool activeBtn = false;
  showSnackbar() {
    /* Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => HelpeeSignin(),
        transitionDuration: Duration(seconds: 0),
      ),
    ); */
    Size size = MediaQuery.of(mycontext).size;
    Alert(
      context: mycontext,
      title: "",
      content: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: size.height,
          width: size.width,
          color: Colors.transparent,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: BackButton(
                  onPressed: () {
                    Navigator.pop(mycontext);
                    numberController.text = "";
                  },
                ),
              ),
              SizedBox(height: 20),
              getPhoneField(false),
              Spacer(),
              _getNumPad(size),
              SizedBox(height: 20),
              getContinuewBtn(),
              SizedBox(
                height: 60,
              )
            ],
          ),
        ),
      ),
      style: AlertStyle(
        backgroundColor: Colors.transparent,
        overlayColor: Colors.white.withOpacity(0.5),
        alertElevation: 0.0,
        alertPadding: EdgeInsets.all(0),
        isButtonVisible: false,
        isCloseButton: false,
        isOverlayTapDismiss: true,
      ),
    ).show();
  }

  getContinuewBtn() {
    return GradButton(
      child: Text("Continue"),
      width: 250,
      backgroundColor: Appdetails.appGreenColor,
      onPressed: () {
        if (numberController.text.length > 9) {
          continueWithPhone();
        } else {
          toast("Please provide a valid number", duration: Toast.LENGTH_SHORT);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color ovrly = Color.fromARGB(100, 0, 0, 0);
    mycontext = context;
    Size screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        body: Container(
          height: screenSize.height,
          width: screenSize.width,
          decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(ovrly, BlendMode.darken),
                image: Image.asset("assets/images/helpersigninbg.png").image,
                fit: BoxFit.cover),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Container(
                  child: _logo(screenSize.height),
                  width: screenSize.width,
                  color: Colors.transparent,
                ),
                SizedBox(height: 20),
                Text(
                  "Continue with",
                  style: TextStyle(
                    color: Appdetails.appGreyColor,
                    fontSize: 30,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: screenSize.width / 100 * 80,
                  child: Column(
                    children: [
                      getPhoneField(true),
                      SizedBox(height: 20),
                      getButton("Google", google(), continueWithGoogle),
                      SizedBox(height: 20),
                      getButton("Facebook", facebook(), continueWithFacebook),
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 1,
                            width: 100,
                            color: Appdetails.appGreyColor,
                          ),
                          SizedBox(width: 40),
                          Container(
                            height: 1,
                            width: 100,
                            color: Appdetails.appGreyColor,
                          ),
                        ],
                      ),
                      Transform.translate(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100)),
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: Text(
                            "OR",
                            style: TextStyle(
                              color: Appdetails.appGreyColor,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        offset: Offset(0, -20),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      InkWell(
                        //onTap: () => becomeHelperPopup(context),
                        child: getButton("Become a Helper", helpal(),
                            becomeHelperEmptyFunction),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Text(
                    "Terms and Conditions",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: Appdetails.appGreyColor,
                        decoration: TextDecoration.underline),
                  ),
                ),
                Container(
                  child: Text(
                    "Helpal © 2021 All Rights Reserved",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18, color: Appdetails.appGreyColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Returns "Otp keyboard input Button"
  Widget _otpKeyboardInputButton({String label, VoidCallback onPressed}) {
    return Container(
      height: 60.0,
      width: 60.0,
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white54,
      ),
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: new Text(
            label,
            style: new TextStyle(
              fontSize: 30.0,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // Current digit
  void _setCurrentDigit(int i) {
    if (numberController.text.length >= 10) return;
    setState(() {
      numberController.text = numberController.text + i.toString();
      if (numberController.text.length > 9)
        activeBtn = true;
      else
        activeBtn = false;
    });
  }

  Widget _getNumPad(Size size) {
    return Container(
      width: size.width,
      height: size.height / 2.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
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
                      if (numberController.text.length == 0) return;
                      setState(() {
                        numberController.text = numberController.text
                            .substring(0, numberController.text.length - 1);
                      });
                    }),
              ],
            ),
          ),
        ],
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
}
