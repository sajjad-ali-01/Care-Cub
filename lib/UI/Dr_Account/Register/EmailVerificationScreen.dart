import 'package:carecub/Logic/Users/ParentsLogic.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:carecub/UI/User/Login.dart';

import '../../../Database/DatabaseServices.dart';
import '../../../Logic/Users/User_Deletion.dart';
import 'Professional_Info.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String title;
  final String city;
  late User? user;
  final String password;

  EmailVerificationScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.phone,
    required this.title,
    required this.city,
    required this.user,
    required this.password,
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

    userSubscription =
        FirebaseAuth.instance.userChanges().listen((User? currentUser) async {
          if (currentUser != null) {
            await currentUser.reload();
            setState(() {
              user = currentUser;
            });

            if (currentUser.emailVerified) {
              isVerified = true;
              await DatabaseService.saveDrData(
                uid: widget.user!.uid,
                name: widget.name,
                email: widget.email,
                phone: widget.phone,
                title: widget.title,
                city: widget.city,
              );
              navigateToNextScreen();
            }
          }
        });

    timer = Timer(Duration(minutes: 3), () {
      if (!isVerified) {
        showToast(message: "Verification Failed");
        User_Deletion.reauthenticateAndDelete(widget.password);
        navigateToLoginScreen();
      }
    });
  }
  @override
  void dispose() {
    userSubscription.cancel();
    timer?.cancel();
    super.dispose();
  }


  void navigateToNextScreen() {
    if (!isVerified) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignUpStep2()),
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
                  onPressed: () async{

                    User_Deletion.reauthenticateAndDelete(widget.password);

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


