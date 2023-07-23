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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "R e n t o",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 80,
                ),
                Center(
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        "assets/login1.svg",
                        height: 350,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                SizedBox(
                  height: 50,
                ),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.pink,
                  child: IconButton(
                    onPressed: () async {
                      await FirebaseServices().SignInWithGoogle();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    },
                    icon: SvgPicture.asset("assets/google.svg"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
