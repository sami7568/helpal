import 'dart:io';

import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';

class TailorListTile extends StatefulWidget {
  final String title;
  final String clothingMaterial;
  final String stitchingType;
  final String stitchingQuality;
  final File imgFile;
  final File imgFile2;
  final File imgSampleDress;
  final int number;
  final Function(int index) onRemoved;

  const TailorListTile(
      {Key key,
      this.title,
      this.imgFile,
      this.number = 0,
      this.onRemoved,
      this.clothingMaterial,
      this.stitchingType,
      this.stitchingQuality,
      this.imgFile2,
      this.imgSampleDress})
      : super(key: key);

  @override
  _TailorListTileState createState() => _TailorListTileState();
}

class _TailorListTileState extends State<TailorListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
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
              padding: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //title
                  Text(
                    widget.title.capitalizeFirstofEach,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700], fontSize: 26),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Fabric: " + widget.clothingMaterial,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                  Text(
                    "Type: " + widget.stitchingType,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                  Text(
                    "Stitch: " + widget.stitchingQuality,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                  Row(
                    children: [
                      Text(
                        "Sample Dress",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 20),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.check_box,
                        color: Appdetails.appBlueColor,
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          Container(
            width: 55,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 50,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: widget.imgFile == null
                            ? Image.asset("assets/images/bubble.png")
                            : Image.file(widget.imgFile).image,
                        fit: BoxFit.cover),
                  ),
                ),
                //image 2
                Container(
                  width: 50,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: widget.imgFile2 == null
                            ? Image.asset("assets/images/bubble.png")
                            : Image.file(widget.imgFile2).image,
                        fit: BoxFit.cover),
                  ),
                ),
                //sample dress img
                Container(
                  width: 50,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: widget.imgSampleDress == null
                            ? Image.asset("assets/images/bubble.png")
                            : Image.file(widget.imgSampleDress).image,
                        fit: BoxFit.cover),
                  ),
                ),
              ],
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
