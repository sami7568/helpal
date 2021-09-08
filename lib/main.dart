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
    "AAAAA3HPyac:APA91bHksmRKRhKDQMlnF07cCpQhsLDIorCk603EG_nR0vEbSh-xo4EHsEfkju87U7gh2Z2eOapDwmGswI_ClnYtbPMgaDJ2_QHju-fyQZ2fXg25NXqLZctdAeWgzPCFh-xDdNlY9bfj";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging fcm = FirebaseMessaging.instance;
  /* NotificationSettings settings = await fcm.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );*/
 // print('User granted permission: ${settings.authorizationStatus}');
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
    fcm.getToken(vapidKey: fcmServerKey).then((value) {
      HelpalStreams.prefs.setString(Appdetails.fcmtoken, value);
    });
  }
  if (sp) {
    //Getting is this app running first time.?
    String isFirstTime = HelpalStreams.prefs.getString(Appdetails.firstTimeKey);
    //String fcmtoken=HelpalStreams.prefs.getString(Appdetails.fcmtoken);
    //if this app runing first time this will return error
    //we will change error result to true
    if (isFirstTime == null || isFirstTime == "")
      await HelpalStreams.prefs.setString(Appdetails.firstTimeKey, "true");
    //setting static variable for first time running to control onboarding screens
    Appdetails.isFirstTime =
        HelpalStreams.prefs.getString(Appdetails.firstTimeKey);
    //getting output in editor console
    print("Running App First Time =   $isFirstTime");

  }
}

/*
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}
*/

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

    FirebaseMessaging.instance.getInitialMessage();

    //foreground message
    FirebaseMessaging.onMessage.listen((message) {
      if(message.notification!=null){
        print(message.notification.body);
        print(message.notification.title);
      }
    });
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

     await fltrNotification.show(
        0, "Task", "You created a Task", 
        generalNotificationDetails, payload: "Task");

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
      print("$firebaseUser.phoneNumber this is user which is not null");
      return SplashScreen();
    }
    if (showSplash) {
      return SplashScreen();
    }
    return WelcomeScreen();
  }
}
