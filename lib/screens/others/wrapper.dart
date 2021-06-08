import 'package:flutter/material.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/screens/helpee/helpeedashboard.dart';
import 'package:helpalapp/screens/helper/helperdashboard.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/others/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  SharedPreferences sharedPreferences;
  BuildContext mycontext;
  String isSignedin = '';
  String accountType = '';

  @override
  void initState() {
    super.initState();
    loadingScreens();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void loadingScreens() {
    accountType = HelpalStreams.prefs.getString(Appdetails.accountTypeKey);
    isSignedin = HelpalStreams.prefs.getString(Appdetails.signinKey);

    //print account type
    print(accountType);
    //print if user signed in or not
    print(isSignedin);

    Future.delayed(Duration(milliseconds: 2000), () {
      //Checking if there is signed in an account
      if (isSignedin == "true") {
        ////checking if account type is HELPEE account
        if (accountType == Appdetails.accountTypeValue_helpee) {
          Appdetails.loadScreen(mycontext, HelpeeDashboard());
        }
        //if helpers account signed in
        else if (accountType == Appdetails.accountTypeValue_helper) {
          Appdetails.loadScreen(mycontext, HelperDash());
        }
        //if there is an error with the data or manipulated
        //start over from welcome screen user have to sign in again
        else {
          Appdetails.loadScreen(mycontext, WelcomeScreen());
        }
      }
      //if no account signed in or first time start go to welcome
      else {
        Appdetails.loadScreen(mycontext, WelcomeScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mycontext = context;

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: SizedBox(height: 0),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text(
                "Please Wait",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
