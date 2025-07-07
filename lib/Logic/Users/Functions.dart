import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../UI/BottomNavigationBar.dart';
import '../../UI/User/ChildDetailsScreen.dart';

Future<void> SignInWithGoogle(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final User? user = await BackendService.signInWithGoogle();
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();

      // Check if user document exists
      if (!docSnapshot.exists) {
        await docRef.set({
          'name': user.displayName,
          'email': user.email,
          'photoUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BabyProfileScreen(),
          ),
        );
        showToast(message: "Welcome! Please enter child details.");
      } else {
        // Check if baby profile exists
        final babyProfileSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('babyProfiles')
            .limit(1)
            .get();

        Navigator.pop(context);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        if (babyProfileSnapshot.docs.isEmpty) {
          // No baby profile exists
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BabyProfileScreen(),
            ),
          );
          showToast(message: "Please complete your child's profile");
        } else {
          // Baby profile exists
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Tabs()),
                (Route<dynamic> route) => false,
          );
          showToast(message: "Welcome back!");
        }
      }
    }
  } catch (e) {
    Navigator.pop(context);
    showToast(message: "Please check your network connection");
    debugPrint("Google Sign-In Error: $e");
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
      throw e;
    }
  }

  static Future<void> sendVerificationEmail(User user) async {
    await user.sendEmailVerification();
  }

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


