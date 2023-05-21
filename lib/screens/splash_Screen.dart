import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:rentalapp/screens/login.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("R e n t o",
          style: TextStyle( fontSize: 40,fontWeight:FontWeight.bold ),
          ),
        ],
      ),
      backgroundColor: Colors.amber,
       nextScreen: const LoginScreen(),
       splashIconSize:250,
       duration: 2500,
       splashTransition: SplashTransition.slideTransition,
       

       );
  }
}