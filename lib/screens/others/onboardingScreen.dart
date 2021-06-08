import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/others/welcome.dart';

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  PageController _pageController;
  int currentIndex = 0;
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kDurationSkip = const Duration(milliseconds: 600);
  static const _kCurve = Curves.ease;

  Map<int, String> screenTitles = {
    0: "PLUMBING & ELECTRICIAN",
    1: "LAUNDRY & DRYCLEANING",
    2: "DELIVERY SERVICES",
    3: "HELPAL BIKE",
    4: "TAILORS",
    5: "TO HELP YOU ALL",
  };
  Map<int, String> screenDescription = {
    0: "Need Plumbing and Electrician Services?",
    1: "Need to get your Clothes Washed, Ironed and DryCleaned?",
    2: "Want something delivered from one place to another?",
    3: "Are you in a rush and need a quick and affordable bike ride?",
    4: "Need to get your Clothes Stiched?",
    5: "Now you can avail all these services from home by a single tap with\nHelpal",
  };
  Map<int, Image> screenLogos = {
    0: Image.asset('assets/images/services/logo1.png'),
    1: Image.asset('assets/images/services/logo4.png'),
    2: Image.asset('assets/images/services/logo6.png'),
    3: Image.asset('assets/images/services/logo2.png'),
    4: Image.asset('assets/images/services/logo5.png'),
    5: Image.asset(
      'assets/images/services/logo3.png',
      scale: 1.5,
    )
  };
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  onChangedFunction(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  nextFunction() {
    _pageController.nextPage(duration: _kDuration, curve: _kCurve);
  }

  previousFunction() {
    _pageController.previousPage(duration: _kDuration, curve: _kCurve);
  }

  skipToLastPage() {
    _pageController.animateToPage(5, duration: _kDurationSkip, curve: _kCurve);
  }

  doneButtonClick() async {
    Appdetails.isFirstTime = "false";
    await AuthService().saveLocalString(Appdetails.firstTimeKey, "false");
    //pushing welcome screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WelcomeScreen(),
      ),
    );
  }

  //indicator customized
  Widget myIndicator(index) {
    return Container(
      height: 3,
      width: 15,
      color:
          currentIndex == index ? Appdetails.appGreenColor : Colors.grey[350],
    );
  }

  Widget skipButton() {
    return Positioned(
      bottom: 25,
      left: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () => skipToLastPage(),
            child: Text(
              "SKIP",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget doneButton() {
    return Positioned(
      bottom: 25,
      right: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            onTap: () => doneButtonClick(),
            child: Text(
              "DONE",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget onboardingScreen(index, Size screenSize) {
    return Container(
      child: Column(
        children: [
          //Logo
          Container(
            margin: EdgeInsets.only(
                top: screenSize.height / 100 * 10, bottom: index == 5 ? 0 : 0),
            child: screenLogos[index],
          ),
          Container(
            child: index == 5
                ? Container(
                    width: screenSize.width / 100 * 80,
                    margin: EdgeInsets.only(bottom: 15),
                    child: Center(
                      child: Image.asset("assets/images/services/allLogos.png"),
                    ),
                  )
                : SizedBox(height: 0),
          ),
          //center
          Container(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              children: [
                Text(
                  screenTitles[index],
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  screenDescription[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            onPageChanged: onChangedFunction,
            controller: _pageController,
            children: <Widget>[
              onboardingScreen(0, size),
              onboardingScreen(1, size),
              onboardingScreen(2, size),
              onboardingScreen(3, size),
              onboardingScreen(4, size),
              onboardingScreen(5, size),
            ],
          ),
          Container(
            child: currentIndex == 5 ? doneButton() : skipButton(),
          ),
          Positioned(
              bottom: 33,
              left: MediaQuery.of(context).size.width / 2 - 57.5,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      myIndicator(0),
                      SizedBox(width: 5),
                      myIndicator(1),
                      SizedBox(width: 5),
                      myIndicator(2),
                      SizedBox(width: 5),
                      myIndicator(3),
                      SizedBox(width: 5),
                      myIndicator(4),
                      SizedBox(width: 5),
                      myIndicator(5),
                    ],
                  ),
                ),
              )),
          Positioned(
            bottom: 30,
            left: 130,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                child: Row(
                  children: <Widget>[],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
