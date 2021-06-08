import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/billing.dart';
import 'package:helpalapp/functions/helpalstreams.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:image_picker/image_picker.dart';

class DisplayPicture extends StatefulWidget {
  final double sizeOfDp;
  final String pictureFor;

  const DisplayPicture(
      {Key key, this.sizeOfDp = 25, this.pictureFor = "helpees"})
      : super(key: key);
  @override
  _DisplayPictureState createState() => _DisplayPictureState();
}

class _DisplayPictureState extends State<DisplayPicture> {
  File _image;
  FirebaseStorage fs = FirebaseStorage.instance;
  Reference lastDp;
  final picker = ImagePicker();
  TextStyle headings = TextStyle(fontSize: 22, color: Appdetails.grey6);
  TextStyle buttons = TextStyle(fontSize: 22, color: Colors.white);

  ImageProvider _userlogo() {
    AssetImage assetImage = AssetImage('assets/images/avatar.png');
    Image image = Image(
      image: Appdetails.myDp == null ? assetImage : Appdetails.myDp.image,
      height: widget.sizeOfDp,
    );
    return image.image;
  }

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(
        source: imageSource,
        preferredCameraDevice: CameraDevice.front,
        maxHeight: 350,
        maxWidth: 350,
        imageQuality: 80);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      String lastPath = await StorageHandler.getDownloadUrl(
          HelpalStreams.prefs.getString(Appdetails.photoidKey),
          UploadTypes.DisplayPicture);
      if (!lastPath.startsWith("Error")) {
        lastDp = fs.refFromURL(lastPath);
        deleteLastDp();
      } else {
        uploadToStorage();
      }
      Appdetails.myDp = Image.file(_image);

      print('Image File :' + pickedFile.path);
      //cropImage();
    } else {
      print('No image selected.');
    }
    setState(() {});
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

  deleteLastDp() async {
    await lastDp.delete();
    uploadToStorage();
  }

  uploadToStorage() async {
    await StorageHandler.upload(_image.path, () async {
      print("dp uploaded");
      String filename = StorageHandler.pathToFilename(_image.path);
      String phone = HelpalStreams.prefs.getString(Appdetails.phoneKey);
      print("updating dp for $phone to $filename");
      await AuthService().updateDocumentField(
          widget.pictureFor, phone, "dpfilename", filename);
      print("dp updated");
      HelpalStreams.prefs.setString(Appdetails.photoidKey, filename);
    }, UploadTypes.DisplayPicture);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        Container(
          child: InkWell(
            onTap: () => showImageOptions(context),
            child: CircleAvatar(
              backgroundImage: _userlogo(),
              maxRadius: widget.sizeOfDp,
            ),
          ),
        ),
        Positioned(
          bottom: widget.sizeOfDp / 20,
          right: widget.sizeOfDp / 20,
          child: InkWell(
            onTap: () => showImageOptions(context),
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: Appdetails.appBlueColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.edit,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
