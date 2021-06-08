import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:helpalapp/AuthenticationProvider.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/others/splashscreen.dart';
import 'package:helpalapp/screens/others/welcome.dart';
import 'package:helpalapp/screens/others/wrapper.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

var showSplash = false;
String fcmServerKey =
    "BALS2VG7sUfzH6tIDZEPNoLWHF2l8JLlAaXBbhOIRHjantDAvzeDEwp-SGaXiuQ2UYNrSIcln8qaB338iSMBA5w";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //SharedPreferences.setMockInitialValues({});
  //Must init before app starts this will get data locally and fast
  bool sp = await HelpalStreams.initSharedPrefs();
  if (!sp) print("SharePrefs Not Inited");
  showSplash = true;
  //Start the app
  runApp(MyApp());
  Appdetails.setServicesIcons();
  bool result = await AuthService().requestIosPermissionFCM();
  if (result) {
    FirebaseMessaging.instance.getToken(vapidKey: fcmServerKey).then((value) {
      HelpalStreams.prefs.setString("fcmtoken", value);
    });
  }
  if (sp) {
    //Getting is this app running first time.?
    String isFirstTime = HelpalStreams.prefs.getString(Appdetails.firstTimeKey);

    //if this app runing first time this will return error
    //we will change error result to true
    if (isFirstTime == null || isFirstTime == "")
      await HelpalStreams.prefs.setString(Appdetails.firstTimeKey, "true");
    //setting static variable for first time running to control onboarding screens
    Appdetails.isFirstTime =
        HelpalStreams.prefs.getString(Appdetails.firstTimeKey);
    //getting output in editor console
    print("Running App First Time = " + isFirstTime);
  }
}

class MyApp extends StatefulWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static Future<void> showNotification() async {
    //print()
    await _MyAppState().showNotification();
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterLocalNotificationsPlugin fltrNotification;

  @override
  void initState() {
    super.initState();
    setupTimeZones();
  }

  void setupTimeZones() async {
    await _configureLocalTimeZone();
    var androidInitilize =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSinitilize = new IOSInitializationSettings();
    var initilizationsSettings = new InitializationSettings(
        android: androidInitilize, iOS: iOSinitilize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    dynamic initResult = fltrNotification.initialize(initilizationsSettings,
        onSelectNotification: notificationSelected);
    if (initResult == true)
      print("init success");
    else
      print("Failed to initilize notification service");
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("Asia/Karachi"));
    print("Time Zone is Ok");
  }

  Future notificationSelected(String payload) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Notification : $payload"),
      ),
    );
  }

  showNotification() async {
    print("Notification Call Received");
    var androidDetails = new AndroidNotificationDetails(
        "Channel ID", "Desi programmer", "This is my channel",
        importance: Importance.max);
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iSODetails);

    /* await fltrNotification.show(
        0, "Task", "You created a Task", 
        generalNotificationDetails, payload: "Task"); */

    //var scheduledTime = TZDateTime.now().add(Duration(seconds: 10));
    var scheduledTime =
        new tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
    fltrNotification.zonedSchedule(
        0, 'Time Up', ' body', scheduledTime, generalNotificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);

    Navigator.pop(MyApp.navigatorKey.currentContext);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MultiProvider(
        providers: [
          Provider<AuthenticationProvider>(
            create: (_) => AuthenticationProvider(),
          ),
          StreamProvider(
            create: (context) =>
                context.read<AuthenticationProvider>().authState,
          ),
        ],
        child: MaterialApp(
          navigatorKey: MyApp.navigatorKey,
          debugShowCheckedModeBanner: false,
          home: Authenticate(),
          /* HelperSignupDetails(
          myPhone: "+923321535880",
          myField: OurServices.Tailors,
        ), */
          builder: (context, child) {
            return MediaQuery(
              child: child,
              data: MediaQuery.of(context).copyWith(textScaleFactor: 0.75),
            );
          },
        ),
      ),
    );
  }
}

class Authenticate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      print(firebaseUser.phoneNumber + " this is user which is not null");
      return SplashScreen();
    }
    if (showSplash) {
      return SplashScreen();
    }
    return WelcomeScreen();
  }
}
