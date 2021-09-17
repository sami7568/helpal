import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

enum AccountTypes { HelpeeAccount, HelperAccount }
enum UploadTypes {
  DisplayPicture,
  VoiceNote,
  Covers,
  Cnic,
  VehicleReg,
  License,
  ServicesImgs
}
enum OurServices {
  Plumbers,
  Electricians,
  DeliveryService,
  HelpalBike,
  HelpalCab,
  Tailors,
  Drycleaners
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach =>
      this.split(" ").map((str) => str.capitalize()).join(" ");
}

class Appdetails {
  static String fcmtoken="";
  static String lastAddress = '';
  static String lastLatlng = '';
  static String lastMessageHistory = '';
  static int lastOrderStamp = 0;
  static String lastSelectedService = "";
  static Uint8List lastImgArray;
  static Image myDp;
  static bool completingOrder = false;
  //static String myPhone = 'Loading...';
  //static bool listeningToLivePos = false;
  //static Map<String, dynamic> servicesList = Map();
  //user info
  static String lastVerifyID;
  //saving current user as static
  static User currentUser;
  //if first time run
  static String isFirstTime = "false";

  //login details keys For Helper
  static const String firstTimeKey = 'asfaefgrgr24f';
  static const String myidKey = 'hlp3r34gke';
  static const String emailKey = 'kn5t0l2d';
  static const String passKey = 'p2lkg98yf';
  static const String nameKey = 'nm09ngplo';
  static const String phoneKey = 'phlk098la';
  static const String fieldKey = 'flo01m43g';
  static const String cnicKey = 'cnko78jk24l';
  static const String shopNameKey = 'snp9o3lk1a';
  static const String addressKey = 'aap90kpw8';
  static const String bikeKey = 'saw2escw2';
  static const String photoidKey = 'f8ashd2398ai';
  static const String cnicphotoidKey = 'ccd55xvd45d5v';

  static const String signinKey = 'mok8l95fy7';
  static const String accountStatusKey = 'kas80sf7as';
  static const String accountTypeKey = 'accounttype';
  static const String mapsApiKey = 'AIzaSyACbX67n0n6dQJh0ptBfFNEJi5fAfErkM8';
  //Values
  static const String accountTypeValue_helper = 'helpers';
  static const String accountTypeValue_helpee = 'helpees';

  static const String accountStatusValue_NoSignup = 'nosignup';
  static const String accountStatusValue_DetailsPending = 'detailspending';
  static const String accountStatusValue_DetailsAdded = 'detailsadded';

  //Buttons Properties
  static const Color appGreenColor = Color.fromARGB(255, 137, 240, 149);
  //static const Color appGreenColor = Color.fromARGB(255, 152, 206, 145);
  static const Color appGreenColorWithAlpha = Color.fromARGB(40, 137, 240, 149);
  static const Color appBlueColor = Color.fromARGB(255, 123, 186, 239);
  static const Color appBlueColorWithAlpha = Color.fromARGB(40, 123, 186, 239);
  static const Color appGreyColor = Color.fromARGB(255, 255, 255, 255);

