import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:helpalapp/screens/helpee/helpeephonsignin.dart';
import 'package:helpalapp/screens/helper/helperotpscreen.dart';
import 'package:helpalapp/screens/helper/helpersignin.dart';
import 'package:helpalapp/screens/helper/helpersignupdetails.dart';
import 'package:helpalapp/screens/helper/pushNotificationService.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/screens/others/welcome.dart';
import 'package:helpalapp/widgets/ShadowText.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperSignup extends StatefulWidget {
  @override
  _HelperSignupState createState() => _HelperSignupState();
}

class _HelperSignupState extends State<HelperSignup> {
  //Database service
  final AuthService _auth = AuthService();
  //current form key to control basic fields
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _field = 'Select Your Field';
  //this color will be used for validation
  //other fields
  String _fullname = '';
  String _cnic = '';
  String _email = '';
  File _image;
  final picker = ImagePicker();
  bool phoneVerified = false;

  //Text Controller
  TextEditingController fullnameConroller = TextEditingController();
  MaskedTextController cnicConroller = MaskedTextController(mask: '00000-0000000-0');
  //TextEditingController cnicConroller = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  BuildContext myContext;
  //Avatar
  AssetImage defaultAvatar = AssetImage('assets/images/avatar.png');

  Widget _avatar(double height) {
    return Container(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Appdetails.appGreenColor,
              borderRadius: BorderRadius.circular(100)),
          child: InkWell(
            child: Icon(
              Icons.add,
              size: 18,
              color: Colors.white,
            ),
            onTap: () => Appdetails.getImage(_scaffoldKey, getImage),
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

  Widget _title() {
    return Center(
      child: Container(
        child: ShadowText(
          text: 'HELPER REGISTRATION',
          fontColor: Colors.white,
          fontSize: 25,
          shadowColor: Colors.black.withAlpha(100),
          shadowBlur: 5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _signinLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HelperSignin()));
      },
      child: Center(
        child: Text(
          "Already have an account",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue, fontSize: 22),
        ),
      ),
    );
  }

  void dpUploaded() {
    print('DP Uploaded CallBack');
  }

   void verifyPhone() async {
    if (_field.startsWith("Select")) {
      print("VerifyPHone :: select");
      DialogsHelpal.showMsgBox("Error", "Please select your field",
          AlertType.error, myContext, Appdetails.appGreenColor);
      return;
    }
    if (_image == null) {
      DialogsHelpal.showMsgBox("Error", "Please add your picture",
          AlertType.error, myContext, Appdetails.appGreenColor);

      return;
    }
    print("Verifying:$formatedPhone()");
    print("going to verify");

    _auth.loginUserWithPhone(formatedPhone(), myContext,
        phoneAutoVerifiedCallback, showotpscreenCallback);
  }

  Future<void> phoneAutoVerifiedCallback(String phone) async {
    //Showing waiting dialog
    DialogsHelpal.showLoadingDialog(myContext, false);
    dynamic exist = await AuthService().ifDetailsExists("helpers", phone);
    print("USER STATUS" + exist.toString());
    Navigator.pop(myContext);
    if (exist == true) {
      DialogsHelpal.showMsgBox(
          "",
          "The phone you entered is already registered\n\nPlease Login",
          AlertType.error,
          myContext,
          Appdetails.appGreenColor);

      return;
    }
    signup();
  }

