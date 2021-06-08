import 'dart:io';

import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/helpee/tailorslisttile.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/widgets/ShadowText.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class NewOrderTailorsAddItem extends StatefulWidget {
  @override
  _NewOrderTailorsAddItemState createState() => _NewOrderTailorsAddItemState();
}

class _NewOrderTailorsAddItemState extends State<NewOrderTailorsAddItem> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  BuildContext mycontext;
  TextStyle headingStyle() => TextStyle(color: Colors.grey[800], fontSize: 25);
  Color fieldsBgColor() => Appdetails.appBlueColor.withAlpha(40);

  String _clothTitle = "";
  String _clothesMaterial = 'Select Clothing Material';
  String _typeOfStitching = 'Select Stitching Type';
  String _stitchingQuality = 'Select Stitching Quality';
  //image picker
  final picker = ImagePicker();
  File _clothphoto;
  File _clothphoto2;
  File _sampleclothphoto;
  bool sampledressAdded = false;
  Image defaultClothPhoto = Image.asset("assets/images/bubble.png");

  getClothesTitle(double screenWidth) {
    return Container(
      width: screenWidth,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 6),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: fieldsBgColor()),
      child: TextField(
        onChanged: (value) {
          _clothTitle = value;
        },
        style: TextStyle(
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.normal,
            fontSize: 22,
            color: Colors.grey[600]),
        decoration: InputDecoration(
          hintStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.normal,
            fontSize: 22,
          ),
          hintText: "Order Title",
          border: InputBorder.none,
          prefixIcon: Padding(
            child: IconTheme(
              data: IconThemeData(color: Appdetails.appBlueColor),
              child: Icon(Icons.border_color),
            ),
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 3.5),
          ),
        ),
      ),
    );
  }

  getClothesMaterial(double screenWidth) {
    return Container(
      width: screenWidth,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: fieldsBgColor()),
      child: DropdownButton<String>(
        dropdownColor: Colors.grey[200],
        value: _clothesMaterial,
        icon: Icon(Icons.keyboard_arrow_down, size: 25),
        iconSize: 16,
        elevation: 5,
        isExpanded: true,
        underline: SizedBox(
          height: 0,
        ),
        style: TextStyle(color: Colors.grey[600], fontSize: 15),
        onChanged: (String newValue) {
          setState(() {
            _clothesMaterial = newValue;
          });
        },
        items: Appdetails.clothesMaterial
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(fontSize: 22, color: Colors.grey[600]),
            ),
          );
        }).toList(),
      ),
    );
  }

  getStitchingType(double screenWidth) {
    return Container(
      width: screenWidth,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: fieldsBgColor()),
      child: DropdownButton<String>(
        dropdownColor: Colors.grey[200],
        value: _typeOfStitching,
        icon: Icon(Icons.keyboard_arrow_down, size: 25),
        iconSize: 16,
        elevation: 5,
        isExpanded: true,
        underline: SizedBox(
          height: 0,
        ),
        style: TextStyle(color: Colors.grey[600], fontSize: 15),
        onChanged: (String newValue) {
          setState(() {
            _typeOfStitching = newValue;
          });
        },
        items: Appdetails.stitchingType
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(fontSize: 22, color: Colors.grey[600]),
            ),
          );
        }).toList(),
      ),
    );
  }

  getStitchingQuality(double screenWidth) {
    return Container(
      width: screenWidth,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: fieldsBgColor()),
      child: DropdownButton<String>(
        dropdownColor: Colors.grey[200],
        value: _stitchingQuality,
        icon: Icon(Icons.keyboard_arrow_down, size: 25),
        iconSize: 16,
        elevation: 5,
        isExpanded: true,
        underline: SizedBox(
          height: 0,
        ),
        style: TextStyle(color: Colors.grey[600], fontSize: 15),
        onChanged: (String newValue) {
          setState(() {
            _stitchingQuality = newValue;
          });
        },
        items: Appdetails.stitchingQuality
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(fontSize: 22, color: Colors.grey[600]),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future getImage(ImageSource imageSource, double maxHeight, double maxWidth,
      int quality, CameraDevice camera, String fileName) async {
    final pickedFile = await picker.getImage(
        source: imageSource,
        preferredCameraDevice: camera,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        imageQuality: quality);

    setState(() {
      if (pickedFile != null) {
        switch (fileName) {
          case "_clothphoto":
            _clothphoto = File(pickedFile.path);
            break;
          case "_clothphoto2":
            _clothphoto2 = File(pickedFile.path);
            break;
          case "_sampleclothphoto":
            _sampleclothphoto = File(pickedFile.path);
            break;
        }

        print('Image File :' + pickedFile.path);
        //cropImage();
      } else {
        print('No image selected.');
      }
    });
  }

  getClothPhotoField(double width) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Clothing Media",
            style: headingStyle(),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _clothphoto == null
                          ? defaultClothPhoto.image
                          : Image.file(_clothphoto).image,
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Appdetails.appBlueColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: InkWell(
                      onTap: () => Appdetails.getImageViaOptions(
                          _scaffoldKey,
                          getImage,
                          800,
                          1280,
                          80,
                          CameraDevice.rear,
                          "_clothphoto"),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Container(
                  height: 100,
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _clothphoto2 == null
                          ? defaultClothPhoto.image
                          : Image.file(_clothphoto2).image,
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Appdetails.appBlueColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: InkWell(
                      onTap: () => Appdetails.getImageViaOptions(
                          _scaffoldKey,
                          getImage,
                          800,
                          1280,
                          80,
                          CameraDevice.rear,
                          "_clothphoto2"),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  getSampleDress(double width) {
    return Container(
      child: InkWell(
        onTap: () {
          if (sampledressAdded)
            sampledressAdded = false;
          else
            sampledressAdded = true;
          setState(() {});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Sample Dress Added",
                  style: headingStyle(),
                ),
                Container(
                  child: Checkbox(
                    activeColor: Appdetails.appBlueColor,
                    value: sampledressAdded,
                    onChanged: (val) {
                      setState(() {
                        sampledressAdded = val;
                      });
                    },
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: Offset(0, -10),
              child: Text(
                "Must add a sample dress for measurement",
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    mycontext = context;
    //Getting screen height
    final height = MediaQuery.of(context).size.height;
    //Getting screen height
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: false,
      //resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Center(
          child: Container(
            margin: EdgeInsets.only(right: 50),
            child: ShadowText(
              text: "create order".toUpperCase(),
              fontColor: Colors.grey[600],
              fontSize: 26,
              shadowColor: Colors.black.withAlpha(0),
              shadowBlur: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.grey[600],
            ),
            onPressed: () {
              //back button
              Navigator.pop(context);
            }),
      ),

      //Body
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            //Text Fields Scrollable on focus
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    getClothesTitle(width),
                    SizedBox(height: 15),
                    getClothesMaterial(width),
                    SizedBox(height: 15),
                    getStitchingType(width),
                    SizedBox(height: 15),
                    getStitchingQuality(width),
                    SizedBox(height: 15),
                    getClothPhotoField(width),
                    SizedBox(height: 15),
                    getSampleDress(width)
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              child: sampledressAdded
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Appdetails.appBlueColor.withAlpha(150),
                                offset: Offset.zero,
                                blurRadius: 3,
                              )
                            ]),
                        child: GradButton(
                          onPressed: () {
                            Appdetails.getImageViaOptions(
                                _scaffoldKey,
                                getImage,
                                512,
                                512,
                                95,
                                CameraDevice.rear,
                                "_sampleclothphoto");
                          },
                          backgroundColor: Colors.white,
                          width: width / 100 * 90,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.add_circle,
                                  size: 30,
                                  color: Appdetails.appBlueColor,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  ' Add Sample Dress Media',
                                  style: TextStyle(
                                      color: Appdetails.appBlueColor,
                                      fontSize: 22),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 6),
                                width: 60,
                                height: 40,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: _sampleclothphoto == null
                                        ? defaultClothPhoto.image
                                        : Image.file(_sampleclothphoto).image,
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                      color: Appdetails.appBlueColor),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SizedBox(height: 5),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(bottom: 20),
              child: GradButton(
                onPressed: () {
                  if (_clothTitle == "" ||
                      _clothesMaterial.startsWith("Select") ||
                      _typeOfStitching.startsWith("Select") ||
                      _stitchingQuality.startsWith("Select") ||
                      _clothphoto == null ||
                      _clothphoto2 == null ||
                      sampledressAdded == false ||
                      _sampleclothphoto == null) {
                    DialogsHelpal.showMsgBox(
                        "Error",
                        "Please check details carefully and try again",
                        AlertType.error,
                        context,
                        Appdetails.appBlueColor);
                    return;
                  }
                  //return result
                  dynamic result = TailorListTile(
                    title: _clothTitle,
                    imgFile: _clothphoto,
                    imgFile2: _clothphoto2,
                    imgSampleDress: _sampleclothphoto,
                    clothingMaterial: _clothesMaterial,
                    stitchingType: _typeOfStitching,
                    stitchingQuality: _stitchingQuality,
                    onRemoved: (index) {},
                  );
                  Navigator.pop(context, result);
                },
                backgroundColor: Appdetails.appBlueColor,
                width: width / 2,
                child: Text(
                  'Add to Basket',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