  static Color grey1 = Colors.grey[50];
  static Color grey2 = Colors.grey[200];
  static Color grey3 = Colors.grey[300];
  static Color grey4 = Colors.grey[400];
  static Color grey5 = Colors.grey;
  static Color grey6 = Colors.grey[600];
  static Color grey8 = Colors.grey[800];
  //Services icons
  //icons of services showing on map
  static BitmapDescriptor plumberIcon;
  static BitmapDescriptor electricianIcon;
  static BitmapDescriptor deliveryBikeIcon;
  static BitmapDescriptor deliveryPickupIcon;
  static BitmapDescriptor riderIcon;
  static BitmapDescriptor cabIcon;
  static BitmapDescriptor drycleanerIcon;
  static BitmapDescriptor tailorIcon;
  //////////////////////////////////////////////////
  ///Getting Services Icons In Special Format
  //////////////////////////////////////////////////
  static void setServicesIcons() {
    //Image configuration for icons
    ImageConfiguration config = new ImageConfiguration(size: Size(48, 48));
    //image path url
    String path = "assets/images/mapicons";
    //Getting from assets
    BitmapDescriptor.fromAssetImage(config, '$path/plumber.png')
        .then((value) => plumberIcon = value);
    BitmapDescriptor.fromAssetImage(config, '$path/electrician.png')
        .then((value) => electricianIcon = value);
    BitmapDescriptor.fromAssetImage(config, '$path/deliverybike.png')
        .then((value) => deliveryBikeIcon = value);
    BitmapDescriptor.fromAssetImage(config, '$path/deliverypickup.png')
        .then((value) => deliveryPickupIcon = value);
    BitmapDescriptor.fromAssetImage(config, '$path/rider.png')
        .then((value) => riderIcon = value);
    BitmapDescriptor.fromAssetImage(config, '$path/washerman.png')
        .then((value) => drycleanerIcon = value);
    BitmapDescriptor.fromAssetImage(config, '$path/tailor.png')
        .then((value) => tailorIcon = value);
    BitmapDescriptor.fromAssetImage(config, '$path/cab.png')
        .then((value) => cabIcon = value);
  }

  static BitmapDescriptor getCurrentMarkerIcon(String field) {
    switch (field) {
      case 'plumber':
        return plumberIcon;
        break;
      case 'electrician':
        return electricianIcon;
        break;
      case 'deliverybike':
        return deliveryBikeIcon;
        break;
      case 'deliverypickup':
        return deliveryPickupIcon;
        break;
      case 'tailor':
        return tailorIcon;
        break;
      case 'drycleaner':
        return drycleanerIcon;
        break;
      case 'helpalcab':
        return cabIcon;
        break;
      default:
        return riderIcon;
        break;
    }
  }

  static Color colorConvert(String hexaColor) {
    int falBackColor = 0xffFF0000;
    int newColor;
    if (hexaColor == null || hexaColor.length == 0) return Color(falBackColor);

    String inputSource = hexaColor.replaceFirst("#", "0xff");
    newColor = int.parse(inputSource, onError: (source) => falBackColor);

    return Color(newColor);
  }

  static loadScreen(BuildContext context, dynamic page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    /* Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration(milliseconds: 500),
      ),
    ); */
  }

