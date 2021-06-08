import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:helpalapp/widgets/ShadowText.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:helpalapp/functions/appdetails.dart';

class OrderReceived extends StatefulWidget {
  @override
  _OrderReceivedState createState() => _OrderReceivedState();
}

class _OrderReceivedState extends State<OrderReceived>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  //String _field = 'Choose a address';
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Widget _myDivider() {
    AssetImage assetImage = AssetImage('assets/images/divider.png');
    Image image = Image(
      image: assetImage,
      height: 15,
    );
    return image;
  }

  Widget _playIcon() {
    AssetImage assetImage = AssetImage('assets/images/play.png');
    Image image = Image(
      image: assetImage,
      height: 30,
    );
    return image;
  }

  Widget _stopIcon() {
    AssetImage assetImage = AssetImage('assets/images/stopred.png');
    Image image = Image(
      image: assetImage,
      height: 30,
    );
    return image;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = (MediaQuery.of(context).size.height);
    double screenWidth = (MediaQuery.of(context).size.width);

    return Scaffold(
      extendBodyBehindAppBar: true,
      //resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(right: 50),
            child: Text(
              'HIRE WORKER',
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
            Row(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight / 3.8,
                  color: Appdetails.appGreenColor,
                  child: (Column(
                    children: [
                      SizedBox(
                        height: 70,
                      ),
                      _myDivider(),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ShadowText(
                        text: 'PLEASE CHECK DETAILS BELOW',
                        fontColor: Colors.white,
                        shadowColor: Colors.black38,
                        shadowBlur: 20,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ],
                  )),
                )
              ],
            ),
            //2NDROW
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                            color: Colors.grey[200],
                            width: screenWidth / 100 * 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: screenWidth / 100 * 70,
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(left: 10),
                                  height: 35,
                                  child: Text('G11 House 15'),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  child: Icon(Icons.arrow_right),
                                  onTap: () {
                                    //showDialog('G11 House 15G11 House 15G11 House 15G11 House 15');
                                  },
                                ),
                              ],
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        //voicenote
                        Container(
                          width: screenWidth / 100 * 80,
                          //color: Colors.greenAccent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Voice Note',
                                style: TextStyle(
                                    color: Appdetails.grey3, fontSize: 14),
                              ),
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  color: Colors.grey[200],
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        child: _playIcon(),
                                        onTap: () {
                                          //Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUsPage()));
                                        },
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      InkWell(
                                        child: _stopIcon(),
                                        onTap: () {
                                          //Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUsPage()));
                                        },
                                      ),
                                      SizedBox(
                                        width: 60,
                                      ),
                                      Text(
                                        '00:00:18',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 35,
                                      ),
                                    ],
                                  ))
                            ],
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
                                'Comment',
                                style: TextStyle(
                                    color: Appdetails.grey3, fontSize: 14),
                              ),
                              Container(
                                color: Colors.grey[200],
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 20),
                                  ),
                                  maxLines: 3,
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: screenWidth / 100 * 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                color: Colors.grey[200],
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '03005065060',
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(
                                height: 50,
                              ),
                              Center(
                                  child: Column(
                                children: [
                                  GradButton(
                                    height: 40,
                                    width: screenWidth / 2,
                                    child: Text(
                                      'Accept',
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
                                ],
                              ))
                            ],
                          ),
                        ),
                      ],
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
