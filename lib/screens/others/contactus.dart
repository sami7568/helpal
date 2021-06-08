import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:helpalapp/widgets/ShadowText.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:helpalapp/functions/appdetails.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  String _field = 'Select Service';
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _myDivider() {
    AssetImage assetImage = AssetImage('assets/images/divider.png');
    Image image = Image(
      image: assetImage,
      height: 15,
    );
    return image;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = (MediaQuery.of(context).size.height);
    double screenWidth = (MediaQuery.of(context).size.width);

    return Scaffold(
      extendBodyBehindAppBar: true,
     // resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(right: 50),
            child: Text(
              'CONTACT US',
              style: TextStyle(
                fontSize: 18,
              ),
            )),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      //Body
      body: Container(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight / 100 * 20,
              color: Appdetails.appGreenColor,
              child: (Column(
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  ShadowText(
                    text: 'PLEASE PROVIDE REQUIRED DETAILS',
                    fontColor: Colors.grey[600],
                    shadowColor: Appdetails.appGreenColor,
                    shadowBlur: 1,
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ],
              )),
            ),
            //2NDROW
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: screenWidth / 100 * 80,
                    child: DropdownButton<String>(
                      value: _field,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 16,
                      elevation: 5,
                      isExpanded: true,
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      underline: Container(
                        height: 2,
                        color: Appdetails.appGreenColor,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          _field = newValue;
                        });
                      },
                      items: <String>[
                        'Select Service',
                        'Account',
                        'Wallet',
                        'Complain',
                        'Information'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: screenWidth / 100 * 80,
                    //color: Colors.greenAccent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explain your problem',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        SizedBox(height: 5),
                        Container(
                          color: Colors.grey[200],
                          child: TextField(
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              hintText:
                                  'If you are having a problem with the app.',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                            ),
                            maxLines: 8,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Container(
              height: 150,
              padding: EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GradButton(
                    height: 40,
                    width: screenWidth / 2,
                    child: Text(
                      'Submit Complaint',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                      } else {}
                    },
                  ),
                  Text(
                    "Terms of Use",
                    style: TextStyle(fontSize: 22),
                  ),
                  Text(
                    "FAQ",
                    style: TextStyle(fontSize: 22),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
