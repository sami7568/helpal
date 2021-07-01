import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/helpee/helpeeorders.dart';
import 'package:helpalapp/functions/helpee/ratingscreen.dart';
import 'package:helpalapp/functions/locationmanager.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:helpalapp/screens/helpee/helpeeWalletDrawer.dart';
import 'package:helpalapp/screens/helpee/helpeebottomnavbar.dart';
import 'package:helpalapp/screens/helpee/helpeedrawer.dart';
import 'package:helpalapp/screens/helpee/helpeerecents.dart';
import 'package:helpalapp/screens/helpee/helpeesettingsnew.dart';
import 'package:helpalapp/screens/helpee/searchforhelper.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/helpee/workermodel.dart';
import 'package:helpalapp/screens/helpee/workermodelvehicle.dart';
import 'package:helpalapp/widgets/displaypicture.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:overlay_container/overlay_container.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HelpeeDashboard extends StatefulWidget {
  @override
  _HelpeeDashboardState createState() => _HelpeeDashboardState();
}

class _HelpeeDashboardState extends State<HelpeeDashboard>
    with SingleTickerProviderStateMixin {
  AnimationController _controllerAnim;
  BuildContext mycontext;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // user details
  String username = 'Loading...';
  String userlogourl = '';

  //Pages control
  PageController _pageController;
  int currentIndex = 0;
  //static const _kDuration = const Duration(milliseconds: 300);
  //static const _kCurve = Curves.ease;

  //Services

  @override
  void dispose() {
    super.dispose();
    _controllerAnim.dispose();
    _pageController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    //init orders data
    startSync();
    startLocationService();
  }

  void startLocationService() async {
    //Requesting location service
    await LocationManager.startLocationService();
  }

  onChangedFunction(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Widget _buildTitle() {
    return Center(child: _helpal());
  }

  Widget _helpal() {
    AssetImage assetImage = AssetImage('assets/images/mainlogo.png');
    Image image = Image(
      image: assetImage,
      height: 30,
    );
    return Hero(tag: "helpal", child: image);
  }

  Widget _drawerBtn() {
    return Container(
      color: Colors.transparent,
      child: IconButton(
        icon: Icon(Icons.menu),
        color: Colors.grey[600],
        onPressed: () => _scaffoldKey.currentState.openDrawer(),
      ),
    );
  }

  _walletBtn() {
    return Container(
      margin: EdgeInsets.only(right: 10),
      height: 25,
      width: 25,
      color: Colors.transparent,
      child: InkWell(
        child: Image(
          image: Image.asset("assets/images/icons/wallet.png").image,
          color: Colors.grey[600],
        ),
        onTap: () {
          _scaffoldKey.currentState.openEndDrawer();
        },
      ),
    );
  }

  void startSync() {
    print("Sync Started");
    HelpeeOrdersUpdate().initDatabase();

    if (Appdetails.myDp == null) {
      getMyDp();
      print("Getting DP");
    } else {
      print("Dp Already Fetched");
    }
  }

  void getMyDp() async {
    String value = HelpalStreams.prefs.getString(Appdetails.photoidKey);
    print("my photo id is=$value");
    if (value == null || value.length == 0) return;

    String url =
        await StorageHandler.getDownloadUrl(value, UploadTypes.DisplayPicture);
    if (!url.startsWith("Error")) {
      Appdetails.myDp = Image.network(url);
    }
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => SystemNavigator.pop(),
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    mycontext = context;
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        extendBodyBehindAppBar: false,
        drawerScrimColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: _drawerBtn(),
          title: _buildTitle(),
          actions: [_walletBtn()],
        ),
        endDrawer: HelpeeWalletDrawer(
          phone: "+923321535880",
        ),
        bottomNavigationBar: HelpeeBottomNavbar()
            .getnewnavbar(context, currentIndex, _pageController),
        drawer: HelpeeDrawer(),
        body: Stack(
          children: [
            PageView(
              onPageChanged: onChangedFunction,
              controller: _pageController,
              children: <Widget>[
                Container(
                  child: homePage(size),
                ),
                Container(
                  child: RecentHistory(),
                ),
                Container(
                  child: HelpeeSettings(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color disableColor = Colors.grey;
  Color enableColor = Colors.yellow[600];
  int currentStars = 0;
  String currentText = "";
  Set<String> ratingMap = {"Very Poor", "Poor", "Avarage", "Good", "Excellent"};

  void setRatingState(int stars) {
    setState(() {
      currentStars = stars;
      currentText = ratingMap.elementAt(stars - 1);
    });
  }

  //Overlay
  bool _cabBikeOverlay = false;
  getCabBikeOverlay() {
    return OverlayContainer(
      show: _cabBikeOverlay,
      // Let's position this overlay to the right of the button.
      position: OverlayContainerPosition(
        // Left position.
        MediaQuery.of(mycontext).size.width / 2 - 50,
        // Bottom position.
        0,
      ),
      // The content inside the overlay.
      child: Container(
        height: 100,
        width: 100,
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey[300],
              blurRadius: 10,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _cabBikeOverlay = false;
                });
              },
              child: Container(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.close,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                setState(() {
                  _cabBikeOverlay = false;
                });
                onButtonPressed("helpalbike");
              },
              child: Container(
                width: 100,
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text("Helpal Bike"),
              ),
            ),
            SizedBox(height: 3),
            InkWell(
              onTap: () {
                setState(() {
                  _cabBikeOverlay = false;
                });
                onButtonPressed("helpalcab");
              },
              child: Container(
                width: 100,
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text("Helpal Cab"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Overlay
  bool _deliveryOverlay = false;
  getDeliveryOverlay() {
    return OverlayContainer(
      show: _deliveryOverlay,
      // Let's position this overlay to the right of the button.
      position: OverlayContainerPosition(
        // Left position.
        MediaQuery.of(mycontext).size.width / 2 - 50,
        // Bottom position.
        0,
      ),
      // The content inside the overlay.
      child: Container(
        height: 100,
        width: 100,
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey[300],
              blurRadius: 10,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _deliveryOverlay = false;
                });
              },
              child: Container(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.close,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                setState(() {
                  _deliveryOverlay = false;
                });
                onButtonPressed("deliverybike");
              },
              child: Container(
                width: 100,
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text("Delivery Bike"),
              ),
            ),
            SizedBox(height: 3),
            InkWell(
              onTap: () {
                setState(() {
                  _deliveryOverlay = false;
                });
                onButtonPressed("deliverypickup");
              },
              child: Container(
                width: 100,
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text("Delivery Pickup"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Home page
  Widget homePage(Size screenSize) {
    double headerHeight = screenSize.height / 2;
    double iconSize = screenSize.width / 100 * 20;
    Color lightBlack = Color.fromARGB(60, 0, 0, 0);

    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: headerHeight,
              width: screenSize.width,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: screenSize.width,
                      padding: EdgeInsets.only(left: 20, top: 20),
                      child: Text(
                        "What Help Do You Need?",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    //Quick ride
                    Container(
                      alignment: Alignment.centerRight,
                      width: screenSize.width,
                      child: Container(
                        padding: EdgeInsets.only(
                          top: 5,
                          bottom: 5,
                          left: 6,
                          right: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.white),
                              child: Image(
                                image: Image.asset(
                                  "assets/images/services/logo2.png",
                                ).image,
                                height: 35,
                              ),
                            ),
                            Text(
                              "Get a quick ride with Helpal Bike",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        //height: screenSize.height / 100 * 7,
                        //width: screenSize.width / 100 * 80,
                        decoration: BoxDecoration(
                          color: Appdetails.appBlueColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(100),
                            bottomLeft: Radius.circular(100),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: lightBlack,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                    getCabBikeOverlay(),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //Plumber
                          getServiceButton(iconSize, 0, "plumber"),
                          SizedBox(width: iconSize / 2),
                          //Bike
                          getServiceButton(iconSize, 3, ""),
                          SizedBox(width: iconSize / 2),
                          //Tailors
                          getServiceButton(iconSize, 4, "tailor"),
                        ],
                      ),
                    ),
                    getDeliveryOverlay(),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //Electrician
                          getServiceButton(iconSize, 1, "electrician"),

                          SizedBox(width: iconSize / 2),
                          //Delivery
                          getServiceButton(iconSize, 2, ""),
                          SizedBox(width: iconSize / 2),
                          //Drycleaner
                          getServiceButton(iconSize, 5, "drycleaner"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    //width: screenSize.width / 100 * 80,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset.zero,
                          color: lightBlack,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image(
                                image: Image.asset("assets/images/icons/ac.png")
                                    .image,
                                height: 25),
                            SizedBox(width: 10),
                            Text(
                              "A/C Technician",
                              style: TextStyle(
                                  fontSize: 22, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          "This summer get your A/C serviced by a skilled Technician",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Spacer(),
                            GradButton(
                              onPressed: () {
                                Alert(
                                  title: "Work Completed",
                                  context: context,
                                  style: AlertStyle(
                                    isOverlayTapDismiss: false,
                                    overlayColor: Colors.black.withAlpha(200),
                                    titleStyle: TextStyle(
                                      fontSize: 33,
                                      color: Appdetails.appBlueColor,
                                    ),
                                    alertPadding: EdgeInsets.all(5),
                                  ),
                                  content: Container(
                                    width: screenSize.width / 100 * 80,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 30),
                                              CircleAvatar(
                                                maxRadius: 50,
                                                backgroundImage: Image.asset(
                                                        "assets/images/avatar.png")
                                                    .image,
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                "Azmat Ali Khan",
                                                style: TextStyle(
                                                  fontSize: 30,
                                                ),
                                              ),
                                              Text(
                                                "Plumber",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 30),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () => setRatingState(1),
                                              child: Icon(
                                                Icons.star,
                                                size: 40,
                                                color: currentStars > 0
                                                    ? enableColor
                                                    : disableColor,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => setRatingState(2),
                                              child: Icon(
                                                Icons.star,
                                                size: 40,
                                                color: currentStars > 1
                                                    ? enableColor
                                                    : disableColor,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => setRatingState(3),
                                              child: Icon(
                                                Icons.star,
                                                size: 40,
                                                color: currentStars > 2
                                                    ? enableColor
                                                    : disableColor,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => setRatingState(4),
                                              child: Icon(
                                                Icons.star,
                                                size: 40,
                                                color: currentStars > 3
                                                    ? enableColor
                                                    : disableColor,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => setRatingState(5),
                                              child: Icon(
                                                Icons.star,
                                                size: 40,
                                                color: currentStars > 4
                                                    ? enableColor
                                                    : disableColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          currentText,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 15),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Appdetails.appBlueColor
                                                      .withAlpha(40),
                                                ),
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.name,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText:
                                                        'What needs to be improved?',
                                                    hintStyle:
                                                        TextStyle(fontSize: 18),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                            vertical: 20),
                                                  ),
                                                  maxLines: 4,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  buttons: [
                                    DialogButton(
                                        color: Appdetails.appBlueColor,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 0),
                                        child: Text(
                                          "Submit Feedback",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                        onPressed: () {})
                                  ],
                                ).show();
                              },
                              child: Text(
                                "Hire a Technician",
                                style: TextStyle(color: Colors.white),
                              ),
                              width: screenSize.width / 100 * 80 / 3,
                              height: 30,
                              backgroundColor: Appdetails.appBlueColor,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 60,
                    //width: screenSize.width / 100 * 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset.zero,
                          color: lightBlack,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                        child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100)),
                          child: Image(
                            image: Image.asset("assets/images/icons/boy.png")
                                .image,
                            height: 20,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: GradButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 35,
                                  width: 35,
                                  padding: EdgeInsets.all(7),
                                  child: Image(
                                    image: Image.asset(
                                            "assets/images/icons/caution.png")
                                        .image,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "Helpal COVID-19 Safety Guidelines",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            height: 30,
                            backgroundColor: Appdetails.appBlueColor,
                          ),
                        ),
                      ],
                    )),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    //width: screenSize.width / 100 * 90,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset.zero,
                          color: lightBlack,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Donation",
                          style:
                              TextStyle(fontSize: 22, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Your share is the cause of someone's smile",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Spacer(),
                            GradButton(
                              onPressed: () {
                                // showWorkerModelTest(mycontext, "HLP00005");
                              },
                              child: Text(
                                "Make a donation",
                                style: TextStyle(color: Colors.white),
                              ),
                              width: screenSize.width / 100 * 80 / 3,
                              height: 30,
                              backgroundColor: Appdetails.appBlueColor,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getServiceButton(
      double iconSize, int serviceIndex, String serviceNameWithoutS) {
    Color lightBlack = Color.fromARGB(60, 44, 178, 195);

    return Container(
      child: InkWell(
        onTap: () {
          print(serviceIndex);
          if (serviceIndex == 3) {
            setState(() {
              _cabBikeOverlay = true;
              _deliveryOverlay = false;
            });
          } else if (serviceIndex == 2) {
            setState(() {
              _deliveryOverlay = true;
              _cabBikeOverlay = false;
            });
          } else {
            _cabBikeOverlay = false;
            _deliveryOverlay = false;
            setState(() {});
            onButtonPressed(serviceNameWithoutS);
          }
        },
        child: Column(
          children: [
            Container(
              height: iconSize,
              width: iconSize,
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(80),
                boxShadow: [
                  BoxShadow(
                    color: lightBlack,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Appdetails.serviceLogos[serviceIndex],
            ),
            Text(
              Appdetails.serviceTitles[serviceIndex],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void onButtonPressed(String service) {
    String selected = service;

    Appdetails.lastSelectedService = selected;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchForHelper(
          currentField: selected,
        ),
      ),
    );
  }

   void showWorkerModelTest(BuildContext context, String workerID) async {
    //Getting details
    var worker = await AuthService()
        .firestoreRef
        .collection('helpers')
        .where('myid', isEqualTo: workerID)
        .get();
    //Getting cover image
    var shopcover = worker.docs[0].data()['shopphoto'];
    var rating =
        await AuthService().getMyRating(worker.docs[0].data()["phone"]);
    if (rating.toString().contains("Error")) {
      toast("Error Getting User's Rating");
      rating = "0";
    }

    Image coverImg = Image.asset("assets/images/bubble.png");
    //Before opening worker model we will close loading ui
    //Navigator.pop(context);
    //Open instance of worker model
    //WorkerModel(workerID, worker, context, coverImg, rating);
  }
}
