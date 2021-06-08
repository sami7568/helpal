import 'dart:async';

import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/helper/helperorders.dart';
import 'package:helpalapp/main.dart';
import 'package:helpalapp/screens/helper/orderreceived.dart';

class TestButtons extends StatefulWidget {
  @override
  _TestButtonsState createState() => _TestButtonsState();
}

class _TestButtonsState extends State<TestButtons> {
  StreamSubscription<String> strm;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () async {
                strm = HelpalStreams().getStatus().listen((event) {
                  if (event != null)
                    print(event);
                  else
                    print("Received Null");
                });
              },
              child: Text("Test"),
              color: Appdetails.appBlueColor,
            ),
            MaterialButton(
              onPressed: () async {
                strm.cancel();
              },
              child: Text("Chk status"),
              color: Appdetails.appBlueColor,
            )
          ],
        ),
      ),
    );
  }
}
