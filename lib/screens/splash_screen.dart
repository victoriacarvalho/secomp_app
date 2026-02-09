import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }


  final Color backgroundColor = const Color(0xFFE6E6E6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),


            Center(
              child: Image.asset(
                'public/secomp.png',
                width: 250,
                fit: BoxFit.contain,
              ),
            ),

            const Spacer(),



            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Image.asset(
                'public/icea.png',
                height: 80,
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}