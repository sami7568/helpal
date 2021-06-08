import 'package:flutter/material.dart';

class NotAvailable extends StatelessWidget {
  final Color color;
  final String title;

  const NotAvailable({Key key, this.color, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.not_interested,
            size: 50,
            color: this.color,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            this.title,
            style: TextStyle(fontSize: 25),
          ),
        ],
      ),
    );
  }
}
