import 'dart:async';
import 'package:flutter/material.dart';
import 'signup_page.dart'; // Import your SignupPage

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    // Start a timer that triggers navigation after a certain duration
    Timer(Duration(seconds: 3), () {
      // Navigate to the SignupPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignupPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text(
            'Fake News Detector',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
