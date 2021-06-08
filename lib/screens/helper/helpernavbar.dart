import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/helper/helperdashboard.dart';
import 'package:helpalapp/screens/helper/helperrecents.dart';
import 'package:helpalapp/screens/helper/helpersettings.dart';
import 'package:helpalapp/screens/helper/neworderslist.dart';

class HelperBottomNavbar {
  BoxDecoration menuDecoration = new BoxDecoration(
    color: Colors.white,
    border: Border(right: BorderSide(color: Colors.grey[400])),
  );

  //static const _kDuration = const Duration(milliseconds: 300);
  //static const _kCurve = Curves.ease;

  getnewnavbar(BuildContext context, int currentIndex) {
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
                onTap: () => Appdetails.loadScreen(context, HelperDash()),
                child: Icon(
                  Icons.home,
                  color: currentIndex == 0
                      ? Appdetails.appGreenColor
                      : Appdetails.grey4,
                ),
              ),
            ),
            Container(
              width: size.width / 3,
              decoration: menuDecoration,
              child: InkWell(
                onTap: () async {
                  String workerid =
                      await AuthService().getLocalString(Appdetails.myidKey);
                  Appdetails.loadScreen(
                    context,
                    HelperRecents(
                      workerId: workerid,
                    ),
                  );
                },
                child: Icon(
                  Icons.history,
                  color: currentIndex == 1
                      ? Appdetails.appGreenColor
                      : Appdetails.grey4,
                ),
              ),
            ),
            Container(
              width: size.width / 3,
              child: InkWell(
                onTap: () => Appdetails.loadScreen(context, HelperSettings()),
                child: Icon(
                  Icons.settings,
                  color: currentIndex == 2
                      ? Appdetails.appGreenColor
                      : Appdetails.grey4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
