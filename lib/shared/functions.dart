import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn {
  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
      // TODO
      print('exception->$e');
    }
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  static Future<void> saveUserData(String username, String email) async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');

    // Check if username already exists
    final duplicateUsername =
        await users.where('username', isEqualTo: username).get();
    if (duplicateUsername.docs.isEmpty) {
      // Username doesn't exist, save user data
      await users.add({
        'username': username,
        'email': email,
        // Add other fields as needed
      });
    } else {
      // Username already exists
      throw Exception('Username or email already exists');
    }
  }
}
