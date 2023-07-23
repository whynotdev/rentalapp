import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentalapp/screens/home_page.dart';
import 'package:rentalapp/screens/login_page.dart';

import '../utils/routers.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      //if user is authenticated then move to AuthPage else move to MainActivityPage
      if (FirebaseAuth.instance.currentUser == null) {
        nextPageOnly(context: context, page: LoginScreen());
      } else {
        nextPageOnly(context: context, page: HomePage());
      }
    });
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "R e n t o",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      backgroundColor: Colors.amber,
      nextScreen: const LoginScreen(),
      splashIconSize: 250,
      splashTransition: SplashTransition.slideTransition,
    );
  }
}