  static getImage(
      GlobalKey<ScaffoldState> _scaffoldKey, Function getImageCallback) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        duration: Duration(seconds: 10),
        backgroundColor: Colors.white,
        content: Container(
          height: 250,
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              Container(
                child: Builder(builder: (context) {
                  return FlatButton(
                      onPressed: () {
                        _scaffoldKey.currentState.hideCurrentSnackBar();
                      },
                      child: Icon(Icons.arrow_drop_down));
                }),
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  size: 50,
                ),
                trailing: Icon(Icons.arrow_forward),
                title: Text("Camera"),
                subtitle: Text("Take a picture with camera"),
                onTap: () {
                  _scaffoldKey.currentState.hideCurrentSnackBar();
                  getImageCallback(ImageSource.camera);
                },
              ),
              ListTile(
                subtitle: Text("Select from gallary"),
                leading: Icon(
                  Icons.folder_open,
                  size: 50,
                ),
                trailing: Icon(Icons.arrow_forward),
                title: Text("Gallary"),
                onTap: () {
                  _scaffoldKey.currentState.hideCurrentSnackBar();
                  getImageCallback(ImageSource.gallery);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  static getImageViaOptions(
      GlobalKey<ScaffoldState> _scaffoldKey,
      Function getImageCallback,
      double maxHeight,
      double maxWidth,
      int quality,
      CameraDevice camera,
      String _file) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        duration: Duration(seconds: 10),
        backgroundColor: Colors.black87,
        content: Container(
          height: 250,
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              Container(
                child: Builder(builder: (context) {
                  return FlatButton(
                      onPressed: () {
                        _scaffoldKey.currentState.hideCurrentSnackBar();
                      },
                      child: Icon(Icons.arrow_drop_down));
                }),
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  size: 50,
                ),
                trailing: Icon(Icons.arrow_forward),
                title: Text("Camera"),
                subtitle: Text("Take a picture with camera"),
                onTap: () {
                  _scaffoldKey.currentState.hideCurrentSnackBar();
                  getImageCallback(ImageSource.camera, maxHeight, maxWidth,
                      quality, camera, _file);
                },
              ),
              ListTile(
                subtitle: Text("Select from gallary"),
                leading: Icon(
                  Icons.folder_open,
                  size: 50,
                ),
                trailing: Icon(Icons.arrow_forward),
                title: Text("Gallary"),
                onTap: () {
                  _scaffoldKey.currentState.hideCurrentSnackBar();
                  getImageCallback(ImageSource.gallery, maxHeight, maxWidth,
                      quality, camera, _file);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  //Services Logos and names
  static Map<int, String> serviceTitles = {
    0: "Plumbers",
    1: "Elecricians",
    2: "Delivery Service",
    3: "Cab & Bike",
    4: "Tailors",
    5: "Dry Cleaners",
  };
  static Map<int, Image> serviceLogos = {
    0: Image.asset('assets/images/services/logo8.png'),
    1: Image.asset('assets/images/services/logo7.png'),
    2: Image.asset('assets/images/services/logo6.png'),
    3: Image.asset('assets/images/services/cabnbike.png'),
    4: Image.asset('assets/images/services/logo5.png'),
    5: Image.asset('assets/images/services/logo4.png')
  };
  //Laundry List
  static List<String> gentsList = [
    "Cotton suit",
    "Suit",
    "Quilt single",
    "Quilt double",
    "Waistcoat",
    "Coat",
    "Drapes small",
    "Drapes large"
  ];

  static List<double> washPrices = [80, 40, 300, 500, 0, 0, 300, 400];
  static List<double> ironPrices = [50, 40, 0, 0, 100, 100, 0, 0];
  static List<double> bothPrices = [100, 80, 0, 0, 0, 0, 0, 0];
  static List<double> drycleanPrices = [0, 0, 0, 0, 300, 400, 0, 0];
  //clothes material types
  static Set<String> clothesMaterial = {
    "Select Clothing Material",
    "Cotton",
    "Karandi",
    "Jersey",
    "Boski",
    "Wash n Wear",
    "Chiffon",
    "Lawn",
    "Linen",
    "Net",
    "Silk",
    "Velvet",
    "Lace",
    "Crinkled",
    "Re-embroidered",
    "Wool",
    "Jeans",
    "Beaded",
    "Bengali",
    "Brocade",
    "Cashmere",
    "Nylon",
    "Crepe",
    "Matte"
  };
  static Set<String> stitchingType = {
    "Select Stitching Type",
    "Kameez Shalwar",
    "Kurta Shalwar",
    "Kurta",
    "Trouser",
    "Shirt",
    "Pant"
  };
  static Set<String> stitchingQuality = {
    "Select Stitching Quality",
    "Single Stitch",
    "Double Stitch"
  };

  //List of months names
  static ImageProvider getLogo(String field) {
    String basicPath = "assets/images/services/";
    if (field == null) {
      return Image.asset(basicPath + "logo3.png").image;
    }
    switch (field.toLowerCase()) {
      case "plumber":
        return Image.asset(basicPath + "logo8.png").image;
        break;
      case "electrician":
        return Image.asset(basicPath + "logo7.png").image;
        break;
      case "helpalbike":
        return Image.asset(basicPath + "logo2.png").image;
        break;
      case "deliverybike":
        return Image.asset(basicPath + "deliverybike.png").image;
        break;
      case "deliverypickup":
        return Image.asset(basicPath + "deliverypickup.png").image;
        break;
      case "helpalcab":
        return Image.asset(basicPath + "cab.png").image;
        break;
      case "tailor":
        return Image.asset(basicPath + "logo5.png").image;
        break;
      case "drycleaner":
        return Image.asset(basicPath + "logo4.png").image;
        break;
      default:
        return Image.asset(basicPath + "logo3.png").image;
        break;
    }
  }
  //CLASS END
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
