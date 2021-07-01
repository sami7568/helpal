import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/helpee/easyPaisa.dart';
import 'package:helpalapp/functions/helper/helperorders.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/helper/helperdashboard.dart';
import 'package:helpalapp/screens/others/contactus.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/others/welcome.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class HelpeeWalletDrawer extends StatefulWidget {
  final String phone;

  const HelpeeWalletDrawer({Key key, this.phone}) : super(key: key);
  @override
  _HelpeeWalletDrawerState createState() => _HelpeeWalletDrawerState(phone);
}

class _HelpeeWalletDrawerState extends State<HelpeeWalletDrawer> {
  final String phone;
  final AuthService _auth = AuthService();
  String username = "Loading...";

  _HelpeeWalletDrawerState(this.phone);

  @override
  Widget build(BuildContext context) {
    Color drawerColor = Color.fromARGB(200, 255, 255, 255);

    Size size = MediaQuery.of(context).size;
    return Theme(
      data: Theme.of(context).copyWith(
        // Set the transparency here
        canvasColor: Colors.transparent,
      ),
      child: Drawer(
        elevation: 0.0,
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: drawerColor,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    // Important: Remove any padding from the ListView.
                    //padding: EdgeInsets.zero,
                    children: <Widget>[
                      Container(
                        color: Colors.transparent,
                        height: MediaQuery.of(context).size.height / 100 * 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 35),
                            Text(
                              "Balance",
                              style: TextStyle(fontSize: 20),
                            ),
                            //Balance Stream
                            SizedBox(height: 30),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "PKR",
                                ),
                                Container(
                                  child: phone == null ||
                                          phone == '' ||
                                          phone == 'error'
                                      ? Text(
                                          "  Loading...",
                                          style: TextStyle(fontSize: 25),
                                        )
                                      : StreamProvider(
                                          create: (BuildContext context) =>
                                              HelpalStreams().getBalance(),
                                          child: MyBalance(),
                                        ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      child: MaterialButton(
                                        //minWidth: size.width / 100 * 75 / 2,
                                        onPressed: () {},
                                        child: Text("Send Credit"),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      child: MaterialButton(
                                        //minWidth: size.width / 100 * 75 / 2,
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=> easypaisa()));
                                        },
                                        child: Text("Withdraw Credit"),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        height: 10,
                        thickness: 5,
                        color: Appdetails.appBlueColor,
                      ),
                      Container(
                        color: Colors.transparent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Image.asset(
                                "assets/images/icons/history.png",
                                height: 25,
                              ),
                              title: Text(
                                'Transactions History',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              onTap: () {
                                /* Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HelpeeHistory())); */
                              },
                            ),
                            Divider(
                              height: 5,
                              color: Appdetails.grey4,
                            ),
                            ListTile(
                              leading: Image.asset(
                                "assets/images/icons/coupons.png",
                                height: 25,
                              ),
                              title: Text(
                                'Bonus',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              onTap: () {
                                // Update the state of the app.
                                // ...
                                //callbackFunction('transections');
                              },
                            ),
                            Divider(
                              height: 5,
                              color: Appdetails.grey4,
                            ),
                            ListTile(
                              leading: Image.asset(
                                "assets/images/icons/donate.png",
                                height: 25,
                              ),
                              title: Text(
                                'Donate',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              onTap: () {
                                // Update the state of the app.
                                // ...
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ContactUsPage()));
                              },
                            ),
                            Divider(
                              height: 5,
                              color: Appdetails.grey4,
                            ),
                            ListTile(
                              leading: Image.asset(
                                "assets/images/mainlogo.png",
                                height: 25,
                              ),
                              title: Text(
                                'About Helpal Wallet',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              onTap: () {},
                            ),
                            Divider(
                              height: 5,
                              color: Appdetails.grey4,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.only(bottom: 30),
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Text(
                      'Terms of Use',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
