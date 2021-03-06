import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/others/contactus.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/screens/others/welcome.dart';
import 'package:helpalapp/widgets/displaypicture.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class HelpeeDrawer extends StatefulWidget {
  @override
  _HelpeeDrawerState createState() => _HelpeeDrawerState();
}

class _HelpeeDrawerState extends State<HelpeeDrawer> {
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
                            SizedBox(height: 20),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                            fontSize: 15,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                      onTap: () {
                                        //onpressed
                                        var re =requestMethod();

                                        print('See Your Profile');
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
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
                                            color: Appdetails.appBlueColor),
                                        child: Row(
                                          children: [
                                            Text(
                                              phone,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16),
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
                                                size: 10,
                                              ),
                                            )
                                          ],
                                        )),
                                  ],
                                ),
                                DisplayPicture(
                                  sizeOfDp: 40,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 5,
                        thickness: 5,
                        color: Appdetails.appBlueColor,
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            /* ListTile(
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
                            ), */
                            ListTile(
                              leading: Image.asset(
                                "assets/images/icons/help.png",
                                height: 25,
                              ),
                              title: Text(
                                'Help and Support',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              onTap: () {
                                Appdetails.loadScreen(context, ContactUsPage());
                              },
                            ),
                            Divider(
                              height: 5,
                              color: Appdetails.grey4,
                            ),
                            ListTile(
                              leading: Image.asset(
                                "assets/images/icons/privacy.png",
                                height: 25,
                              ),
                              title: Text(
                                'Privacy Policy',
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
                            /* ListTile(
                              leading: Image.asset(
                                "assets/images/icons/feedback.png",
                                height: 25,
                              ),
                              title: Text('Feedback'),
                              onTap: () {},
                            ),
                            Divider(
                              height: 5,
                              color: Appdetails.grey3,
                            ), */
                            ListTile(
                              leading: Image.asset(
                                "assets/images/mainlogo.png",
                                height: 25,
                              ),
                              title: Text(
                                'About Helpal',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              onTap: () async {},
                            ),
                            Divider(
                              height: 5,
                              color: Appdetails.grey4,
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.exit_to_app,
                                color: Colors.red.shade900,
                              ),
                              title: Text(
                                'Sign out',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              onTap: () async {
                                DialogsHelpal.showLoadingDialog(context, false);
                                await _auth.signOut();
                                Navigator.pop(context);
                                Appdetails.loadScreen(context, WelcomeScreen());
                              },
                            ),
                            Divider(
                              height: 5,
                              color: Appdetails.grey4,
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
                      'Helpal\nCopyrights ?? 2021',
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

  Future<void> requestMethod() async {

      String soap = '''<?xml version="1.0"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dto="http://dto.txn.part.pg.systems.com/" xmlns:dto1="http://dto.common.pg.systems.com/">
	   	<soapenv:Header></soapenv:Header>
		<soapenv:Body>
		<dto:initiateTransactionRequestType>
			<dto1:username>pg-systems</dto1:username>
		    <dto1:password>d28df893f1c08c6a5ce0efa896c2943e</dto1:password>
		    <orderId>111222</orderId>
		    <storeId>641</storeId>
		    <transactionAmount>5</transactionAmount>
		    <transactionType>MA</transactionType>
		    <msisdn>03457878789</msisdn>
		    <mobileAccountNo>03457878789</mobileAccountNo>
		    <emailAddress>a@a.com</emailAddress>
		</dto:initiateTransactionRequestType>
		</soapenv:Body>
		</soapenv:Envelope>''';

      http.Response response = await http.post(
        'https://easypaystg.easypaisa.com.pk/easypay/PluginPageSource.jsf',
        headers: {
          'content-type': 'text/xmlc',
          'authorization': 'bWVzdHJlOnRvdHZz',
          'SOAPAction': 'http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL',
        },
        body: utf8.encode(soap),
      );

      Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      print(response.statusCode);
      return response.body;

  }
}
