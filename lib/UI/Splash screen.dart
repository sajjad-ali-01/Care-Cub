import 'package:carecub/UI/Doctor_Booking/Doctor_Side/DoctorHome.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BottomNavigationBar.dart';
import 'DayCare/Daycarecenter/MainScreen.dart';
import 'WelcomeScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Widget nextScreen = const Center(child: CircularProgressIndicator());

  @override
  void initState() {
    super.initState();
    determineNextScreen();
  }

  Future<void> determineNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
   // bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    bool isDrLoggedIn = await prefs.getBool('isDrLoggedIn')??false;
    bool isDaCareLoggedIn = await prefs.getBool('isDaCareLoggedIn') ?? false;

    setState(() {
      // if (isFirstTime) {
      //   nextScreen =  WelcomeScreen();
      //   prefs.setBool('isFirstTime', false);
      // } else
      if (isLoggedIn) {
        nextScreen =  Tabs();
      }
      else if(isDrLoggedIn){
        nextScreen = DoctorDashboard();
      }

      else if(isDaCareLoggedIn){
        nextScreen = MainScreen();
      }
      else {
        nextScreen =  WelcomeScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Image.asset('assets/images/CareCub_Animation.gif'),
      splashIconSize: 2500,
      centered: true,
      nextScreen: nextScreen,
      backgroundColor: Colors.red.shade300,
      duration: 2800,
    );
  }
}
