import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/helper/neworderslist.dart';
import 'package:helpalapp/screens/others/contactus.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/screens/others/welcome.dart';
import 'package:helpalapp/widgets/displaypicture.dart';

class HelperDrawer extends StatefulWidget {
  @override
  _HelperDrawerState createState() => _HelperDrawerState();
}

class _HelperDrawerState extends State<HelperDrawer> {
  final AuthService _auth = AuthService();
  String username = "Loading...";
  String phone = "Loading...";

  void getUsername() async {
    final uname = await _auth.getLocalString(Appdetails.nameKey);

    setState(() {
      username = uname.capitalizeFirstofEach;
    });
    final _phone = await _auth.getLocalString(Appdetails.phoneKey);
    setState(() {
      phone = _phone;
    });
  }


  @override
  void initState() {
    super.initState();
    //firebase notification initialize here

  }

  @override
  Widget build(BuildContext context) {
    getUsername();
    Color drawerColor = Color.fromARGB(200, 255, 255, 255);
    return Theme(
      data: Theme.of(context).copyWith(
        // Set the transparency here
        canvasColor: Colors
            .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
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
                    children: <Widget>[
                      Container(
                        height: 170,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      child: Text(
                                        username,
                                        style: TextStyle(
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24),
                                      ),
                                      onTap: () {
                                        //onpressed
                                        print('See Your Profile');
                                      },
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    InkWell(
                                      child: Text(
                                        'See Your Profile',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      onTap: () {
                                        //onpressed
                                        print('See Your Profile');
                                      },
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            top: 2,
                                            bottom: 2,
                                            right: 2),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            color: Appdetails.appGreenColor),
                                        child: Row(
                                          children: [
                                            Text(
                                              phone,
                                              style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                            SizedBox(width: 10),
                                            Container(
                                              padding: EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  color: Colors.white),
                                              child: Icon(
                                                Icons.edit,
                                                size: 20,
                                              ),
                                            )
                                          ],
                                        )),
                                  ],
                                ),
                                DisplayPicture(
                                  sizeOfDp: 35,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 10,
                        thickness: 10,
                        color: Appdetails.appGreenColor,
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                             ListTile(
                              leading: Image.asset(
                                "assets/images/icons/waiting.png",
                                height: 25,
                              ),
                              title: Text('Available Orders'),
                              onTap: () {
                                Appdetails.loadScreen(context, NewOrdersList());
                              },
                            ),
                            Divider(
                              height: 5,
                              color: Appdetails.grey3,
                            ),
                            ListTile(
                              leading: Image.asset(
                                "assets/images/icons/help.png",
                                height: 25,
                              ),
                              title: Text('Help and Support'),
                              onTap: () {
                                Appdetails.loadScreen(context, ContactUsPage());
                              },
                            ),
                            Divider(
                              height: 5,
                              color: Appdetails.grey3,
                            ),
                            ListTile(
                              leading: Image.asset(
                                "assets/images/icons/privacy.png",
                                height: 25,
                              ),
                              title: Text('Privacy Policy'),
                              onTap: () {},
                            ),
                            Divider(
                              height: 5,
                              color: Appdetails.grey3,
                            ),
                             ListTile(
                              leading: Image.asset(
                                "assets/images/icons/feedback.png",
                                height: 25,
                              ),
                              title: Text('Feedback'),
                              onTap: () {

                              },
                            ),
                            Divider(
                              height: 5,
                              color: Appdetails.grey3,
                            ),
                            ListTile(
                              leading: Image.asset(
                                "assets/images/mainlogo.png",
                                height: 25,
                              ),
                              title: Text('About Helpal'),
                              onTap: () async {},
                            ),
                            Divider(
                              height: 5,
                              color: Appdetails.grey3,
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.exit_to_app,
                                color: Colors.red.shade900,
                              ),
                              title: Text('Log-Out'),
                              onTap: () async {
                                DialogsHelpal.showLoadingDialog(context, false);
                                await _auth.changeStatusOffline();
                                await _auth.signOut();
                                Navigator.pop(context);
                                Appdetails.loadScreen(context, WelcomeScreen());
                              },
                            ),
                            Divider(
                              height: 5,
                              color: Appdetails.grey3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Text(
                      'Helpal\nCopyrights © 2021',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
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
