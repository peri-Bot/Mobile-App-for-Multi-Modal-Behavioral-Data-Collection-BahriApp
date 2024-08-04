

import 'package:firebase_auth/firebase_auth.dart';

class FirebaseLoginServices{
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Some error Occurred");
      return null;
    }
  }

}