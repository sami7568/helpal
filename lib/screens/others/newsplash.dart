import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/others/onboardingScreen.dart';
import 'package:helpalapp/screens/others/wrapper.dart';

class NewSplash extends StatefulWidget {
  @override
  _NewSplashState createState() => _NewSplashState();
}

class _NewSplashState extends State<NewSplash> {
  double _logoSize = 80;
  double _height = 0;
  Curve _curve = Curves.bounceOut;
  //Durations
  int _dureationFirstAnimaion = 1000;
  int _dureationLastAnimaion = 800;
  int _durationSlogan = 150; //per Word = 150ms Total 5 words
  int _durationTitle = 800;
  int _durationStay = 3000;
  //helpal style
  int currentLetter = 0;

  TextStyle titleStyleFadeout = new TextStyle(
    fontSize: 75,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
  TextStyle titleStyleFadein = new TextStyle(
    fontSize: 75,
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
    color: Appdetails.appGreenColor,
  );

  bool showHomePage = false;
  bool showTitle = false;
  bool firstAnimationEnd = false;

  @override
  void initState() {
    super.initState();
    print("init called");
    print("First Animation Status = $firstAnimationEnd");
    print("Current heigt =$_height");
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
    //the delay to show logo
    Future.delayed(Duration(milliseconds: _durationStay), () {
      setState(() {
        showHomePage = true;
        showTitle = false;
        _curve = Curves.fastOutSlowIn;
        _height = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //Getting screen size
    Size size = MediaQuery.of(context).size;
    //if animation of logo not ended
    if (!firstAnimationEnd) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _height = size.height / 2;
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
              ? Container(
                  child: Text("Home"),
                )
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
            height: _height,
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
            height: _height,
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
