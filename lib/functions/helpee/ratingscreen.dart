import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/widgets/ShadowText.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class RatingScreen extends StatefulWidget {
  final QueryDocumentSnapshot order;

  const RatingScreen({Key key, this.order}) : super(key: key);

  @override
  _RatingScreenState createState() => _RatingScreenState(order);
}

class _RatingScreenState extends State<RatingScreen> {
  final QueryDocumentSnapshot order;

  _RatingScreenState(this.order);

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

  Widget loading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          CircularProgressIndicator(),
          SizedBox(
            height: 5,
          ),
          Text(
            "Please Wait",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: InkWell(
          onTap: () {
            print("Closed Button");
          },
          child: Container(
            margin: EdgeInsets.only(top: 10, left: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.transparent),
            child: Icon(
              Icons.close,
              color: Colors.grey[800],
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      /* order == null
          ? loading()
          :  */
      body: Container(
        child: Column(
          children: [
            //header
            Container(
              height: size.height / 100 * 30,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset("assets/images/mapdummy.png").image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 5, color: Appdetails.appBlueColor),
                ),
              ),
              height: size.height / 100 * 70,
              width: size.width,
              child: Column(
                children: [
                  Container(
                    child: Transform.translate(
                      offset: Offset(0, -40),
                      child: Column(
                        children: [
                          CircleAvatar(
                            maxRadius: 40,
                            backgroundImage:
                                Image.asset("assets/images/avatar.png").image,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Helper Name",
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            "Plumber",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "Feedback",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => setRatingState(1),
                        child: Icon(
                          Icons.star,
                          size: 40,
                          color: currentStars > 0 ? enableColor : disableColor,
                        ),
                      ),
                      InkWell(
                        onTap: () => setRatingState(2),
                        child: Icon(
                          Icons.star,
                          size: 40,
                          color: currentStars > 1 ? enableColor : disableColor,
                        ),
                      ),
                      InkWell(
                        onTap: () => setRatingState(3),
                        child: Icon(
                          Icons.star,
                          size: 40,
                          color: currentStars > 2 ? enableColor : disableColor,
                        ),
                      ),
                      InkWell(
                        onTap: () => setRatingState(4),
                        child: Icon(
                          Icons.star,
                          size: 40,
                          color: currentStars > 3 ? enableColor : disableColor,
                        ),
                      ),
                      InkWell(
                        onTap: () => setRatingState(5),
                        child: Icon(
                          Icons.star,
                          size: 40,
                          color: currentStars > 4 ? enableColor : disableColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[100],
                          ),
                          child: TextField(
                            keyboardType: TextInputType.name,
                            style: TextStyle(
                              fontSize: 22,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'What needs to be improved?',
                              hintStyle: TextStyle(fontSize: 22),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                            ),
                            maxLines: 4,
                          ),
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.only(bottom: 20, left: 30, right: 30),
                    child: Column(
                      children: [
                        Text(
                          currentText,
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(height: 20),
                        GradButton(
                          width: size.width / 2,
                          onPressed: () async {
                            if (currentStars == 0) {
                              DialogsHelpal.showMsgBox(
                                  "Error",
                                  "Please Select Stars 0-5 or skip The process by selecting close button on left corner",
                                  AlertType.warning,
                                  context,
                                  Appdetails.appGreenColor);
                              return;
                            } else {
                              DialogsHelpal.showLoadingDialog(context, false);
                              dynamic result = await AuthService()
                                  .setRating("+923321535880", currentStars);
                              Navigator.pop(context);
                              if (result == true) {
                                //review posted
                                DialogsHelpal.showMsgBox(
                                    "Success",
                                    "Thank you for your feedback",
                                    AlertType.success,
                                    context,
                                    Appdetails.appGreenColor);
                              } else {
                                //error
                                DialogsHelpal.showMsgBox(
                                    "Error",
                                    result,
                                    AlertType.success,
                                    context,
                                    Appdetails.appGreenColor);
                              }
                            }
                          },
                          backgroundColor: Appdetails.appBlueColor,
                          child: ShadowText(
                            text: "Post Review",
                            fontColor: Colors.white,
                            shadowColor: Colors.black45,
                            shadowBlur: 5,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
