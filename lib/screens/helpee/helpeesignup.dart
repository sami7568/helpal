import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:helpalapp/screens/helpee/helpeedashboard.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/screens/others/welcome.dart';
import 'package:helpalapp/widgets/custextfield.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HelpeeSignup extends StatefulWidget {
  final String phoneNumber;

  const HelpeeSignup({Key key, this.phoneNumber}) : super(key: key);

  @override
  _HelpeeSignupState createState() => _HelpeeSignupState();
}

class _HelpeeSignupState extends State<HelpeeSignup>
    with SingleTickerProviderStateMixin {
  //variables regarding details of helpee and services
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String error = '';
  String _email = '';
  String _phone = '';
  String _fullname = '';

  AssetImage defaultAvatar = AssetImage('assets/images/avatar.png');
  File _image;
  final picker = ImagePicker();

  //this is linked to sign in page
  //if user already have an account he/she can login
  Widget _signupLabel(double height) {
    //getting font size
    final titleFontSize = height / 100 * 2.5;

    return InkWell(
      onTap: () {
        //provice link for helpee signin page
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
        //DBUpdater().initDatabase();
      },
      child: Center(
        child: Text(
          "Already have an account",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue, fontSize: titleFontSize),
        ),
      ),
    );
  }

  Widget _backBtn() {
    return Container(
      color: Colors.transparent,
      child: BackButton(
        color: Colors.white,
      ),
    );
  }

  Widget _avatar(double height) {
    return Container(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          width: 35,
          height: 35,
          //padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Appdetails.appBlueColor,
              borderRadius: BorderRadius.circular(100)),
          child: Center(
            child: IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () => Appdetails.getImage(_scaffoldKey, getImage),
            ),
          ),
        ),
      ),
      height: height / 100 * 10,
      width: height / 100 * 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        image: DecorationImage(
          image: _image == null ? defaultAvatar : FileImage(File(_image.path)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void dpUploaded() {
    print('DP Uploaded CallBack');
  }

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(
        source: imageSource,
        preferredCameraDevice: CameraDevice.front,
        maxHeight: 350,
        maxWidth: 350,
        imageQuality: 80);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('Image File :' + pickedFile.path);
        //cropImage();
      } else {
        print('No image selected.');
      }
    });
  }

  Future signUp(BuildContext context) async {
    String errorReason = "Please check details and try again!";

    //if form is valid proceed to check further
    if (_formKey.currentState.validate()) {
      //Showing waiting dialog
      DialogsHelpal.showLoadingDialog(context, false);
      //Creating Map Details
      //Getting new id
      String myid = FirebaseAuth.instance.currentUser.uid;
      if (myid == null) {
        DialogsHelpal.showMsgBox(
            "Error", myid, AlertType.error, context, Appdetails.appBlueColor);
        return;
      }
      //Uploading display picture
      String fileName = "";
      if (_image != null) {
        fileName = StorageHandler.pathToFilename(_image.path);
        await StorageHandler.upload(
            _image.path, dpUploaded, UploadTypes.DisplayPicture);
        print("dp upload await complete");
      }
      setState(() {
        if (widget.phoneNumber.length > 5) _phone = widget.phoneNumber;
      });
      //Making map of user's details
      Map<String, dynamic> _details = {
        'address': '',
        'dpfilename': fileName,
        'email': _email,
        'name': _fullname,
        'phone': _phone,
        'balance': '0.00',
        'myid': myid,
      };
      //getting result for firestore user creation
      dynamic result =
          await _auth.createRecord('helpees', widget.phoneNumber, _details);

      //if the result is negitive
      if (result != true) {
        errorReason = result;
        //if getting an error from firestore
        Navigator.pop(context);
        DialogsHelpal.showMsgBox("Error", errorReason, AlertType.error, context,
            Appdetails.appBlueColor);
      }
      //if firestore user created
      else {
        await _auth.saveDefaultLocalKeys(widget.phoneNumber, 'helpees');
        //closing waiting dialog
        Navigator.pop(context);
        //showing success dialog
        DialogsHelpal.showMsgBoxCallback(
            "Successfull",
            "Details added successfully",
            AlertType.success,
            context,
            callBackSuccess);
      }
    }
  }

  void callBackSuccess() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HelpeeDashboard()));
  }

  @override
  Widget build(BuildContext context) {
    //Getting screen height
    final height = MediaQuery.of(context).size.height;
    //Getting screen height
    //final width = MediaQuery.of(context).size.width;
    //getting size of top logo
    final sizeofLogo = height / 100 * 22;
    //getting logo
    //getting contents height
    final contentsHeight = height / 100 * 63;
    //
    //final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      //resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: _backBtn(),
      ),
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            //Stack for top logo
            //_topLogo(sizeofLogo, height),
            Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: sizeofLogo - (sizeofLogo / 100 * 20),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      height: contentsHeight,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            _avatar(height),
                            CusTextField(
                              initialValueString: Appdetails.currentUser != null
                                  ? Appdetails.currentUser.displayName
                                  : "",
                              screenHeight: height,
                              keyboardType: TextInputType.name,
                              hint: 'Full Name',
                              icon: Icon(Icons.person),
                              obsecure: false,
                              validator: (val) =>
                                  val.isEmpty ? 'Enter Name!' : null,
                              onChanged: (val) {
                                setState(() => _fullname = val);
                              },
                            ),
                            CusTextField(
                              initialValueString: Appdetails.currentUser != null
                                  ? Appdetails.currentUser.email
                                  : "",
                              screenHeight: height,
                              keyboardType: TextInputType.emailAddress,
                              hint: 'Email (Optional)',
                              icon: Icon(Icons.email),
                              obsecure: false,
                              onChanged: (val) {
                                setState(() => _email = val);
                              },
                            ),
                            CusTextField(
                              initialValueString: widget.phoneNumber,
                              enabled:
                                  widget.phoneNumber.length > 5 ? false : true,
                              screenHeight: height,
                              keyboardType: TextInputType.phone,
                              hint: 'Phone',
                              icon: Icon(Icons.phone_android),
                              obsecure: false,
                              validator: (val) =>
                                  val.isEmpty ? 'Enter Phone!' : null,
                              onChanged: (val) {
                                setState(() => _phone = val);
                              },
                            ),
                            /* CusTextField(
                              screenHeight: height,
                              hint: 'Password',
                              icon: Icon(Icons.lock),
                              obsecure: true,
                              validator: (val) => val.length < 6
                                  ? 'Password Must Be 6+ Chars Long!'
                                  : null,
                              onChanged: (val) {
                                setState(() => _password = val);
                              },
                            ), */
                            IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () {
                                signUp(context);
                              },
                            ),
                            _signupLabel(height),
                          ],
                        ),
                      ),
                    ),
                    //MyFooter(screenHeight: height),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