  void showotpscreenCallback(String phonenumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelperOtpScreen(
          phonNumber: formatedPhone(),
          callBack: callbackFromOtpScreen,
        ),
      ),
    );
  }

  void callbackFromOtpScreen() {
    Future.delayed(Duration(milliseconds: 500), () {
      proceedSignup();
    });
  }

  Future<void> proceedSignup() async {
    //Showing waiting dialog
    DialogsHelpal.showLoadingDialog(myContext, false);
    dynamic exist =
        await AuthService().ifDetailsExists("helpers", formatedPhone());
    print("USER STATUS" + exist.toString());
    Navigator.pop(myContext);
    if (exist == true) {
      DialogsHelpal.showMsgBox(
          "",
          "The phone you entered is already registered\n\nPlease Login",
          AlertType.error,
          myContext,
          Appdetails.appGreenColor);

      return;
    }
    signup();
  }

  String formatedPhone() {
    //Creating a formated phone variable
    String fp = phoneController.text.trim();
    //checking if phone number contains zero at first
    if (fp.startsWith('0')) fp = phoneController.text.replaceFirst('0', '');
    //adding +92 at as country code
    fp = "+92" + fp;
    return fp;
  }
  String token;
  @override
  void initState() {
   getToken();
    super.initState();
  }
  Future getToken()async{
//    token=HelpalStreams.prefs.getString(Appdetails.fcmtoken);
    setState(() async{
       await FirebaseMessaging.instance.getToken(vapidKey: fcmtoken).then((value) =>
         token = value,
      );
    });

    print("Your FCM token is : $token");
  }

  Future signup() async {

    //Showing waiting dialog
    DialogsHelpal.showLoadingDialog(myContext, false);
    //Creating Map Details
    String myid = FirebaseAuth.instance.currentUser.uid;
    if (myid == null) {
      //if getting an error from firestore
      Navigator.pop(context);
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

    //Making map of user's details
    Map<String, dynamic> _details = {
      'field': _field.replaceAll(" ", "").toLowerCase(),
      'dpfilename': fileName,
      'email': emailController.text,
      'name': fullnameConroller.text,
      'phone': formatedPhone(),
      'cnicnum': cnicConroller.text.trim(),
      'balance': '0.00',
      'status': 'offline',
      'myid': myid,
      "approved": "false",
      "token":token
    };
    //getting result for firestore user creation
    dynamic result =
        await _auth.createRecord('helpers', formatedPhone(), _details);

    //if the result is negitive
    if (result != true) {
      //if getting an error from firestore
      Navigator.pop(context);
      DialogsHelpal.showMsgBox(
          "Error", result, AlertType.error, context, Appdetails.appGreenColor);
    }
    //if firestore user created
    else {
      await _auth.saveDefaultLocalKeys(formatedPhone(), 'helpers');
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

  void callBackSuccess() {
    OurServices myField = OurServices.Plumbers;

    switch (_field) {
      case 'Electrician':
        myField = OurServices.Electricians;
        break;
      case 'Delivery Service':
        myField = OurServices.DeliveryService;
        break;
      case 'Helpal Bike':
        myField = OurServices.HelpalBike;
        break;
      case 'Helpal Cab':
        myField = OurServices.HelpalCab;
        break;
      case 'Tailor':
        myField = OurServices.Tailors;
        break;
      case 'Drycleaner':
        myField = OurServices.Drycleaners;
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelperSignupDetails(
          myField: myField,
          myPhone: formatedPhone(),
        ),
      ),
    );
  }

  //Settings
  BoxDecoration btnDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(5),
      boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
    );
  }

  //Styling phone field
  getInputField(
      TextEditingController textController,
      IconData icon,
      bool isPhone,
      hintText,
      TextInputType keyboardType,
      Function onChanged(String value)) {
    TextStyle titleStyle = new TextStyle(fontSize: 20, color: Colors.grey[600]);
    //button structer
    return Container(
      height: 50,
      decoration: btnDecoration(),
      child: ListTile(
        title: Transform.translate(
          offset: Offset(-15, -2.5),
          child: TextField(
            onChanged: onChanged,
            style: titleStyle,
            controller: textController,
            keyboardType: keyboardType,
            inputFormatters: isPhone
                ? [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly
                  ]
                : [],
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
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
            child: isPhone
                ? Text(
                    "+92",
                    style: titleStyle,
                  )
                : Icon(
                    icon,
                    color: Colors.grey,
                  ),
          ),
        ),
      ),
    );
  }

  getCnicInputField(
      TextEditingController textController,
      IconData icon,
      bool isCnic,
      autofocus,
      hintText,
      TextInputType keyboardType,
      Function onChanged(String value)) {
    TextStyle titleStyle = new TextStyle(fontSize: 20, color: Colors.grey[600]);
    //button structer
    return Container(
      height: 50,
      decoration: btnDecoration(),
      child: ListTile(
        title: Transform.translate(
          offset: Offset(-15, -2.5),
          child: TextField(
            onChanged: onChanged,
            style: titleStyle,
            controller: textController,
            keyboardType: keyboardType,

            inputFormatters: isCnic
            ? [
            LengthLimitingTextInputFormatter(15),
            FilteringTextInputFormatter.digitsOnly
            ]
            : [],
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
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
            child: Icon(
              icon,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  getNameInputField(
      TextEditingController textController,
      IconData icon,
      bool isPhone,
      hintText,
      TextInputType keyboardType,
      Function onChanged(String value)) {
    TextStyle titleStyle = new TextStyle(fontSize: 20, color: Colors.grey[600]);
    //button structer
    return Container(
      height: 50,
      decoration: btnDecoration(),
      child: ListTile(
        title: Transform.translate(
          offset: Offset(-15, -2.5),
          child: TextField(
            onChanged: onChanged,
            style: titleStyle,
            textCapitalization: TextCapitalization.sentences,
            controller: textController,
            keyboardType: keyboardType,
            inputFormatters: isPhone
            ? [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.digitsOnly
            ]
            : [],
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
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
            child: isPhone
                ? Text(
              "+92",
              style: titleStyle,
            )
                : Icon(
              icon,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    //Screen size
    Size size = MediaQuery.of(context).size;
    double headerHeight = size.height / 100 * 12;
    double fieldsAreaHeight = size.height / 100 * 65;
    double footerHeight = size.height / 100 * 7;
    double topFooterHeight = size.height / 100 * 16;

    Color ovrly = Color.fromARGB(100, 0, 0, 0);
    myContext = context;
    return WillPopScope(
       // onWillPop: () => Appdetails.loadScreen(context, WelcomeScreen()),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(ovrly, BlendMode.darken),
                image: Image.asset("assets/images/helpersigninbg.png").image,
                fit: BoxFit.cover),
          ),
          child: Scaffold(
            key: _scaffoldKey,
            //Appbar area
            appBar: PreferredSize(
              child: Container(
                padding: EdgeInsets.only(top: 20),
                width: size.width,
                height: headerHeight,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: Image.asset("assets/images/greenbg.png").image,
                      fit: BoxFit.cover),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      child: BackButton(
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: _title(),
                      ),
                    ),
                    Container(
                      width: 60,
                    ),
                  ],
                ),
              ),
              preferredSize: Size(size.width, headerHeight),
            ),
            extendBodyBehindAppBar: false,
            extendBody: true,
            backgroundColor: Colors.transparent,
            //Body Area
            body: Container(
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //Fields Container
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      height: fieldsAreaHeight,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: DropdownButton<String>(
                                      value: _field,
                                      icon: Icon(Icons.keyboard_arrow_down_outlined),
                                      iconSize: 16,
                                      elevation: 5,
                                      isExpanded: true,
                                      underline: Container(
                                        height: 2,
                                        color: Colors.black87,
                                      ),
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 18),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          _field = newValue;
                                        });
                                      },
                                      hint: Text("Select Your Feild"),
                                      items: <String>[
                                        'Plumber',
                                        'Electrician',
                                        'Delivery Service',
                                        'Helpal Bike',
                                        'Helpal Cab',
                                        'Tailor',
                                        'Drycleaner'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                _avatar(size.height),
                              ],
                            ),
                            getNameInputField(
                                fullnameConroller,
                                Icons.person,
                                false,
                                "Full Name",
                                TextInputType.name, (value) {
                              _fullname = value;
                              setState(() {});
                              //change full name
                              print(value);
                              return;
                            }),
                            getCnicInputField(cnicConroller, Icons.credit_card,
                                true,true, "CNIC", TextInputType.number, (value) {
                              //change full name
                              print(value);
                              _cnic = value;
                              setState(() {});
                              return;
                            }),
                            getInputField(
                                emailController,
                                Icons.email,
                                false,
                                "Email(Optional)",
                                TextInputType.emailAddress, (value) {
                              //change full name
                              _email = value;
                              setState(() {});
                              print(value);
                              return;
                            }),
                            getInputField(phoneController, Icons.person, true,
                                "Mobile Number", TextInputType.phone, (value) {
                              //change full name
                              print(value);
                              setState(() {

                              });
                              return;
                            }),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: topFooterHeight,
                      width: size.width,
                      child: Center(
                        child: GradButton(
                          height: 35,
                          child: ShadowText(
                            text: "Continue",
                            fontSize: 20,
                            fontColor: Colors.white,
                            shadowColor: Colors.black54,
                            shadowBlur: 5,
                          ),
                          width: size.width / 2,
                          onPressed: () {
                            verifyPhone();
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: footerHeight,
                      width: size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image:
                                Image.asset("assets/images/greenbg.png").image,
                            fit: BoxFit.cover),
                      ),
                      child: Center(
                        child: Text("Helpal © 2021 All Rights Reserved"),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
