import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Database/DatabaseServices.dart';
import '../../UI/BottomNavigationBar.dart';

Future<void> SignInWithGoogle(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final User? user = await BackendService.signInWithGoogle();
    if (user != null) {
      await DatabaseService.updateUserData(
        uid: user.uid,
        name: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
      );

      // Check if this is a new user
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Store login state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      Navigator.pop(context); // Remove loading dialog

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Tabs(),
        ),
      );

      // Show different message for new vs existing users
      if (!doc.exists) {
        showToast(message: "Welcome new user!");
      } else {
        showToast(message: "Welcome back!");
      }
    }
  } catch (e) {
    Navigator.pop(context);
    showToast(message: "Please check your network connections");
  }
}

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
class BackendService {
  static Future<User?> registerUser(String email, String password) async {
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw e; // Re-throw for error handling in UI
    }
  }

  static Future<void> sendVerificationEmail(User user) async {
    await user.sendEmailVerification();
  }
  // Add to BackendService class
  static Future<User?> signInWithGoogle() async {
  try {
  final GoogleSignInAccount? googleAccount = await GoogleSignIn().signIn();
  if (googleAccount == null) return null;

  final GoogleSignInAuthentication googleAuth =
  await googleAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
  idToken: googleAuth.idToken,
  accessToken: googleAuth.accessToken,
  );

  final UserCredential authResult =
  await FirebaseAuth.instance.signInWithCredential(credential);
  return authResult.user;
  } catch (e) {
  throw e;
  }
  }
}


