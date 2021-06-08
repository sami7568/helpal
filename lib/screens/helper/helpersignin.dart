import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/helpee/helpeesignup.dart';
import 'package:helpalapp/screens/helper/helperdashboard.dart';
import 'package:helpalapp/screens/helper/helperotpscreen.dart';
import 'package:helpalapp/screens/helper/helpersignup.dart';
import 'package:helpalapp/screens/helper/helpersignupdetails.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/screens/others/welcome.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HelperSignin extends StatefulWidget {
  @override
  _HelperSigninState createState() => _HelperSigninState();
}

class _HelperSigninState extends State<HelperSignin> {
  bool showBackButton = true;

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  BuildContext mycontext;

  //Phone controller
  TextEditingController phone = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _title() {
    return Text(
      'Sign in as Helper',
      textAlign: TextAlign.left,
      style: TextStyle(
          fontFamily: "Montserrat", color: Colors.grey[300], fontSize: 30),
    );
  }

  Widget _signupLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HelperSignup()));
      },
      child: Center(
        child: Text(
          "Register New Account",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  Future signIn() async {
    if (_formKey.currentState.validate()) {}
  }

  Widget _logo(double headerHeight) {
    //getting font size
    final logoHeight = headerHeight / 100 * 25;
    return Image.asset(
      "assets/images/mainlogo.png",
      height: logoHeight,
    );
  }

  Widget _backBtn() {
    return Container(
      color: Colors.transparent,
      child: BackButton(
        color: Colors.white,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => WelcomeScreen(),
              transitionDuration: Duration(seconds: 0),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    mycontext = context;
    //heights
    final size = MediaQuery.of(context).size;
    double headerHeight = size.height / 100 * 50;
    double fieldAreaHeight = size.height / 100 * 50;

    Color ovrly = Color.fromARGB(100, 0, 0, 0);

    return WillPopScope(
      onWillPop: () => Appdetails.loadScreen(context, WelcomeScreen()),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: _backBtn(),
        ),
        body: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(ovrly, BlendMode.darken),
                image: Image.asset("assets/images/helpersigninbg.png").image,
                fit: BoxFit.cover),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 50, bottom: 30),
                  height: headerHeight,
                  width: size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _logo(headerHeight),
                      SizedBox(height: 10),
                      Text(
                        "Helpal",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          color: Colors.grey[300],
                          fontSize: 42,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: fieldAreaHeight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _title(),
                        SizedBox(height: 10),
                        //Phone Field
                        Row(
                          children: [
                            Container(
                              width: size.width / 100 * 70,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 1, color: Colors.white))),
                              child: TextFormField(
                                controller: phone,
                                keyboardType: TextInputType.phone,
                                validator: (val) => val.length < 10
                                    ? "Please Provide a Valid Phone Number"
                                    : null,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    fontStyle: FontStyle.normal,
                                    fontSize: 20,
                                    color: Colors.white70,
                                  ),
                                  hintText: "Mobile Number",
                                  prefixIcon: Padding(
                                    child: IconTheme(
                                      data: IconThemeData(color: Colors.white),
                                      child: Container(
                                        width: 50,
                                        height: 25,
                                        child: Row(
                                          children: [
                                            ImageIcon(
                                              Image.asset(
                                                      "assets/images/logo.png")
                                                  .image,
                                              size: 37,
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              width: 1,
                                              color: Colors.white,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.only(
                                        left: 10, right: 10, bottom: 6),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 70,
                              width: 50,
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                color: Colors.transparent,
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    print("Validated");
                                    verifyPhone(context);
                                  }
                                },
                                icon: Icon(
                                  Icons.arrow_forward,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        //_signupLabel(),
                        SizedBox(height: 20),
                      ],
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

  void verifyPhone(BuildContext context) {
    _auth.loginUserWithPhone(
        phone.text, context, phoneAutoVerifiedCallback, showotpscreenCallback);
  }

  String formatedPhone() {
    //Creating a formated phone variable
    String fp = phone.text.replaceAll(" ", "").trim();
    //checking if phone number contains zero at first
    if (fp.startsWith('0')) fp = fp.replaceFirst('0', '');
    //adding +92 at as country code
    fp = "+92" + fp;
    return fp;
  }

  void phoneAutoVerifiedCallback() async {
    DialogsHelpal.showLoadingDialog(mycontext, false);
    //after auth checking if account exist in database
    dynamic isExist =
        await AuthService().ifDetailsExists('helpers', formatedPhone());
    //if exist
    if (isExist == true) {
      dynamic isSignedup =
          await AuthService().ifHelperSignedup(formatedPhone());
      if (isSignedup == true) {
        await AuthService().saveDefaultLocalKeys(formatedPhone(), 'helpers');
        await AuthService().saveLocalString(Appdetails.signinKey, "true");
        await AuthService().saveLocalString(
            Appdetails.accountTypeKey, Appdetails.accountTypeValue_helper);
        Navigator.pop(mycontext);
        //Pushing otp screen to display for entering the code manually
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HelperDash(),
          ),
        );
      } else {
        final myField = await AuthService()
            .getDocuementField("helpers", formatedPhone(), 'field');
        OurServices _field = OurServices.Plumbers;
        if (myField == null) {
          Navigator.pop(mycontext);
          //Pushing otp screen to display for entering the code manually
          Navigator.push(
            mycontext,
            MaterialPageRoute(
              builder: (context) => HelperSignup(),
            ),
          );
        } else {
          if (myField == "tailor" || myField == "drycleaner") {
            _field = OurServices.Drycleaners;
          } else if (myField == "deliveryservice") {
            _field = OurServices.DeliveryService;
          } else if (myField == "helpalbike") {
            _field = OurServices.HelpalBike;
          }

          Navigator.pop(mycontext);
          //Pushing otp screen to display for entering the code manually
          Navigator.push(
            mycontext,
            MaterialPageRoute(
              builder: (context) => HelperSignupDetails(
                  myField: _field, myPhone: formatedPhone()),
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
          builder: (context) => HelpeeSignup(),
        ),
      );
    } else {
      DialogsHelpal.showMsgBoxCallback(
        "Error",
        isExist + "\nPlease Contect Providers",
        AlertType.error,
        context,
        onErrorCallback,
      );
    }
  }

  void onErrorCallback() {}
  void showotpscreenCallback(String phonenumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelperOtpScreen(
          phonNumber: formatedPhone(),
        ),
      ),
    );
  }
}
