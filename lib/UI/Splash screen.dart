import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'User/Login.dart';
import 'BottomNavigationBar.dart';
import 'WelcomeScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Widget nextScreen = const Center(child: CircularProgressIndicator()); // Default loading widget

  @override
  void initState() {
    super.initState();
    determineNextScreen();
  }

  Future<void> determineNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
   // bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Update the nextScreen based on user status
    setState(() {
      // if (isFirstTime) {
      //   nextScreen =  WelcomeScreen();
      //   prefs.setBool('isFirstTime', false); // Update first-time status
      // } else
      if (isLoggedIn) {
        nextScreen =  Tabs(); // If user is logged in, navigate to Home
      } else {
        nextScreen =  WelcomeScreen(); // Otherwise, navigate to Login
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Image.asset('assets/images/Animation.gif'),
      splashIconSize: 2500,
      centered: true,
      nextScreen: nextScreen, // Dynamic next screen
      backgroundColor: Colors.red.shade300,
      duration: 3500,
    );
  }
}
