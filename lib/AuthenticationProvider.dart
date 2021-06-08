import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationProvider {
  //Using Stream to listen to Authentication State
  Stream<User> get authState => FirebaseAuth.instance.idTokenChanges();
}
