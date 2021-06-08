import 'package:firebase_database/firebase_database.dart';
import 'package:helpalapp/functions/locationmanager.dart';

class NearbyWorkers {
  final ref = FirebaseDatabase.instance;
  //final AuthService _auth = AuthService();

  static bool _isDbSynced = false;
  static bool _serviceEnabled;

  static bool _permissionGranted;

  void initDatabase(Function callBack) async {
    if (_isDbSynced) return;
    print('Nearby Worker Database Update Request Received');
    _permissionGranted = await LocationManager.isPermissionGranted();
    if (_permissionGranted == false) {
      _permissionGranted = await LocationManager.requestPermission();
      if (_permissionGranted == false) {
        return;
      }
    }

    _serviceEnabled = await LocationManager.isServiceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await LocationManager.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    ref.reference().child('onlineworkers').onChildChanged.listen((event) {
      callBack();
    });
    ref.reference().child('onlineworkers').onChildAdded.listen((event) {
      callBack();
    });
    _isDbSynced = true;
    print('Nearby Worker Database Update Request Approved');
  }

  Future<void> disposeRef() async {
    print("Online worker sync cancelled");
    _isDbSynced = false;
    await ref.reference().child('onlineworkers').onChildChanged.listen((event) {
      return;
    }).cancel();

    await ref.reference().child('onlineworkers').onChildAdded.listen((e) {
      return;
    }).cancel();
  }
}
