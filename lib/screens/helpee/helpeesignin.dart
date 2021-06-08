import 'package:flutter/material.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/helpee/helpeedashboard.dart';
import 'package:helpalapp/screens/helpee/helpeesignup.dart';
import 'package:helpalapp/widgets/bubbleimage.dart';
import 'package:helpalapp/widgets/custextfield.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpeeSignin extends StatefulWidget {
  @override
  _HelpeeSigninState createState() => _HelpeeSigninState();
}

class _HelpeeSigninState extends State<HelpeeSignin> {
  bool showBackButton = true;

  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  String _email = '';
  String _password = '';

  SharedPreferences sharedPreferences;

  String isSignedin = '';
  String accountStatus = '';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      sharedPreferences = sp;
      isSignedin = sharedPreferences.getString(Appdetails.signinKey);
      // will be null if never previously saved
      accountStatus = sharedPreferences.getString(Appdetails.accountStatusKey);
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _title() {
    return Text(
      'Enter Email & Password!',
      style: TextStyle(color: Appdetails.grey3, fontSize: 22),
    );
  }

  Widget _signupLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HelpeeSignup()));
      },
      child: Center(
        child: Text(
          "Register New Account!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue, fontSize: 18),
        ),
      ),
    );
  }

  Widget _topLogo(double sizeofLogo, double height) {
    //getting font size
    final titleFontSize =
        height / 100 * ((sizeofLogo / height) * (sizeofLogo / 9));
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: BubbleImage('Sign In', titleFontSize, 70, 20, sizeofLogo),
        ),
      ],
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

  Future signIn(BuildContext context) async {
    //if form i valid then proceed
    if (_formKey.currentState.validate()) {
      //show waiting dialog
      //getting response from server
      dynamic result = await _auth.loginWithEP(_email, _password);
      //if the server result if negetive
      if (result != null) {
        //dissmiss the waiting dialog
        //show the error
        setState(() {
          error = result;
        });
      }
      //if server result is positive
      else {
        //save signin key for next time auto signin
        await _auth.saveLocalString(Appdetails.signinKey, 'true');
        await _auth.saveDefaultLocalKeys(_email, 'helpees');
        //taking user to dashboard
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HelpeeDashboard(),
          ),
        );
      }
    }
  }

  //Positioned(top: 100, left: 10, child: _backButton()),
  @override
  Widget build(BuildContext context) {
    //Getting screen height
    final height = MediaQuery.of(context).size.height;
    //Getting screen height
    //final width = MediaQuery.of(context).size.width;
    //getting size of top logo
    final sizeofLogo = height / 100 * 25;
    //getting contents height
    final contentsHeight = height / 100 * 60;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: _backBtn(),
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            _topLogo(sizeofLogo, height),
            Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: sizeofLogo,
                    ),
                    Container(
                      height: contentsHeight,
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _title(),
                            CusTextField(
                              screenHeight: height,
                              controller: emailController,
                              hint: 'Email',
                              icon: Icon(Icons.email),
                              obsecure: false,
                              validator: (val) =>
                                  val.isEmpty ? 'Enter Email!' : null,
                              onChanged: (val) {
                                setState(() => _email = val);
                              },
                            ),
                            CusTextField(
                              screenHeight: height,
                              controller: passController,
                              hint: 'Password',
                              icon: Icon(Icons.lock),
                              obsecure: true,
                              validator: (val) =>
                                  val.length < 6 ? 'Wrong Password!' : null,
                              onChanged: (val) {
                                setState(() => _password = val);
                              },
                            ),
                            GradButton(
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => signIn(context),
                            ),
                            _signupLabel(),
                            Text(
                              error,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 14.0),
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
}
