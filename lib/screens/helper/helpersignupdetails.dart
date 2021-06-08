import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:helpalapp/screens/helpee/picklocation.dart';
import 'package:helpalapp/screens/helper/helperdashboard.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/widgets/ShadowText.dart';
import 'package:helpalapp/widgets/custextfield.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HelperSignupDetails extends StatefulWidget {
  //getting service
  final OurServices myField;
  final String myPhone;

  const HelperSignupDetails({Key key, this.myField, this.myPhone})
      : super(key: key);

  @override
  _HelperSignupDetailsState createState() =>
      _HelperSignupDetailsState(myField, myPhone);
}

class _HelperSignupDetailsState extends State<HelperSignupDetails> {
  //Getting my Field
  final OurServices myField;
  final String myPhone;
  _HelperSignupDetailsState(this.myField, this.myPhone);
  BuildContext mycontext;

  bool fieldFocused = false;
  ScrollController scrollController = ScrollController();
  //current form key to control basic fields
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  //Image files
  File _cnicFront;
  File _cnicBack;
  File _shopphoto;
  File _vehicleReg;
  File _licenseFront;
  File _licenseBack;
  String _shoplocation = '';
  Uint8List _shopLocationImg;
  String _vehicletype = 'Select Vehicle';
  String _vehiclemaker = 'Select Maker';
  String _vehiclemodel = 'Select Model';
  String _vehiclenumber = '';
  Color _vehicleTypeColor = Appdetails.appGreenColor;
  Color _vehiclemakerColor = Appdetails.appGreenColor;
  Color _vehiclemodelColor = Appdetails.appGreenColor;
  Image defaultSopPhoto = Image.asset("assets/images/bubble.png");

  //image picker
  final picker = ImagePicker();

  ///Signup details for plumbers
  TextEditingController _shopname = TextEditingController();
  TextEditingController _shopadd = TextEditingController();
  //TextEditingController _alternatephone = TextEditingController();

  //Google maps instance variable
  GoogleMap myGoogleMap;
  //Google maps controller for this state
  GoogleMapController myMapController;
  //Markers for showing nearby helpers
  Set<Marker> shopLocationMarkers = Set();

