import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:path/path.dart';

class StorageHandler {
  static getDownloadUrl(String fileName, UploadTypes fileType) async {
    //Getting basic path
    String basicPath = getPath(fileType);

    try {
      String downloadURL = await FirebaseStorage.instance
          .ref()
          .child("$basicPath/$fileName")
          .getDownloadURL();
      return downloadURL;
    } catch (e) {
      return "Error:\n" + e.toString();
    }
  }

  //Call this from other to upload the file
  static Future<dynamic> upload(
      String filePath, Function callback, UploadTypes type) async {
    //Getting basic path
    String basicpath = getPath(type);
    //Creating file from path
    File _voiceNote = File(filePath);
    //getting filename only
    String fileName = basename(_voiceNote.path);
    //Putting filepath into reference
    Reference fbStorageRef =
        FirebaseStorage.instance.ref().child("$basicpath/$fileName");
    //Sending file to firebase storage
    UploadTask uploadTask = fbStorageRef.putFile(_voiceNote);
    //receving callback when file uploaded
    await uploadTask.whenComplete(() => callback());
  }

  static String getPath(UploadTypes type) {
    String basicPath = '';
    if (type == UploadTypes.DisplayPicture)
      basicPath = 'dps';
    else if (type == UploadTypes.Covers)
      basicPath = "covers";
    else if (type == UploadTypes.Cnic)
      basicPath = "cnic";
    else if (type == UploadTypes.VehicleReg)
      basicPath = "vehiclereg";
    else if (type == UploadTypes.License)
      basicPath = "licenses";
    else if (type == UploadTypes.ServicesImgs)
      basicPath = "servicesimgs";
    else
      basicPath = 'voicenotes';

    return basicPath;
  }

  static String pathToFilename(String path) {
    String fileName = basename(path);
    return fileName;
  }
}
