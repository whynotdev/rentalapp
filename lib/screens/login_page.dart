import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rentalapp/screens/home_page.dart';
import 'package:rentalapp/services/firebase_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "R e n t o",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SvgPicture.asset("assets/login.svg"),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey,
            
                child: IconButton(
                  onPressed: () async {
                    await FirebaseServices().SignInWithGoogle();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  HomePage()));
                  },
                  icon: Image.asset("assets/google.png"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
