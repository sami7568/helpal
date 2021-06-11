import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/helper/helperorders.dart';
import 'package:helpalapp/screens/helpee/helpeedashboard.dart';
import 'package:helpalapp/screens/helpee/helpeeotpscreen.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:hive/hive.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  //////////////////////////////////////////
  //Instances of firebase
  //////////////////////////////////////////
  /////Firebase and firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestoreRef = FirebaseFirestore.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<bool> requestIosPermissionFCM() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized)
      return true;
    else
      return false;
  }

  void registerEventsForFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();

    print("Handling a background message: ${message.messageId}");
  }

  //////////////////////////////////////////
  //Variables region
  //////////////////////////////////////////
  //obtain shared preferences
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //this is last logeding account type helpee or helper
  AccountTypes currentAccount = AccountTypes.HelpeeAccount;

  //////////////////////////////////////////
  //Getting account type from other scripts
  //////////////////////////////////////////
  Future<AccountTypes> getAccountType() async {
    if (await getLocalString(Appdetails.accountTypeKey) ==
        Appdetails.accountTypeValue_helpee) {
      return AccountTypes.HelpeeAccount;
    } else {
      return AccountTypes.HelperAccount;
    }
  }

  /////////////////////////////////////////////
  //Setting account type while login or signup
  /////////////////////////////////////////////
  setAccountType(AccountTypes typeofaccount) async {
    if (typeofaccount == AccountTypes.HelpeeAccount) {
      await saveLocalString(
          Appdetails.accountTypeKey, Appdetails.accountTypeValue_helpee);
    } else {
      await saveLocalString(
          Appdetails.accountTypeKey, Appdetails.accountTypeValue_helper);
    }
  }

  //////////////////////////////////////////
  //Verification code entering manual
  //////////////////////////////////////////
  Future<dynamic> verifyCode(String userInputCode, BuildContext context) async {
    print("You input code $userInputCode");

    print("You Verification id is " + Appdetails.lastVerifyID);
    //Showing loading bar while verfying code in background
    DialogsHelpal.showLoadingDialog(context, false);
    try {
      //getting credentiols
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: Appdetails.lastVerifyID,
          smsCode: userInputCode.trim());
      //Getting user result from credentionals
      UserCredential result = await _auth.signInWithCredential(credential);
      //closing loading bar
      Navigator.pop(context);
      //getting user from result
      User user = result.user;
      print("user $user");
      //checking if user is not null
      if (user != null) {
        //saving user in static variable
        Appdetails.currentUser = user;

        //Returning true verification is sussessful
        return true;
      } else {
        //Verification failed
        //resporting error to user
        Appdetails.currentUser = null;
        return "error";
      }
    } catch (e) {
      //closing loading bar
      Navigator.pop(context);
      Appdetails.currentUser = null;
      print("Failed");
      //Verification failed
      //resporting error to user
      return e.toString();
    }
  }

  ///////////////////////////////////////////
  ///Login user with phone authentication
  ///////////////////////////////////////////
  void loginUserWithPhone(String phone, BuildContext context,

    Function autoVerfyCallback, Function otpScreenCallback) async {
    print("Received call for $phone");
    //Creating a formated phone variable
    String formatedPhone = phone.trim().replaceAll(" ", "");
    //checking if phone number contains zero at first
    if (formatedPhone.startsWith('0'))
      formatedPhone = phone.replaceFirst('0', '');
    //adding +92 at as country code
    if (!formatedPhone.startsWith("+92")) formatedPhone = "+92" + formatedPhone;

    //showing loading indicator
    DialogsHelpal.showLoadingDialog(context, false);

    //Starting verification process
    await _auth.verifyPhoneNumber(
      //given phone number
      phoneNumber: formatedPhone,
      //timeout for auto verification or code seding
      timeout: Duration(seconds: 90),
      //if verified automatically
      verificationCompleted: (AuthCredential credential) async {
        //creating credentional variable
        UserCredential result = await _auth.signInWithCredential(credential);
        //after getting credentionals closing loading indicator
        Navigator.pop(context);
        //getting user from credentions
        User user = result.user;
        print("Authenticating USer phone number ::  $user ");
        //checking if user is not null so proceed to dashboard
        if (user != null) {
          //saving current user variable as static
          Appdetails.currentUser = user;
          //pushing dashboard to screen
          autoVerfyCallback(formatedPhone);
        } else {
          //turning user to null if verification process had any error
          Appdetails.currentUser = null;
        }
      },
      //failed verification
      verificationFailed: (FirebaseAuthException exception) {
        //closing loading indicator
        Navigator.pop(context);
        DialogsHelpal.showMsgBox(
            "Failed", exception.message, AlertType.error, context, Colors.grey);
        //sending execption back as print but it should in a box to display the problem
        print("Verification Failed\n" + exception.toString());
      },
      //this will called when code sent on users phone
      codeSent: (String verificationId, [int forceResendingToken]) {
        print("Verify ID Sent = $verificationId");
        //adding verification id to a variable so we can veryfy with this later
        Appdetails.lastVerifyID = verificationId;
        //closing loading indicator
        Navigator.pop(context);
        //Pushing otp screen to display for entering the code manually
        otpScreenCallback(formatedPhone);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        //Navigator.pop(context);
      },
    );
  }

  //////////////////////////////////////////
  //Google Signin Firebase
  //////////////////////////////////////////
  Future<dynamic> signInWithGoogle(BuildContext context) async {
    //showing loading indicator
    DialogsHelpal.showLoadingDialog(context, false);

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential uc =
          await FirebaseAuth.instance.signInWithCredential(credential);

      Appdetails.currentUser = uc.user;
      print("User Added");
      Navigator.pop(context);
      return true;
    } catch (e) {
      print("error: = " + e.toString());
      Appdetails.currentUser = null;
      Navigator.pop(context);
      DialogsHelpal.showMsgBox(
          "Error", e.toString(), AlertType.error, context, Colors.grey);
      return e.toString();
    }
  }
  //END Sign in With Google

  //////////////////////////////////////////
  //Signin User with Facebook
  //////////////////////////////////////////
   /*Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult result = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final FacebookAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(result.accessToken.token);

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }*/
  //////////////////////////////////////////
  //Signout user
  //////////////////////////////////////////
  Future signOut() async {
    final User user = _auth.currentUser;
    if (HelperOrdersUpdate.isMyStream) {
      HelperOrdersUpdate().cancelHelperStream();
      HelperOrdersUpdate().cancelOrderStream();
    }
    await HelpalStreams.prefs.clear();
    await HelpalStreams.prefs.setString(Appdetails.signinKey, 'false');
    await HelpalStreams.prefs.setString(Appdetails.firstTimeKey, 'false');
    if (user == null) {
      return 'No User Signed In';
    }
    await _auth.signOut();

    return 'Signed out';
  }

  //////////////////////////////////////////
  //Register with email and password
  //////////////////////////////////////////
  Future registerWithEP(String _email, String _password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return e.code;
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  //////////////////////////////////////////
  //Login with email and password
  //////////////////////////////////////////
  Future loginWithEP(String _email, String _password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  ///////////////////////////////////////////////////
  //getting new unique id while registering new user
  ///////////////////////////////////////////////////
  Future<String> getNewId(String phone, String accountType) async {
    try {
      Map<String, dynamic> emptyData = {"completed": "false"};
      final newrec = await createRecord(accountType, phone, emptyData);
      if (newrec == true) {
        final allsnapsHelpers = await getAllSnapshots('helpers');
        final allsnapsHelpees = await getAllSnapshots('helpees');
        final snapslength =
            allsnapsHelpers.docs.length + allsnapsHelpees.docs.length;

        return 'HLP' + snapslength.toString().padLeft(5, '0');
      } else {
        return newrec;
      }
    } catch (e) {
      return e.toString();
    }
  }

  //////////////////////////////////////////
  //Getting online helpers
  //////////////////////////////////////////
  Future getOnlineHelpers() async {
    try {
      final snapshot = await firestoreRef
          .collection('helpers')
          .where('status', isEqualTo: 'online')
          .get();
      int totalonline = snapshot.size;
      return totalonline;
    } catch (e) {
      return 0;
    }
  }

  Future changeStatusOnline() async {
    String myphone = HelpalStreams.prefs.getString(Appdetails.phoneKey);
    String myid = HelpalStreams.prefs.getString(Appdetails.myidKey);
    if (myphone == '' || myphone == null)
      return false;
    else {
      try {
        Map<String, dynamic> newsatus = {"status": "online"};
        await firestoreRef.collection("helpers").doc(myphone).update(newsatus);
        await FirebaseDatabase.instance
            .reference()
            .child("onlineworkers")
            .child(myid)
            .update(newsatus);
        return true;
      } catch (e) {
        return e.toString();
      }
    }
  }

  Future changeStatusOffline() async {
    String myphone = HelpalStreams.prefs.getString(Appdetails.phoneKey);
    if (myphone == '' || myphone == null)
      return false;
    else {
      try {
        Map<String, dynamic> newsatus = {"status": "offline"};
        await firestoreRef.collection("helpers").doc(myphone).update(newsatus);
        return true;
      } catch (e) {
        return e.toString();
      }
    }
  }

  Future changeStatusAccepted() async {
    String myphone = HelpalStreams.prefs.getString(Appdetails.phoneKey);
    String myid = HelpalStreams.prefs.getString(Appdetails.myidKey);
    if (myphone == '' || myphone == null)
      return false;
    else {
      try {
        Map<String, dynamic> newsatus = {"status": "accepted"};
        await firestoreRef.collection("helpers").doc(myphone).update(newsatus);
        await FirebaseDatabase.instance
            .reference()
            .child("onlineworkers")
            .child(myid)
            .update(newsatus);
        return true;
      } catch (e) {
        return e.toString();
      }
    }
  }

  Future changeStatusWorking() async {
    String myphone = HelpalStreams.prefs.getString(Appdetails.phoneKey);
    if (myphone == '' || myphone == null)
      return false;
    else {
      try {
        Map<String, dynamic> newsatus = {"status": "working"};
        await firestoreRef.collection("helpers").doc(myphone).update(newsatus);
        return true;
      } catch (e) {
        return e.toString();
      }
    }
  }

  //////////////////////////////////////////
  //Checking if user's details are exists
  //////////////////////////////////////////
  Future<dynamic> ifDetailsExists(String accountType, String phone) async {
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection(accountType)
          .doc(phone)
          .get();
      if (snapShot.exists)
        return true;
      else
        return false;
    } catch (e) {
      return e.toString();
    }
  }

  //////////////////////////////////////////
  //Checking if user's details are exists
  //////////////////////////////////////////
  Future<dynamic> ifHelperSignedup(String phone) async {
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection('helpers')
          .doc(phone)
          .get();
      Map<String, dynamic> data = snapShot.data();
      if (data.containsKey("completed"))
        return true;
      else
        return false;
    } catch (e) {
      return "Error:" + e.toString();
    }
  }

  //////////////////////////////////////////
  //Getting user info Map<String , dynamic>
  //////////////////////////////////////////
  Future getDocumentSnapshot(String accountType, String phone) async {
    try {
      final snapshot =
          await firestoreRef.collection(accountType).doc(phone).get();
      if (!snapshot.exists) {
        return "User Data Not Exist";
      } else {
        Map<String, dynamic> data = snapshot.data();
        return data;
      }
    } catch (e) {
      return "Error:" + e.toString();
    }
  }

  //////////////////////////////////////////
  //Gettig all users in collection
  //////////////////////////////////////////
  Future<QuerySnapshot> getAllSnapshots(String accountType) async {
    try {
      final snapshots = await firestoreRef.collection(accountType).get();
      return snapshots;
    } catch (e) {
      return null;
    }
  }

  /////////////////////////////////////////////////////
  //Getting a single field from user data type dynamic
  /////////////////////////////////////////////////////
  Future getDocuementField(
      String accountType, String phone, String _field) async {
    try {
      final snapshot =
          await firestoreRef.collection(accountType).doc(phone).get();
      if (!snapshot.exists) {
        return "User Data Not Exist";
      } else {
        Map<String, dynamic> data = snapshot.data();
        return data[_field];
      }
    } catch (e) {
      return null;
    }
  }

  //////////////////////////////////////////////
  //Getting single field with where condition
  //////////////////////////////////////////////
  Future getDocuementFieldWhere(String accountType, String whereValue,
      String whereField, String returnField) async {
    try {
      final snapshot = await firestoreRef
          .collection(accountType)
          .where(whereField, isEqualTo: whereValue)
          .get();
      if (snapshot.docs.length > 0) {
        return snapshot.docs[0].data()[returnField];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //////////////////////////////////////////
  //Updating information to firestore user
  //////////////////////////////////////////
  Future updateDocumentField(String accountType, String phone, String fieldId,
      dynamic userData) async {
    var result = '';
    await firestoreRef
        .collection(accountType)
        .doc(phone)
        .update({fieldId: userData})
        .then((value) => result = 'Success')
        .catchError((error) => result = 'Error:' + error.toString());

    return result;
  }

  //////////////////////////////////////////
  //Update user info
  //////////////////////////////////////////
  Future updateDocument(
      String accountType, String phone, Map<String, dynamic> userData) async {
    var result = '';
    await firestoreRef
        .collection(accountType)
        .doc(phone)
        .update(userData)
        .then((value) => result = 'Success')
        .catchError((error) => result = 'Error:' + error.toString());

    return result;
  }

  //////////////////////////////////////////
  //Change profile details
  //////////////////////////////////////////
  Future changeProfileDetails(
      Map<String, dynamic> userdetail, String phone) async {
    //profile changes here
    String collection = await getLocalString(Appdetails.accountTypeKey);

    if (collection == Appdetails.accountTypeValue_helpee)
      collection = 'helpees';
    else
      collection = 'helpers';

    dynamic result = await updateDocument(collection, phone, userdetail);
    return result;
  }

  //////////////////////////////////////////
  //Create new user with given data
  //////////////////////////////////////////
  Future createRecord(
      String accountType, String phone, Map<String, dynamic> userdata) async {
    try {
      await firestoreRef.collection(accountType).doc(phone).set(userdata);
      return true;
    } catch (e) {
      return e.toString();
    }
  }

  //////////////////////////////////////////
  //Getting saved addresses
  //////////////////////////////////////////
  Future getAddressesList(String phone) async {
    //print('Getting address list from db');
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection('helpees')
          .doc(phone)
          .get();
      if (!snapShot.exists) {
        print('Addresses not exist in db');
        return 'Address field not exist';
      } else {
        print('Generating list of addresses');
        List<String> addList =
            snapShot.data()['address'].toString().split('&&');
        return addList;
      }
    } catch (e) {
      print('Error getting addresses:' + e.toString());
      return 'Error:' + e.toString();
    }
  }

  //////////////////////////////////////////
  //Create new user with given data
  //////////////////////////////////////////
  Future setRating(String helperPhone, int numberOfStars) async {
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection('helpers')
          .doc(helperPhone)
          .get();
      if (!snapShot.exists) {
        print('user not exist in db');
        return false;
      } else {
        print('getting old map');
        //getting list of stars
        Map<String, dynamic> stars = {
          "s1": "0",
          "s2": "0",
          "s3": "0",
          "s4": "0",
          "s5": "0"
        };
        if (snapShot.data().containsKey("rating"))
          stars = snapShot.data()["rating"];
        //creating separate list for each rating
        double s1 = double.parse(stars["s1"]);
        double s2 = double.parse(stars["s2"]);
        double s3 = double.parse(stars["s3"]);
        double s4 = double.parse(stars["s4"]);
        double s5 = double.parse(stars["s5"]);
        //add new rating to old map and repost to users account
        switch (numberOfStars) {
          case 1:
            s1 = s1 + 1;
            break;
          case 2:
            s2 = s2 + 1;
            break;
          case 3:
            s3 = s3 + 1;
            break;
          case 4:
            s4 = s4 + 1;
            break;
          case 5:
            s5 = s5 + 1;
            break;
        }
        Map<String, dynamic> ratingsMap = {
          "s1": s1.toString(),
          "s2": s2.toString(),
          "s3": s3.toString(),
          "s4": s4.toString(),
          "s5": s5.toString()
        };
        Map<String, dynamic> rating = {"rating": ratingsMap};

        await firestoreRef
            .collection("helpers")
            .doc(helperPhone)
            .update(rating);
        return true;
      }
    } catch (e) {
      return e.toString();
    }
  }

  //////////////////////////////////////////
  //Create new user with given data
  //////////////////////////////////////////
  Future getMyRating(phone) async {
    //print('Getting address list from db');
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection('helpers')
          .doc(phone)
          .get();
      if (!snapShot.exists) {
        print('user not exist in db');
        return false;
      } else {
        print('Generating list of stars');
        //getting list of stars
        Map<String, dynamic> stars = {
          "s1": "0",
          "s2": "0",
          "s3": "0",
          "s4": "0",
          "s5": "0"
        };
        if (snapShot.data().containsKey("rating"))
          stars = snapShot.data()["rating"];
        //creating separate list for each rating
        double s5 = double.parse(stars.values.elementAt(4));
        double s4 = double.parse(stars.values.elementAt(3));
        double s3 = double.parse(stars.values.elementAt(2));
        double s2 = double.parse(stars.values.elementAt(1));
        double s1 = double.parse(stars.values.elementAt(0));
        //Getting total number of stars
        double totalStars = s5 + s4 + s3 + s2 + s1;
        //calculate rating
        double rating =
            (5 * s1 + 4 * s4 + 3 * s3 + 2 * s2 + 1 * s1) / totalStars;
        double newcr = (rating * 100).truncateToDouble() / 100;
        return newcr.toString();
      }
    } catch (e) {
      print('Error getting ratings:' + e.toString());
      return 'Error:' + e.toString();
    }
  }

  ///////////////////////////////////////////////////////////
  //Saving details locally so we can access name and etc...
  ///////////////////////////////////////////////////////////
  Future saveDefaultLocalKeys(String phone, String accountType) async {
    dynamic result = await getDocumentSnapshot(accountType, phone);
    if (result == null) {
      print('error while saving local string');
    } else if (result == "User Data Not Exist") {
      print('User phone is invalid');
    } else {
      Map<String, dynamic> finalResult = result as Map;
      //Saving key for signed in
      await saveLocalString(Appdetails.signinKey, "true");

      await saveLocalString(Appdetails.emailKey, finalResult['email']);
      await saveLocalString(Appdetails.nameKey, finalResult['name']);
      await saveLocalString(Appdetails.phoneKey, finalResult['phone']);
      await saveLocalString(Appdetails.myidKey, finalResult['myid']);
      await saveLocalString(Appdetails.photoidKey, finalResult['dpfilename']);

      if (accountType == 'helpers') {
        await saveLocalString(Appdetails.cnicKey, finalResult['cnicnum']);
        await saveLocalString(Appdetails.fieldKey, finalResult['field']);
      }

      print('Default Local Keys Saved');
    }
  }

  //////////////////////////////////////////
  //Save a local key
  //////////////////////////////////////////
  Future saveLocalString(String key, String value) async {
    HelpalStreams.prefs.setString(key, value);
    print(key + ' saved local key with value = ' + value);
  }

  //////////////////////////////////////////
  //Save a local key book
  //////////////////////////////////////////
  Future saveLocalBool(String key, bool value) async {
    final SharedPreferences prefs = await _prefs;

    // set value
    prefs.setBool(key, value);

    print(key + ' saved local key with value = $value');
  }

  void saveHive(String key, String value) {
    var box = Hive.box("myldb");
    box.put(key, value);
  }

  //////////////////////////////////////////
  //Get a local saved key
  //////////////////////////////////////////
  Future<String> getLocalString(String key) async {
    final SharedPreferences prefs = await _prefs;

    String s = prefs.getString(key) ?? 'error';
    // get value
    return s;
  }

  //////////////////////////////////////////
  //Get a local saved key
  //////////////////////////////////////////
  Future<dynamic> getLocalBool(String key) async {
    final SharedPreferences prefs = await _prefs;

    dynamic s = prefs.getBool(key) ?? 'error';
    // get value
    return s;
  }

  //////////////////////////////////////////
  //Checking if local key exist
  //////////////////////////////////////////
  Future<bool> ifLocalKeyExists(String key) async {
    final SharedPreferences prefs = await _prefs;

    bool b = prefs.containsKey(key);
    // get value
    return b;
  }

  //////////////////////////////////////////
  //Clearing app Data
  //////////////////////////////////////////
  Future<bool> clearApp() async {
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
    signOut();
    return true;
  }

  //////////////////////////////////////////
  //Share balance from wallet using phone
  //////////////////////////////////////////
  Future shareBalance(String receiverPhone, double _amount) async {
    //Transfer here
    String collection = await getLocalString(Appdetails.accountTypeKey);
    String _phonefrom = await getLocalString(Appdetails.phoneKey);

    if (collection == Appdetails.accountTypeValue_helpee)
      collection = 'helpees';
    else
      collection = 'helpers';

    try {
      final snapshot =
          await firestoreRef.collection(collection).doc(_phonefrom).get();
      final snapshot2 =
          await firestoreRef.collection(collection).doc(receiverPhone).get();
      if (!snapshot.exists || !snapshot2.exists) {
        return "There is an error,\nPlease Logout and Login Again";
      } else {
        //Sender data
        Map<String, dynamic> data = snapshot.data();
        //Receiver Data
        Map<String, dynamic> data2 = snapshot2.data();
        //Sender
        double currentBalanceFrom = double.parse(data['balance'].toString());
        //Receiver
        double currentBalanceTo = double.parse(data2['balance'].toString());
        //if the amount is larger than current balance
        if (_amount > currentBalanceFrom) {
          return 'Please enter a valid amount.';
        } else {
          double afterDeduction = currentBalanceFrom - _amount;
          await updateDocumentField(
              collection, _phonefrom, 'balance', afterDeduction.toString());

          double afterAddition = currentBalanceTo + _amount;
          await updateDocumentField(
              collection, receiverPhone, 'balance', afterAddition.toString());

          return 'Success';
        }
      }
    } catch (e) {
      return e.toString();
    }
  }

  //////////////////////////////////////////
  //Add credit to wallet
  //////////////////////////////////////////
  Future topupWallet(
      String amount, String contact, String comment, LatLng myLoc) async {
    try {
      String myId = await getLocalString(Appdetails.myidKey);
      String _date = DateTime.now().millisecondsSinceEpoch.toString();
      String _loc =
          myLoc.latitude.toString() + '-' + myLoc.longitude.toString();

      final ref = FirebaseDatabase.instance;
      Map<String, dynamic> reqData = {
        'user': myId,
        'status': 'waiting',
        'date': _date,
        'contact': contact,
        'amount': amount,
        'message': comment,
        'location': _loc,
      };
      await ref
          .reference()
          .child('topuprequests')
          .child(myId + _date)
          .update(reqData);
      return 'Success';
    } catch (e) {
      return e.toString();
    }
  }

  //////////////////////////////////////////
  //Withdraw amount from wallet
  //////////////////////////////////////////
  Future withdrawAmount(String amount, LatLng myLoc) async {
    try {
      String myId = await getLocalString(Appdetails.myidKey);
      String _date = DateTime.now().millisecondsSinceEpoch.toString();
      String _loc =
          myLoc.latitude.toString() + '-' + myLoc.longitude.toString();

      final ref = FirebaseDatabase.instance;
      Map<String, dynamic> reqData = {
        'user': myId,
        'status': 'waiting',
        'date': _date,
        'amount': amount,
        'source': '', //easypesa or cash
        'location': _loc,
      };
      await ref
          .reference()
          .child('withdrawalrequest')
          .child(myId + _date)
          .update(reqData);
      return 'Success';
    } catch (e) {
      return e.toString();
    }
  }

  //accountType = field like EasypesaAccount, Bankaccount
  Future changeAccountumber(String accountType, String accountNumber) async {
    //account number here
    String collection = await getLocalString(Appdetails.accountTypeKey);
    String phone = await getLocalString(Appdetails.phoneKey);

    if (collection == Appdetails.accountTypeValue_helpee)
      collection = 'helpees';
    else
      collection = 'helpers';

    dynamic result = await updateDocumentField(
        collection, phone, accountType, accountNumber);
    return result;
  }
}
