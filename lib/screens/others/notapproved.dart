import 'package:flutter/material.dart';

class NotApproved extends StatelessWidget {
  final Color color;
  final String title;

  const NotApproved({Key key, this.color, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(
            height: 20,
          ),
          Text(
            "Account approvel in progress",
            style: TextStyle(fontSize: 25),
          ),
        ],
      ),
    );
  }
}
