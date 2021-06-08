import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/helpee/helpeedrawer.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/widgets/custextfield.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HelperSettingsAccount extends StatefulWidget {
  @override
  _HelperSettingsAccountState createState() => _HelperSettingsAccountState();
}

class _HelperSettingsAccountState extends State<HelperSettingsAccount>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _email = '';
  String _username = '';
  String _phone = '';
  DocumentSnapshot savedSnapshot;

  TextEditingController fullnameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController passController = new TextEditingController();

  final AuthService _auth = AuthService();

  Future getProfileDetails() async {
    final phone = HelpalStreams.prefs.getString(Appdetails.phoneKey);
    final snapshot =
        await FirebaseFirestore.instance.collection('helpers').doc(phone).get();
    if (!snapshot.exists) {
      print("User Data Not Exist");
    } else {
      print('Getting data');
      Map<String, dynamic> data = snapshot.data();
      setState(() {
        savedSnapshot = snapshot;
        _email = data['email'];
        _username = data['name'];
        _phone = data['phone'];
        fullnameController.text = _username;
        emailController.text = _email;
        phoneController.text = _phone;
      });
    }
  }

  Future setProfileDetails(BuildContext context) async {
    DialogsHelpal.showLoadingDialog(context, false);
    Map<String, dynamic> data = savedSnapshot.data();
    if (fullnameController.text == "" || fullnameController.text.length < 3) {
      Navigator.pop(context);

      return "Please provide a valid name";
    }
    if (emailController.text.startsWith("Email") ||
        !emailController.text.contains("@")) {
      Navigator.pop(context);

      return "Please provide a valid email";
    }
    data['name'] = fullnameController.text;
    data['email'] = emailController.text;
    //data['phone'] = phoneController.text;
    print(data);
    dynamic result = await _auth.changeProfileDetails(data, _phone);
    print(result.toString());
    Navigator.pop(context);
    if (!result.toString().contains('Error')) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    getProfileDetails();
    _controller = AnimationController(vsync: this);
    //DBUpdater().initDatabase();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Getting screen height
    final height = MediaQuery.of(context).size.height;
    //Getting screen height
    final width = MediaQuery.of(context).size.width;
    //getting contents height
    final contentsHeight = height / 100 * 70;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Container(
          child: Center(
            child: Text("ACCOUNT SETTINGS"),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      //bottomNavigationBar: HelpeeBottomNavbar().getCustomBottomBar(context, 3),
      drawer: HelpeeDrawer(),
      extendBodyBehindAppBar: true,
      //resizeToAvoidBottomInset: false,
      body: Container(
        child: Stack(
          children: [
            Container(
              //margin: EdgeInsets.only(top: height / 100 * 15),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: height / 100 * 15,
                    ),
                    Container(
                      height: contentsHeight,
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: Form(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Change Your Personal Detail',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 25),
                            ),
                            CusTextField(
                              controller: fullnameController,
                              showLabel: true,
                              labelText: 'Full Name',
                              hint: 'Loading...',
                              obsecure: false,
                              icon: Icon(
                                Icons.person,
                                color: Appdetails.appGreenColor,
                              ),
                              validator: (val) => val.isEmpty
                                  ? 'Please Enter Your Name!'
                                  : null,
                              onChanged: (val) {
                                setState(() => _email = val);
                              },
                            ),
                            CusTextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              showLabel: true,
                              labelText: 'Email',
                              hint: 'Loading...',
                              obsecure: false,
                              icon: Icon(
                                Icons.email,
                                color: Appdetails.appGreenColor,
                              ),
                              validator: (val) =>
                                  val.isEmpty ? 'Enter Email!' : null,
                              onChanged: (val) {
                                setState(() => _email = val);
                              },
                            ),
                            CusTextField(
                              controller: phoneController,
                              enabled: false,
                              keyboardType: TextInputType.number,
                              showLabel: true,
                              labelText: 'Phone',
                              hint: 'Loading...',
                              obsecure: false,
                              icon: Icon(
                                Icons.phone_android,
                                color: Appdetails.appGreenColor,
                              ),
                              validator: (val) => val.isEmpty
                                  ? 'Empty Field Not Allowed'
                                  : null,
                              onChanged: (val) {
                                setState(() => _email = val);
                              },
                            ),
                            /* CusTextField(
                            controller: passController,
                            showLabel: true,
                            labelText: 'Password',
                            hint: 'Loading...',
                            obsecure: true,
                            icon: Icon(
                              Icons.lock,
                              color: Appdetails.appGreenColor,
                            ),
                            validator: (val) => val.isEmpty
                                ? 'Password Must Be 8 Chars Long'
                                : null,
                            onChanged: (val) {
                              setState(() => _email = val);
                            },
                          ), */
                            Divider(
                              color: Appdetails.appGreenColor,
                              height: 10,
                            ),
                            GradButton(
                              backgroundColor: Appdetails.appGreenColor,
                              height: 50,
                              width: width / 2,
                              onPressed: () async {
                                dynamic result =
                                    await setProfileDetails(context);
                                if (result == true) {
                                  showSuccessAlert(context);
                                } else if (result == false) {
                                  showFailedNotification(context);
                                } else {
                                  DialogsHelpal.showMsgBox(
                                      "Failed",
                                      result,
                                      AlertType.error,
                                      context,
                                      Appdetails.appBlueColor);
                                }
                              },
                              child: Text(
                                'Apply Changes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showFailedNotification(BuildContext context) {
    DialogsHelpal.showMsgBox("Failed", "Please check details and try again",
        AlertType.error, context, Appdetails.appGreenColor);
  }

  void showSuccessAlert(BuildContext context) {
    DialogsHelpal.showMsgBox("Success", "Details changed successfully",
        AlertType.success, context, Appdetails.appGreenColor);
  }
}
