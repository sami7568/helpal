import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';

class HelpeeBottomNavbar {
  BoxDecoration menuDecoration = new BoxDecoration(
    color: Colors.white,
    border: Border(right: BorderSide(color: Colors.grey[400])),
  );

  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;
  getnewnavbar(
      BuildContext context, int currentIndex, PageController pageController) {
    Size size = MediaQuery.of(context).size;
    return BottomAppBar(
      child: Container(
        height: 50,
        child: Row(
          children: [
            Container(
              width: size.width / 3,
              decoration: menuDecoration,
              child: InkWell(
                onTap: () => pageController.animateToPage(0,
                    duration: _kDuration, curve: _kCurve),
                child: Icon(
                  Icons.home,
                  color: currentIndex == 0
                      ? Appdetails.appBlueColor
                      : Colors.grey[600],
                ),
              ),
            ),
            Container(
              width: size.width / 3,
              decoration: menuDecoration,
              child: InkWell(
                onTap: () => pageController.animateToPage(1,
                    duration: _kDuration, curve: _kCurve),
                child: Icon(
                  Icons.history,
                  color: currentIndex == 1
                      ? Appdetails.appBlueColor
                      : Colors.grey[600],
                ),
              ),
            ),
            Container(
              width: size.width / 3,
              child: InkWell(
                onTap: () => pageController.animateToPage(2,
                    duration: _kDuration, curve: _kCurve),
                child: Icon(
                  Icons.settings,
                  color: currentIndex == 2
                      ? Appdetails.appBlueColor
                      : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
