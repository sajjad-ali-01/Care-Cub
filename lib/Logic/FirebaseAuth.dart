import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../UI/Home.dart';

SignInWithGoogle(BuildContext context) async {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  try {
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      // Authenticate with Google
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      // Get user details
      String? name = user?.displayName;
      String? email = user?.email;
      String? photoUrl = user?.photoURL;

      // Navigate to Home with user details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Home(
            // userName: name ?? "Guest",
            // userEmail: email ?? "No Email",
            // userPhoto: photoUrl,
          ),
        ),
      );
    }
  } catch (e) {
    showToast(message: "Some error occurred: $e");
  }
}

// Show toast function
void showToast({required String message}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