  ColorFilter licenseFilter = ColorFilter.matrix(<double>[
    1,
    0.5,
    1,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _title() {
    var title = myField.toString().split(".")[1].toLowerCase();
    if (title.endsWith("s")) title = title.substring(0, title.length - 1);

    if (title.toLowerCase().contains("bike")) title = "helpal bike";
    if (title.toLowerCase().contains("cab")) title = "helpal cab";
    if (title.toLowerCase().contains("delivery")) title = "Delivery Service";

    return Center(
      child: Container(
        child: ShadowText(
          text: title.toUpperCase() + " REGISTRATION",
          fontColor: Colors.white,
          fontSize: 23,
          shadowColor: Colors.black.withAlpha(100),
          shadowBlur: 5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future getImage(ImageSource imageSource, double maxHeight, double maxWidth,
      int quality, CameraDevice camera, String fileName) async {
    final pickedFile = await picker.getImage(
        source: imageSource,
        preferredCameraDevice: camera,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        imageQuality: quality);

    setState(() {
      if (pickedFile != null) {
        switch (fileName) {
          case "_cnicFront":
            _cnicFront = File(pickedFile.path);
            break;
          case "_cnicBack":
            _cnicBack = File(pickedFile.path);
            break;
          case "_shopphoto":
            _shopphoto = File(pickedFile.path);
            break;
          case "_vehicleReg":
            _vehicleReg = File(pickedFile.path);
            break;
          case "_licenseFront":
            _licenseFront = File(pickedFile.path);
            break;
          case "_licenseBack":
            _licenseBack = File(pickedFile.path);
            break;
        }

        print('Image File :' + pickedFile.path);
        //cropImage();
      } else {
        print('No image selected.');
      }
    });
  }

  onMapCreated(GoogleMapController controller) async {
    print("Maps Created");
    setState(() {
      myMapController = controller;
    });
  }

  getShopSrc() async {
    if (myMapController == null) return;
    String markerpos = _shoplocation;
    double lat = double.parse(markerpos.split(",")[0]);
    double lng = double.parse(markerpos.split(",")[1]);
    LatLng position = new LatLng(lat, lng);

    await myMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        new CameraPosition(
          target: position,
          zoom: 15,
        ),
      ),
    );
    Marker marker =
        new Marker(position: position, markerId: new MarkerId('shop'));
    setState(() {
      shopLocationMarkers.add(marker);
    });
    Future.delayed(Duration(milliseconds: 1500), () async {
      var imgArray = await myMapController.takeSnapshot();
      //Before opening worker model we will close loading ui
      setState(() {
        _shopLocationImg = imgArray;
      });
    });
  }

  getShopLocation() {
    Appdetails.loadScreen(
        mycontext, PickLocation(callback: callbackAfterLocationPick));
  }

  callbackAfterLocationPick() {
    print("Getting call back from pick");
    setState(() {});
  }

  getAddresses() {
    if (Appdetails.lastAddress.length > 5) {
      print("Updating address to = " + Appdetails.lastAddress);

      setState(() {
        _shopadd.text = Appdetails.lastAddress;
        _shoplocation = Appdetails.lastLatlng;
        Appdetails.lastAddress = '';
        Appdetails.lastLatlng = '';
      });

      getShopSrc();
    }
  }

  @override
  Widget build(BuildContext context) {
    mycontext = context;
    setState(() {
      myGoogleMap = GoogleMap(
        padding: EdgeInsets.only(right: 5),
        markers: shopLocationMarkers,
        onMapCreated: onMapCreated,
        initialCameraPosition:
            CameraPosition(target: LatLng(34.185184, 73.3599774), zoom: 15),
        mapType: MapType.normal,
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        mapToolbarEnabled: false,
      );
    });
    //Screen size
    Size size = MediaQuery.of(context).size;
    double headerHeight = size.height / 100 * 12;
    double fieldsAreaHeight = size.height / 100 * 70;
    double footerHeight = size.height / 100 * 10;

    return Scaffold(
      key: _scaffoldKey,
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
      resizeToAvoidBottomInset: true,
      //Body Area
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              /* Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: Image.asset("assets/images/greenbg.png").image,
                      fit: BoxFit.cover),
                ),
                height: headerHeight,
                width: size.width,
              ), */
              //Fields Container
              Container(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: getCurrentFields(),
                  ),
                ),
              ),
              Container(
                height: footerHeight,
                width: size.width,
                //color: Appdetails.appGreenColor,
              ),
              Opacity(
                opacity: 0,
                child: Container(
                  height: 300,
                  child: myGoogleMap,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> getCurrentFields() {
    return myField == OurServices.Electricians ||
            myField == OurServices.Plumbers
        ? getPlumberElectricians()
        : myField == OurServices.DeliveryService
            ? getDelivery()
            : myField == OurServices.Drycleaners ||
                    myField == OurServices.Tailors
                ? getTailorsDrycleaners()
                : myField == OurServices.HelpalBike
                    ? getHelpalBike()
                    : myField == OurServices.HelpalCab
                        ? getHelpalCab()
                        : Container(
                            child: Center(
                              child: Text(
                                  "Got an error please try again\nif you continues facing this error\nplease contact developers!"),
                            ),
                          );
  }

  void successSignup() async {
    print("Received Success");
    await AuthService().saveDefaultLocalKeys(myPhone, "helpers");
    await AuthService().saveLocalString(Appdetails.signinKey, "true");
    await AuthService().saveLocalString(
        Appdetails.accountTypeKey, Appdetails.accountTypeValue_helper);
    Appdetails.loadScreen(mycontext, HelperDash());
  }

  Future uploadCnic() async {
    try {
      await StorageHandler.upload(_cnicFront.path, () {
        print("uploaded");
      }, UploadTypes.Cnic);
      await StorageHandler.upload(_cnicBack.path, () {
        print("uploaded");
      }, UploadTypes.Cnic);
      print("shop dp upload await complete");
      return true;
    } catch (w) {
      return w.toString();
    }
  }

  Future uploadLicense() async {
    try {
      await StorageHandler.upload(_licenseFront.path, () {
        print("uploaded");
      }, UploadTypes.License);
      await StorageHandler.upload(_licenseBack.path, () {
        print("uploaded");
      }, UploadTypes.License);
      print("shop dp upload await complete");
      return true;
    } catch (w) {
      return w.toString();
    }
  }

  Future uploadShopPhoto() async {
    try {
      await StorageHandler.upload(_shopphoto.path, () {
        print("uploaded");
      }, UploadTypes.Covers);

      print("shop dp upload await complete");
      return true;
    } catch (w) {
      return w.toString();
    }
  }

  Future uploadVechileReg() async {
    try {
      await StorageHandler.upload(_vehicleReg.path, () {
        print("uploaded");
      }, UploadTypes.VehicleReg);

      print("shop dp upload await complete");
      return true;
    } catch (w) {
      return w.toString();
    }
  }

  /////////////////////////////////////////////////
  ///PUMBERS ANd ELECTRICIANS
  ////////////////////////////////////////////////
  void signupPlumElec() async {
    DialogsHelpal.showLoadingDialog(mycontext, false);
    //Uploading CNIC
    if (_cnicFront != null && _cnicBack != null) {
      final cnic = await uploadCnic();
      if (cnic != true) {
        DialogsHelpal.showMsgBox("Failed", cnic, AlertType.error, mycontext,
            Appdetails.appGreenColor);
        return;
      }
    } else {
      DialogsHelpal.showMsgBox("Failed", "Please attach your cnic",
          AlertType.error, mycontext, Appdetails.appGreenColor);
      return;
    }
    //Uploading Shop Photo
    if (!isindivisual) {
      if (_shopphoto != null) {
        final photo = await uploadShopPhoto();
        if (photo != true) {
          DialogsHelpal.showMsgBox("Failed", photo, AlertType.error, mycontext,
              Appdetails.appGreenColor);
          return;
        }
      } else {
        DialogsHelpal.showMsgBox("Failed", "Please attach your shop photo",
            AlertType.error, mycontext, Appdetails.appGreenColor);
        return;
      }
    }
    //mapping details
    Map<String, dynamic> userData = {
      "shopname": _shopname.text,
      "shopphoto":
          isindivisual ? "" : StorageHandler.pathToFilename(_shopphoto.path),
      "shopadd": _shopadd.text,
      "shoplatlng": _shoplocation,
      "cnicfront": StorageHandler.pathToFilename(_cnicFront.path),
      "cnicback": StorageHandler.pathToFilename(_cnicBack.path),
      "completed": "true"
    };
    dynamic result =
        await AuthService().updateDocument('helpers', myPhone, userData);
    Navigator.pop(mycontext);
    if (result == 'Success') {
      DialogsHelpal.showMsgBoxCallback("Success", "Signup Completed",
          AlertType.success, mycontext, successSignup);
    } else {
      DialogsHelpal.showMsgBox("Failed", result, AlertType.error, mycontext,
          Appdetails.appGreenColor);
    }
  }

  bool isindivisual = false;
  List<Widget> getPlumberElectricians() {
    print("Displaying Plumbers");
    getAddresses();
    List<Widget> wl = new List();
    var empty = Container();
    var f0 = new Container(
      child: InkWell(
        onTap: () {
          if (isindivisual)
            isindivisual = false;
          else
            isindivisual = true;
          setState(() {});
        },
        child: Row(
          children: [
            Text(
              "Are you Individual.?",
              style: TextStyle(fontSize: 22),
            ),
            Expanded(child: Container()),
            Text(
              "Yes",
              style: TextStyle(fontSize: 22),
            ),
            Checkbox(
                activeColor: Appdetails.appGreenColor,
                value: isindivisual,
                onChanged: (val) {
                  isindivisual = val;
                  if (isindivisual) {
                    _shopname.text = "Individual";
                  } else {
                    _shopname.text = "";
                  }
                  setState(() {});
                }),
          ],
        ),
      ),
    );
    //Shop name
    var f2 = new CusTextField(
      controller: _shopname,
      hint: 'Shop Name',
      icon: Icon(Icons.shop),
      iconColor: Colors.grey[400],
      validator: (val) => val.isEmpty ? 'Please Provide Shop Name' : null,
    );
    //Shop Photo
    var f1 = getShopPhotoField();
    //Map Location
    var f3 = getMapLocationField();
    //Address of shop
    var f4 = new CusTextField(
      controller: _shopadd,
      hint: 'Shop Address',
      icon: Icon(Icons.pin_drop),
      iconColor: Colors.grey[400],
      validator: (val) => val.isEmpty ? 'Please Provide Shop Address' : null,
    );
    /* var f4b = new CusTextField(
      controller: _shopadd,
      hint: 'Your Address',
      icon: Icon(Icons.pin_drop),
      iconColor: Colors.grey[400],
      validator: (val) => val.isEmpty ? 'Please Provide Shop Address' : null,
    ); */
    //cnic field
    var f5 = getCnicField();
    //submit button
    var sb = getSubmitButton(() {
      if (!isindivisual) {
        if (_shoplocation.length < 5) {
          DialogsHelpal.showMsgBox(
              "Details Missing",
              "Please Select Your Shop Location On Map",
              AlertType.warning,
              mycontext,
              Appdetails.appGreenColor);
          return;
        }
      }
      if (_cnicFront == null || _cnicBack == null) {
        DialogsHelpal.showMsgBox(
            "Error",
            "Please provide all necessary details",
            AlertType.error,
            mycontext,
            Appdetails.appGreenColor);
        return;
      }
      if (isindivisual) {
        print("Validated");
        signupPlumElec();
      } else {
        if (_formKey.currentState.validate()) {
          print("Validated");
          signupPlumElec();
        }
      }
    });
    var dis = SizedBox(height: 20);

    wl.addAll([
      dis,
      f0,
      dis,
      isindivisual ? empty : f2,
      isindivisual ? empty : dis,
      isindivisual ? empty : f1,
      isindivisual ? empty : dis,
      isindivisual ? empty : f3,
      isindivisual ? empty : dis,
      isindivisual ? empty : f4,
      isindivisual ? empty : dis,
      f5,
      sb
    ]);
    return wl;
  }

  //////////////////////////////////////////////
  ///DELIVERY SERVICES BIKE AND PICKUP
  //////////////////////////////////////////////
  void signupDelivery() async {
    DialogsHelpal.showLoadingDialog(mycontext, false);
    //Uploading CNIC
    if (_cnicFront != null && _cnicBack != null) {
      final cnic = await uploadCnic();
      if (cnic != true) {
        DialogsHelpal.showMsgBox("Failed", cnic, AlertType.error, mycontext,
            Appdetails.appGreenColor);
        return;
      }
    } else {
      DialogsHelpal.showMsgBox("Failed", "Please attach your cnic",
          AlertType.error, mycontext, Appdetails.appGreenColor);
      return;
    }
    //Uploading License
    if (_licenseFront != null && _licenseBack != null) {
      final license = await uploadLicense();
      if (license != true) {
        DialogsHelpal.showMsgBox("Failed", license, AlertType.error, mycontext,
            Appdetails.appGreenColor);
        return;
      }
    } else {
      DialogsHelpal.showMsgBox("Failed", "Please attach your license",
          AlertType.error, mycontext, Appdetails.appGreenColor);
      return;
    }
    //Uploading Registration book
    if (_vehicleReg != null) {
      final veReg = await uploadVechileReg();
      if (veReg != true) {
        DialogsHelpal.showMsgBox("Failed", veReg, AlertType.error, mycontext,
            Appdetails.appGreenColor);
        return;
      }
    } else {
      DialogsHelpal.showMsgBox(
          "Failed",
          "Please attach a copy of\nyour vehicle registration book",
          AlertType.error,
          mycontext,
          Appdetails.appGreenColor);
      return;
    }
    Map<String, dynamic> userData = {
      "vehicle": _vehicletype,
      "maker": _vehiclemaker,
      "model": _vehiclemodel,
      "regnum": _vehiclenumber,
      "vehregphoto": StorageHandler.pathToFilename(_vehicleReg.path),
      "cnicfront": StorageHandler.pathToFilename(_cnicFront.path),
      "cnicback": StorageHandler.pathToFilename(_cnicBack.path),
      "licensefront": StorageHandler.pathToFilename(_licenseFront.path),
      "licenseback": StorageHandler.pathToFilename(_licenseBack.path),
      "field": "delivery" + _vehicletype.toLowerCase(),
      "completed": "true"
    };
    dynamic result =
        await AuthService().updateDocument('helpers', myPhone, userData);
    Navigator.pop(mycontext);
    if (result == 'Success') {
      DialogsHelpal.showMsgBoxCallback("Success", "Signup Completed",
          AlertType.success, mycontext, successSignup);
    } else {
      DialogsHelpal.showMsgBox("Failed", result, AlertType.error, mycontext,
          Appdetails.appGreenColor);
    }
  }

  getDelivery() {
    List<Widget> wl = new List();
    //Field Type
    var f1 = getVehicleTypeField();
    //Field Makers
    List<String> makers = ['Select Maker', "Honda", "Suzuki", "Road Prince"];

    var f2 = getVehicleMakerField(makers);
    //Year Field
    var f3 = getVehicleModelsField();
    var f4 = new CusTextField(
      capitalization: TextCapitalization.characters,
      hint: 'Vehicle Number (IDM-550)',
      icon: Icon(Icons.confirmation_number),
      validator: (val) => val.isEmpty ? 'Please Provide Vehicle Number' : null,
      onChanged: (val) => setState(() => _vehiclenumber = val),
    );
    var f5 = getVehicleRegField();
    var f6 = getCnicField();
    var f7 = getLicenseField();

    //submit button
    var sb = getSubmitButton(() {
      //Checking vehicle type
      if (_vehicletype.startsWith("Select"))
        setState(() => _vehicleTypeColor = Colors.red);
      else
        setState(() => _vehicleTypeColor = Appdetails.appGreenColor);
      //checking Vehicle maker
      if (_vehiclemaker.startsWith("Select"))
        setState(() => _vehiclemakerColor = Colors.red);
      else
        setState(() => _vehiclemakerColor = Appdetails.appGreenColor);
      //checking Vehicle maker
      if (_vehiclemodel.startsWith("Select"))
        setState(() => _vehiclemodelColor = Colors.red);
      else
        setState(() => _vehiclemodelColor = Appdetails.appGreenColor);

      if (_vehicletype.startsWith("Select") ||
          _vehiclemaker.startsWith("Select") ||
          _vehiclemodel.startsWith("Select")) return;

      if (_vehicleReg == null ||
          _cnicFront == null ||
          _cnicBack == null ||
          _licenseBack == null ||
          _licenseFront == null) {
        DialogsHelpal.showMsgBox(
            "Details Missing",
            "Please check details and try again",
            AlertType.error,
            mycontext,
            Appdetails.appGreenColor);
        return;
      }
      if (_formKey.currentState.validate()) {
        print("Validated");
        signupDelivery();
      }
    });
    var dis = SizedBox(height: 20);

    wl.addAll([
      dis,
      f1,
      dis,
      f2,
      dis,
      f3,
      dis,
      f4,
      dis,
      f5,
      dis,
      f6,
      dis,
      f7,
      dis,
      sb
    ]);
    return wl;
  }

  ////////////////////////////////////////////////
  ///HELPAL BIKE
  ///////////////////////////////////////////////
  void signupBike() async {
    DialogsHelpal.showLoadingDialog(mycontext, false);
    //Uploading CNIC
    if (_cnicFront != null && _cnicBack != null) {
      final cnic = await uploadCnic();
      if (cnic != true) {
        DialogsHelpal.showMsgBox("Failed", cnic, AlertType.error, mycontext,
            Appdetails.appGreenColor);
        return;
      }
    } else {
      DialogsHelpal.showMsgBox("Failed", "Please attach your cnic",
          AlertType.error, mycontext, Appdetails.appGreenColor);
      return;
    }
    //Uploading License
    if (_licenseFront != null && _licenseBack != null) {
      final license = await uploadLicense();
      if (license != true) {
        DialogsHelpal.showMsgBox("Failed", license, AlertType.error, mycontext,
            Appdetails.appGreenColor);
        return;
      }
    } else {
      DialogsHelpal.showMsgBox("Failed", "Please attach your license",
          AlertType.error, mycontext, Appdetails.appGreenColor);
      return;
    }
    //Uploading Registration book
    if (_vehicleReg != null) {
      final veReg = await uploadVechileReg();
      if (veReg != true) {
        DialogsHelpal.showMsgBox("Failed", veReg, AlertType.error, mycontext,
            Appdetails.appGreenColor);
        return;
      }
    } else {
      DialogsHelpal.showMsgBox(
          "Failed",
          "Please attach a copy of\nyour vehicle registration book",
          AlertType.error,
          mycontext,
          Appdetails.appGreenColor);
      return;
    }
    Map<String, dynamic> userData = {
      "maker": _vehiclemaker,
      "model": _vehiclemodel,
      "regnum": _vehiclenumber,
      "vehregphoto": StorageHandler.pathToFilename(_vehicleReg.path),
      "cnicfront": StorageHandler.pathToFilename(_cnicFront.path),
      "cnicback": StorageHandler.pathToFilename(_cnicBack.path),
      "licensefront": StorageHandler.pathToFilename(_licenseFront.path),
      "licenseback": StorageHandler.pathToFilename(_licenseBack.path),
      "completed": "true"
    };
    dynamic result =
        await AuthService().updateDocument('helpers', myPhone, userData);
    Navigator.pop(mycontext);
    if (result == 'Success') {
      DialogsHelpal.showMsgBoxCallback("Success", "Signup Completed",
          AlertType.success, mycontext, successSignup);
    } else {
      DialogsHelpal.showMsgBox("Failed", result, AlertType.error, mycontext,
          Appdetails.appGreenColor);
    }
  }

  getHelpalBike() {
    List<Widget> wl = new List();
    //Field Makers
    List<String> makers = [
      'Select Maker',
      'Honda',
      'United',
      'Pak Hero',
      "Road Prince",
      "High Speed",
      'Suzuki',
      'Zxmco',
      'Other'
    ];
    //maker
    var f1 = getVehicleMakerField(makers);
    //model
    var f2 = getVehicleModelsField();
    //number
    var f3 = new CusTextField(
      hint: 'Bike Number (RLC-110)',
      capitalization: TextCapitalization.characters,
      icon: Icon(Icons.confirmation_number),
      validator: (val) => val.isEmpty ? 'Please Provide Bike Number' : null,
      onChanged: (val) => setState(() => _vehiclenumber = val),
    );
    var f4 = getVehicleRegField();
    var f5 = getCnicField();
    var f6 = getLicenseField();
    //submit button
    var sb = getSubmitButton(() {
      //checking Vehicle maker
      if (_vehiclemaker.startsWith("Select"))
        setState(() => _vehiclemakerColor = Colors.red);
      else
        setState(() => _vehiclemakerColor = Appdetails.appGreenColor);
      //checking Vehicle model
      if (_vehiclemodel.startsWith("Select"))
        setState(() => _vehiclemodelColor = Colors.red);
      else
        setState(() => _vehiclemodelColor = Appdetails.appGreenColor);

      if (_vehiclemaker.startsWith("Select") ||
          _vehiclemodel.startsWith("Select")) return;

      if (_vehicleReg == null ||
          _cnicFront == null ||
          _cnicBack == null ||
          _licenseBack == null ||
          _licenseFront == null) {
        DialogsHelpal.showMsgBox(
            "Details Missing",
            "Please check details and try again",
            AlertType.error,
            mycontext,
            Appdetails.appGreenColor);
        return;
      }

      if (_formKey.currentState.validate()) {
        signupBike();
      }
    });
    var dis = SizedBox(height: 20);
    wl.addAll([dis, f1, dis, f2, dis, f3, dis, f4, dis, f5, dis, f6, dis, sb]);
    return wl;
  }

  void signupCab() async {
    DialogsHelpal.showLoadingDialog(mycontext, false);
    Map<String, dynamic> userData = {
      "maker": _vehiclemaker,
      "model": _vehiclemodel,
      "regnum": _vehiclenumber,
      "vehregphoto": StorageHandler.pathToFilename(_vehicleReg.path),
      "cnicfront": StorageHandler.pathToFilename(_cnicFront.path),
      "cnicback": StorageHandler.pathToFilename(_cnicBack.path),
      "licensefront": StorageHandler.pathToFilename(_licenseFront.path),
      "licenseback": StorageHandler.pathToFilename(_licenseBack.path),
      "completed": "true"
    };
    dynamic result =
        await AuthService().updateDocument('helpers', myPhone, userData);
    Navigator.pop(mycontext);
    if (result == 'Success') {
      DialogsHelpal.showMsgBoxCallback("Success", "Signup Completed",
          AlertType.success, mycontext, successSignup);
    } else {
      DialogsHelpal.showMsgBox("Failed", result, AlertType.error, mycontext,
          Appdetails.appGreenColor);
    }
  }

  getHelpalCab() {
    List<Widget> wl = new List();
    //Field Makers
    List<String> makers = [
      'Select Maker',
      'Honda',
      'Toyota',
      'Daihatsu',
      'Road Prince',
      'United',
      'Suzuki',
      'Other'
    ];
    //maker
    var f1 = getVehicleMakerField(makers);
    //model
    var f2 = getVehicleModelsField();
    //number
    var f3 = new CusTextField(
      hint: 'Car Number (RLC-110)',
      icon: Icon(Icons.confirmation_number),
      validator: (val) => val.isEmpty ? 'Please Provide Car Number' : null,
      onChanged: (val) => setState(() => _vehiclenumber = val),
    );
    var f4 = getVehicleRegField();
    var f5 = getCnicField();
    var f6 = getLicenseField();
    //submit button
    var sb = getSubmitButton(() {
      //checking Vehicle maker
      if (_vehiclemaker.startsWith("Select"))
        setState(() => _vehiclemakerColor = Colors.red);
      else
        setState(() => _vehiclemakerColor = Appdetails.appGreenColor);
      //checking Vehicle model
      if (_vehiclemodel.startsWith("Select"))
        setState(() => _vehiclemodelColor = Colors.red);
      else
        setState(() => _vehiclemodelColor = Appdetails.appGreenColor);

      if (_vehiclemaker.startsWith("Select") ||
          _vehiclemodel.startsWith("Select")) return;

      if (_vehicleReg == null ||
          _cnicFront == null ||
          _cnicBack == null ||
          _licenseBack == null ||
          _licenseFront == null) {
        DialogsHelpal.showMsgBox(
            "Details Missing",
            "Please check details and try again",
            AlertType.error,
            mycontext,
            Appdetails.appGreenColor);
        return;
      }

      if (_formKey.currentState.validate()) {
        signupBike();
      }
    });
    var dis = SizedBox(height: 20);
    wl.addAll([dis, f1, dis, f2, dis, f3, dis, f4, dis, f5, dis, f6, dis, sb]);
    return wl;
  }

  //////////////////////////////////////////////////////////////
  //DRY CLEANERS AND TAILORS
  /////////////////////////////////////////////////////////////
  void signupTailorDrycleaners() async {
    DialogsHelpal.showLoadingDialog(mycontext, false);
    //Uploading Shop Photo
    if (_shopphoto != null) {
      final photo = await uploadShopPhoto();
      if (photo != true) {
        DialogsHelpal.showMsgBox("Failed", photo, AlertType.error, mycontext,
            Appdetails.appGreenColor);
        return;
      }
    } else {
      DialogsHelpal.showMsgBox("Failed", "Please attach your shop photo",
          AlertType.error, mycontext, Appdetails.appGreenColor);
      return;
    }

    Map<String, dynamic> userData = {
      "shopname": _shopname.text,
      "shopphoto": StorageHandler.pathToFilename(_shopphoto.path),
      "shopadd": _shopadd.text,
      "services": servicesList,
      "shoplatlng": _shoplocation,
      "completed": "true"
    };
    dynamic result =
        await AuthService().updateDocument('helpers', myPhone, userData);
    Navigator.pop(mycontext);
    if (result == 'Success') {
      DialogsHelpal.showMsgBoxCallback("Success", "Signup Completed",
          AlertType.success, mycontext, successSignup);
    } else {
      DialogsHelpal.showMsgBox("Failed", result, AlertType.error, mycontext,
          Appdetails.appGreenColor);
    }
  }

  getTailorsDrycleaners() {
    getAddresses();
    List<Widget> wl = new List();
    var f1 = getShopPhotoField();
    var f2 = new CusTextField(
      controller: _shopname,
      hint: 'Shop Name',
      icon: Icon(Icons.shop),
      iconColor: Colors.grey[400],
      validator: (val) => val.isEmpty ? 'Please Provide Shop Name' : null,
    );
    var f3 = getMapLocationField();

    var f4 = new CusTextField(
      controller: _shopadd,
      hint: 'Shop Address',
      icon: Icon(Icons.pin_drop),
      iconColor: Colors.grey[400],
      validator: (val) =>
          val.length < 10 ? 'Please Provide Valid Address' : null,
    );
    var f5 = widget.myField == OurServices.Tailors
        ? getServicesField()
        : SizedBox(height: 0);
    //submit button
    var sb = getSubmitButton(() {
      if (_shopphoto == null) {
        DialogsHelpal.showMsgBox("Details Missing", "Please add a shop photo",
            AlertType.error, mycontext, Appdetails.appGreenColor);
        return;
      }
      if (_shopLocationImg == null) {
        DialogsHelpal.showMsgBox(
            "Details Missing",
            "Please select you shop location",
            AlertType.error,
            mycontext,
            Appdetails.appGreenColor);

        return;
      }
      if (myField == OurServices.Tailors && servicesList.length == 0) {
        DialogsHelpal.showMsgBox("Details Missing", "Please add some services",
            AlertType.error, mycontext, Appdetails.appGreenColor);

        return;
      }
      if (_formKey.currentState.validate()) {
        signupTailorDrycleaners();
      }
    });

    var dis = SizedBox(height: 20);
    wl.addAll([dis, f1, dis, f2, dis, f3, dis, f4, dis, f5, dis, sb]);

    return wl;
  }

  //////////////////////////////////////////////////////////
  ///////FIELDS LIST
  /////////////////////////////////////////////////////////
  //Button Submit
  getSubmitButton(Function onPressed) {
    return Container(
      height: 50,
      width: 300,
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
          onPressed: onPressed,
        ),
      ),
    );

    /*    return Container(
      height: 50,
      alignment: Alignment.centerRight,
      child: FlatButton(
        color: Colors.grey[100],
        onPressed: onPressed,
        child: Container(
          height: 50,
          width: 50,
          child: Icon(
            Icons.arrow_forward,
            size: 30,
          ),
        ),
      ),
    ); */
  }

  Map<String, dynamic> servicesList = Map();
  TextEditingController serviceTitle = TextEditingController();
  TextEditingController servicePrice = TextEditingController();

  getServicesField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add your services",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: 10),
          Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Appdetails.appGreenColor.withAlpha(50),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  color: Colors.white,
                  child: CusTextField(
                    controller: serviceTitle,
                    hint: 'Service Title',
                    icon: Icon(Icons.list),
                    iconColor: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  color: Colors.white,
                  child: CusTextField(
                    controller: servicePrice,
                    hint: 'Service Price',
                    imgIcon: ImageIcon(
                      Image.asset("assets/images/icons/money.png").image,
                      size: 25,
                    ),
                    iconColor: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 10),
                MaterialButton(
                  child: ShadowText(
                    text: "Add Service",
                    fontColor: Colors.white,
                    shadowColor: Colors.black54,
                    shadowBlur: 5,
                  ),
                  onPressed: () {
                    if (serviceTitle.text.length > 0 &&
                        servicePrice.text.length > 0) {
                      setState(() {
                        Map<String, dynamic> serviceMap = {
                          serviceTitle.text: servicePrice.text
                        };
                        servicesList.addAll(serviceMap);
                        serviceTitle.text = '';
                        servicePrice.text = '';
                      });
                    } else {
                      DialogsHelpal.showMsgBox(
                          "Details Missing",
                          "Please type details first",
                          AlertType.info,
                          mycontext,
                          Appdetails.appGreenColor);
                    }
                  },
                  color: Appdetails.appGreenColor,
                  textColor: Colors.grey[800],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: servicesList.length != 0
                      ? Text(
                          "Your Services",
                        )
                      : SizedBox(height: 0),
                ),
                SizedBox(height: 10),
                Container(
                  height: getheight(),
                  child: servicesList.length == 0
                      ? SizedBox(
                          height: 0,
                        )
                      : MediaQuery.removePadding(
                          context: mycontext,
                          removeTop: true,
                          child: ListView.builder(
                            itemCount: servicesList.length,
                            itemBuilder: (BuildContext context, int index) {
                              String serviceT =
                                  servicesList.keys.elementAt(index);
                              String serviceP =
                                  servicesList.values.elementAt(index);

                              return Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                margin: EdgeInsets.only(bottom: 5),
                                child: Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 15),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                serviceT.capitalize(),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey[600]),
                                              ),
                                              Text(
                                                "Rs " + serviceP,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[500]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 50,
                                        width: 50,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.grey[500],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              servicesList.remove(serviceT);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double getheight() {
    double lnt = double.parse(servicesList.length.toString());
    return lnt * 80;
  }

  getVehicleTypeField() {
    return DropdownButton<String>(
      value: _vehicletype,
      icon: Icon(Icons.arrow_downward),
      iconSize: 16,
      elevation: 5,
      isExpanded: true,
      dropdownColor: Appdetails.colorConvert("#D1FAD7"),
      style: TextStyle(color: Colors.grey[600], fontSize: 18),
      underline: Container(height: 1, color: _vehicleTypeColor),
      onChanged: (newValue) => setState(() => _vehicletype = newValue),
      items: <String>['Select Vehicle', 'Bike', 'Pickup']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    );
  }

  getVehicleModelsField() {
    return DropdownButton<String>(
      value: _vehiclemodel,
      icon: Icon(Icons.arrow_downward),
      iconSize: 16,
      elevation: 5,
      isExpanded: true,
      dropdownColor: Appdetails.colorConvert("#D1FAD7"),
      style: TextStyle(color: Colors.grey[600], fontSize: 18),
      underline: Container(height: 1, color: _vehiclemodelColor),
      onChanged: (String newValue) => setState(() => _vehiclemodel = newValue),
      items: <String>[
        'Select Model',
        '2010',
        '2011',
        '2012',
        '2013',
        '2014',
        '2015',
        '2016',
        '2017',
        '2018',
        '2019',
        '2020',
        '2021'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    );
  }

  getVehicleMakerField(List<String> makersList) {
    return DropdownButton<String>(
      value: _vehiclemaker,
      icon: Icon(Icons.arrow_downward),
      iconSize: 16,
      elevation: 5,
      isExpanded: true,
      dropdownColor: Appdetails.colorConvert("#D1FAD7"),
      style: TextStyle(color: Colors.grey[600], fontSize: 18),
      underline: Container(height: 1, color: _vehiclemakerColor),
      onChanged: (newValue) => setState(() => _vehiclemaker = newValue),
      items: makersList.map<DropdownMenuItem<String>>((value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    );
  }

  getShopPhotoField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Photo Cover of your Shop",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal),
          ),
          SizedBox(height: 5),
          Container(
            height: 90,
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: _shopphoto == null
                    ? defaultSopPhoto.image
                    : Image.file(_shopphoto).image,
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Appdetails.appGreenColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: InkWell(
                onTap: () => Appdetails.getImageViaOptions(_scaffoldKey,
                    getImage, 800, 1280, 80, CameraDevice.rear, "_shopphoto"),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getMapLocationField() {
    return Container(
      height: 115,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Location on Map",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: 5),
          Container(
            height: 90,
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[600]),
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: _shopLocationImg != null
                    ? MemoryImage(_shopLocationImg)
                    : Image.asset("assets/images/mapdummy.png").image,
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Appdetails.appGreenColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: InkWell(
                onTap: () => getShopLocation(),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getCnicField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Scanned Copy of CNIC Font & Back",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal)),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(10),
                height: 75,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: _cnicFront != null
                        ? Image.file(_cnicFront).image
                        : Image.asset("assets/images/cnicf.png").image,
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(5),
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    color: Appdetails.appGreenColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: InkWell(
                    onTap: () => Appdetails.getImageViaOptions(
                        _scaffoldKey,
                        getImage,
                        250,
                        350,
                        95,
                        CameraDevice.rear,
                        "_cnicFront"),
                    child: Icon(
                      Icons.edit,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                height: 75,
                width: 120,
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: _cnicBack != null
                        ? Image.file(_cnicBack).image
                        : Image.asset("assets/images/cnicb.png").image,
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(5),
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    color: Appdetails.appGreenColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: InkWell(
                    onTap: () => Appdetails.getImageViaOptions(_scaffoldKey,
                        getImage, 250, 350, 95, CameraDevice.rear, "_cnicBack"),
                    child: Icon(
                      Icons.edit,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  getLicenseField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Scanned Copy of License Font & Back",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal)),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(10),
                height: 75,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    colorFilter: _licenseFront == null
                        ? licenseFilter
                        : ColorFilter.mode(Colors.transparent, BlendMode.color),
                    fit: BoxFit.contain,
                    image: _licenseFront != null
                        ? Image.file(_licenseFront).image
                        : Image.asset("assets/images/cnicf.png").image,
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(5),
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    color: Appdetails.appGreenColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: InkWell(
                    onTap: () => Appdetails.getImageViaOptions(
                        _scaffoldKey,
                        getImage,
                        250,
                        350,
                        95,
                        CameraDevice.rear,
                        "_licenseFront"),
                    child: Icon(
                      Icons.add,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                height: 75,
                width: 120,
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    colorFilter: _licenseBack == null
                        ? licenseFilter
                        : ColorFilter.mode(Colors.transparent, BlendMode.color),
                    image: _licenseBack != null
                        ? Image.file(_licenseBack).image
                        : Image.asset("assets/images/cnicb.png").image,
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(5),
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    color: Appdetails.appGreenColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: InkWell(
                    onTap: () => Appdetails.getImageViaOptions(
                        _scaffoldKey,
                        getImage,
                        250,
                        350,
                        95,
                        CameraDevice.rear,
                        "_licenseBack"),
                    child: Icon(
                      Icons.edit,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  getVehicleRegField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Copy of Vehicle Registration",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal)),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(10),
                height: 150,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: _vehicleReg != null
                        ? Image.file(_vehicleReg).image
                        : Image.asset("assets/images/vehreg.png").image,
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(5),
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    color: Appdetails.appGreenColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: InkWell(
                    onTap: () => Appdetails.getImageViaOptions(
                        _scaffoldKey,
                        getImage,
                        1280,
                        800,
                        95,
                        CameraDevice.rear,
                        "_vehicleReg"),
                    child: Icon(
                      Icons.add,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
