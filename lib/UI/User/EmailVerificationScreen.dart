import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:carecub/UI/User/Login.dart';

import '../BottomNavigationBar.dart';


class EmailVerificationScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;

  const EmailVerificationScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.phone,
  }) : super(key: key);

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  late StreamSubscription<User?> userSubscription;
  Timer? timer;
  bool isVerified = false;

  @override
  void initState() {
    super.initState();

    // Listen to user changes
    userSubscription =
        FirebaseAuth.instance.userChanges().listen((User? currentUser) async {
          if (currentUser != null) {
            await currentUser.reload(); // Reload the user state
            setState(() {
              user = currentUser;
            });

            if (currentUser.emailVerified) {
              isVerified = true;
              await _setUserLoggedIn(); // Save login state locally
              await _storeUserData(); // Store user data in Firestore
              navigateToNextScreen();
            }
          }
        });

    // Stop checking after 3 minutes
    timer = Timer(Duration(minutes: 20), () {
      if (!isVerified) {
        navigateToLoginScreen();
      }
    });
  }

  @override
  void dispose() {
    userSubscription.cancel(); // Cancel the subscription to avoid memory leaks
    timer?.cancel();
    super.dispose();
  }

  // Save login state in SharedPreferences
  Future<void> _setUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  // Store user data in Firestore
  Future<void> _storeUserData() async {
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'name': widget.name,
        'email': widget.email,
        'phone': widget.phone,
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void navigateToNextScreen() {
    if (!isVerified) return; // Ensure navigation happens only once
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Tabs()),
    );
  }
  void navigateToLoginScreen() {
    if (isVerified) return; // Prevent navigating back if already verified
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Image.asset('assets/images/email_verification.png'),
              SizedBox(height: 25),
              Text("Verify Your Email",
                style: TextStyle(
                fontSize: 24,
                  fontWeight: FontWeight.bold
              ),
              ),
              Text(
                'A verification email has been sent to "${user?.email}". Please verify.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18
                )
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                    if (user != null) {
                      await user?.sendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Verification email resent!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(
                        vertical: 10, horizontal: 90),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Resend Email',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18
                    ),
                  )
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey[600],
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "OR Click",
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey[600],
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(
                        vertical: 10, horizontal: 90),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Cancel Request',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18
                    ),
                  )
              ),
            ],
          ),
          ),
        ),
    );
  }
}


