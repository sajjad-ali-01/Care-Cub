import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:carecub/UI/User/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Database/DatabaseServices.dart';
import '../../Logic/Users/User_Deletion.dart';
import 'ChildDetailsScreen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  late User? user;
  final String password;

  EmailVerificationScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.phone,
    required this.user,
    required this.password,
  }) : super(key: key);

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late StreamSubscription<User?> userSubscription;
  Timer? timer;
  bool isVerified = false;
  bool isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();

    userSubscription =
        FirebaseAuth.instance.userChanges().listen((User? currentUser) async {
          if (currentUser != null) {
            await currentUser.reload();
            setState(() {
              widget.user = currentUser;
            });

            if (currentUser.emailVerified) {
              setState(() {
                isLoading = true; // Start loading
              });

              // Save user data to Firestore
              await DatabaseService.saveUserData(
                uid: widget.user!.uid,
                name: widget.name,
                email: widget.email,
                phone: widget.phone,
              );

              setState(() {
                isLoading = false; // Stop loading
                isVerified = true;
              });

              navigateToNextScreen();
            }
          }
        });

    timer = Timer(Duration(minutes: 3), () {
      if (!isVerified) {
        User_Deletion.reauthenticateAndDelete(widget.password);
        navigateToLoginScreen();
      }
    });
  }

  Future<void> navigateToNextScreen() async {
    if (!isVerified) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BabyProfileScreen()),
          (Route<dynamic> route) => false,

    );
  }

  void navigateToLoginScreen() {
    if (isVerified) return;
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
              Text(
                "Verify Your Email",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'A verification email has been sent to "${widget.user?.email}". Please verify.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20),
              if (isLoading) // Show loading indicator if isLoading is true
                CircularProgressIndicator(
                  color: Colors.deepOrange,
                ),
              if (!isLoading) // Show buttons only if not loading
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.user != null) {
                          await widget.user?.sendEmailVerification();
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
                          fontSize: 18,
                        ),
                      ),
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
                        User_Deletion.reauthenticateAndDelete(widget.password);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
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
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}