import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/others/onboardingScreen.dart';
import 'package:helpalapp/screens/others/wrapper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _logoSize = 80;
  double _heightTop = 0;
  double _heightBottom = 0;
  Curve _curve = Curves.bounceOut;
  //Durations
  int _dureationFirstAnimaion = 1000;
  int _dureationLastAnimaion = 600;
  int _durationSlogan = 150; //per Word = 300ms Total 5 words
  int _durationTitle = 800;
  int _durationStay = 3000;
  //helpal style
  int currentLetter = 0;

  TextStyle titleStyleFadeout = new TextStyle(
    fontFamily: "Montserrat",
    fontSize: 60,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
  TextStyle titleStyleFadein = new TextStyle(
    fontFamily: "Montserrat",
    fontSize: 60,
    color: Colors.grey[500],
    fontWeight: FontWeight.bold,
  );
  //Slogan
  TextStyle sloganFadeout = new TextStyle(
    fontSize: 30,
    color: Colors.white,
  );
  TextStyle sloganFadein = new TextStyle(
    fontSize: 30,
    color: Colors.grey,
  );

  bool showHomePage = false;
  bool showTitle = false;
  bool firstAnimationEnd = false;

  //Context
  BuildContext mycontext;

  @override
  void initState() {
    super.initState();
    print("init called");
  }

  @override
  void dispose() {
    super.dispose();
    print("Dispose Called");
  }

  Image logoTop() {
    AssetImage assetImage = AssetImage('assets/images/logoTop.png');
    Image image = Image(
      image: assetImage,
      height: _logoSize + 2,
    );
    return image;
  }

  Image logoBottom() {
    AssetImage assetImage = AssetImage('assets/images/logoBottom.png');
    Image image = Image(
      image: assetImage,
      height: _logoSize,
    );
    return image;
  }

  void firstAnimationCompleted() {
    setState(() {
      firstAnimationEnd = true;
      showTitle = true;
    });
    Future.delayed(Duration(milliseconds: 300), () {
      //Activate 1st
      Future.delayed(Duration(milliseconds: 300), () {});
    });
    //the delay to show logo
    Future.delayed(Duration(milliseconds: _durationStay), () {
      setState(() {
        showHomePage = true;
        showTitle = false;
        _curve = Curves.fastOutSlowIn;
        _heightTop = 0;
        _heightBottom = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mycontext = context;
    //Getting screen size
    Size size = MediaQuery.of(context).size;
    //if animation of logo not ended
    if (!firstAnimationEnd) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _heightTop = size.height / 100 * 35;
          _heightBottom = size.height / 100 * 65;
        });
      });
    }
    return Stack(
      children: [
        Container(
          height: size.height,
          width: size.width,
          color: Colors.white,
        ),
        Align(
          alignment: Alignment.center,
          child: showHomePage
              ? Appdetails.isFirstTime == "true" ? OnBoarding() : Wrapper()
              : SizedBox(height: 0),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: AnimatedContainer(
            alignment: Alignment.bottomCenter,
            duration: Duration(
                milliseconds: firstAnimationEnd
                    ? _dureationLastAnimaion
                    : _dureationFirstAnimaion),
            curve: _curve,
            color: Colors.transparent,
            height: _heightTop,
            width: size.width,
            onEnd: () => firstAnimationCompleted(),
            child: Transform.translate(
              offset: Offset(0, 10),
              child: logoTop(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            alignment: Alignment.topCenter,
            duration: Duration(
                milliseconds: firstAnimationEnd
                    ? _dureationLastAnimaion
                    : _dureationFirstAnimaion),
            curve: _curve,
            color: Colors.transparent,
            height: _heightBottom,
            width: size.width,
            onEnd: () {
              Future.delayed(Duration(milliseconds: 50), () {
                setState(() {
                  currentLetter = 1;
                });
              });
            },
            child: showTitle
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: Offset(0, -10),
                        child: logoBottom(),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedDefaultTextStyle(
                            child: Text("Helpal"),
                            style: currentLetter > 0
                                ? titleStyleFadein
                                : titleStyleFadeout,
                            onEnd: () {
                              print('Title Animation Completed');
                              setState(() {
                                currentLetter = 2;
                              });
                            },
                            duration: Duration(milliseconds: _durationTitle),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedDefaultTextStyle(
                            child: Text("All "),
                            style: currentLetter > 1
                                ? sloganFadein
                                : sloganFadeout,
                            onEnd: () {
                              setState(() {
                                currentLetter = 3;
                              });
                            },
                            duration: Duration(milliseconds: _durationSlogan),
                          ),
                          AnimatedDefaultTextStyle(
                            child: Text("The "),
                            style: currentLetter > 2
                                ? sloganFadein
                                : sloganFadeout,
                            onEnd: () {
                              setState(() {
                                currentLetter = 4;
                              });
                            },
                            duration: Duration(milliseconds: _durationSlogan),
                          ),
                          AnimatedDefaultTextStyle(
                            child: Text("Help "),
                            style: currentLetter > 3
                                ? sloganFadein
                                : sloganFadeout,
                            onEnd: () {
                              setState(() {
                                currentLetter = 5;
                              });
                            },
                            duration: Duration(milliseconds: _durationSlogan),
                          ),
                          AnimatedDefaultTextStyle(
                            child: Text("You "),
                            style: currentLetter > 4
                                ? sloganFadein
                                : sloganFadeout,
                            onEnd: () {
                              setState(() {
                                currentLetter = 6;
                              });
                            },
                            duration: Duration(milliseconds: _durationSlogan),
                          ),
                          AnimatedDefaultTextStyle(
                            child: Text("Need"),
                            style: currentLetter > 5
                                ? sloganFadein
                                : sloganFadeout,
                            duration: Duration(milliseconds: _durationSlogan),
                          ),
                        ],
                      ),
                    ],
                  )
                : Transform.translate(
                    offset: Offset(0, -10),
                    child: logoBottom(),
                  ),
          ),
        ),
      ],
    );
  }
}
