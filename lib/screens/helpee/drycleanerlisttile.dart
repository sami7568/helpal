import 'dart:io';

import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';

class DrycleanerListTile extends StatefulWidget {
  final String title;
  final File imgFile;
  final int number;
  final Function(int index) onRemoved;
  final double price;

  const DrycleanerListTile(
      {Key key,
      this.title,
      this.imgFile,
      this.number = 0,
      this.onRemoved,
      this.price})
      : super(key: key);

  @override
  _DrycleanerListTileState createState() => _DrycleanerListTileState();
}

class _DrycleanerListTileState extends State<DrycleanerListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Appdetails.appBlueColorWithAlpha,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.number.toString(),
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10),
              child: Text(
                widget.title,
                style: TextStyle(color: Colors.grey[600], fontSize: 18),
              ),
            ),
          ),
          Container(
            width: 50,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                  image: widget.imgFile == null
                      ? Image.asset("assets/images/bubble.png")
                      : Image.file(widget.imgFile).image,
                  fit: BoxFit.cover),
            ),
          ),
          Container(
            width: 60,
            child: InkWell(
              onTap: () {
                widget.onRemoved(widget.number - 1);
              },
              child: Icon(
                Icons.close,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
