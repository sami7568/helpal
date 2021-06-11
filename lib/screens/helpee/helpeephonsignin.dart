import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/helpee/helpeedashboard.dart';
import 'package:helpalapp/screens/helpee/helpeeotpscreen.dart';
import 'package:helpalapp/screens/helpee/helpeesignin.dart';
import 'package:helpalapp/screens/helpee/helpeesignup.dart';
import 'package:helpalapp/screens/helper/helpersignin.dart';
import 'package:helpalapp/screens/helper/helpersignup.dart';
import 'package:helpalapp/screens/others/welcome.dart';
import 'package:helpalapp/widgets/ShadowText.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:overlay_container/overlay_container.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HelpeePhonSignin extends StatefulWidget {
  @override
  _HelpeePhonSigninState createState() => _HelpeePhonSigninState();
}

class _HelpeePhonSigninState extends State<HelpeePhonSignin> {
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

  //continue function here login with phone here
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
    await AuthService().saveDefaultLocalKeys(phone, "helpees");
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
    //becomeHelperPopups();
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
        title: Transform.translate(
          offset: Offset(-15, -2.5),
          child: isText
              ? Text(
                  "Mobile Number",
                  style: titleStyle,
                )
              : TextField(
                  autofocus: true,
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

  //continue button here
  getContinuewBtn() {
    return GradButton(
      child: ShadowText(
        text: "Continue",
        fontColor: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 28,
      ),
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
      onWillPop: () => Appdetails.loadScreen(context, WelcomeScreen()),
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: false,
        body: Container(
          height: screenSize.height,
          width: screenSize.width,
          padding: EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(ovrly, BlendMode.darken),
                image: Image.asset("assets/images/helpersigninbg.png").image,
                fit: BoxFit.cover),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Column(
              children: [
                SizedBox(height: 40),
                Transform.translate(
                  offset: Offset(-10, 0),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: BackButton(
                      color: Colors.white,
                      onPressed: () {
                        Appdetails.loadScreen(context, WelcomeScreen());
                      },
                    ),
                  ),
                ),
                SizedBox(height: 25),
                getPhoneField(false),
                Spacer(),
                getContinuewBtn(),
                SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
