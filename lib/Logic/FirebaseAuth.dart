import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../UI/Home.dart';

SignInWithGoogle(BuildContext context) async {
  bool _isLoading = true; // Initialize loading state

  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

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

      if (user != null) {
        // Get user details
        String? name = user.displayName;
        String? email = user.email;
        String? photoUrl = user.photoURL;

        // Save user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name ?? 'No Name',
          'email': email ?? 'No Email',
          'photoUrl': photoUrl ?? '',
        }, SetOptions(merge: true));  // Merge to avoid overwriting existing data
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        // After the process completes, hide the loading indicator
        Navigator.pop(context);  // Dismiss the loading dialog

        // Navigate to Home with user details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(
              // Pass the user data to Home screen
              // userName: name ?? "Guest",
              // userEmail: email ?? "No Email",
              // userPhoto: photoUrl,
            ),
          ),
        );
      }
    }
  } catch (e) {
    // Hide the loading indicator in case of error
    Navigator.pop(context);
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
