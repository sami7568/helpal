import 'dart:io';

import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:image_picker/image_picker.dart';

class DryCleanerQuantityTile extends StatefulWidget {
  final String title;
  final Function(File imgFile) onImagePicked;

  const DryCleanerQuantityTile({Key key, this.title, this.onImagePicked})
      : super(key: key);

  @override
  _DryCleanerQuantityTileState createState() => _DryCleanerQuantityTileState();
}

class _DryCleanerQuantityTileState extends State<DryCleanerQuantityTile> {
  ImageProvider defaultImage = Image.asset("assets/images/bubble.png").image;

  File _image;
  final picker = ImagePicker();
  TextStyle headings = TextStyle(fontSize: 22, color: Appdetails.grey6);
  TextStyle buttons = TextStyle(fontSize: 22, color: Colors.white);

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(
        source: imageSource,
        preferredCameraDevice: CameraDevice.rear,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 90);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('Image File :' + pickedFile.path);
        widget.onImagePicked(_image);
        //cropImage();
      } else {
        print('No image selected.');
      }
    });
  }

  showImageOptions(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      color: Colors.red[600],
      child: Text(
        "Cancel",
        style: buttons,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the buttons
    Widget cameraButton = FlatButton(
      color: Appdetails.appBlueColor,
      child: Text(
        "Camera",
        style: buttons,
      ),
      onPressed: () {
        Navigator.pop(context);
        getImage(ImageSource.camera);
      },
    );
    Widget gallaryButton = FlatButton(
      color: Appdetails.appBlueColor,
      child: Text("Gallary", style: buttons),
      onPressed: () {
        Navigator.pop(context);
        getImage(ImageSource.gallery);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Choose image option"),
      content: Text(""),
      actions: [cancelButton, cameraButton, gallaryButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: Text(widget.title, style: headings),
            ),
          ),
          InkWell(
            onTap: () => showImageOptions(context),
            child: Container(
              height: 45,
              width: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                    image: _image == null
                        ? defaultImage
                        : Image.file(_image).image,
                    fit: BoxFit.cover),
              ),
              child: Container(
                height: 20,
                width: 20,
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.add,
                  size: 15,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
