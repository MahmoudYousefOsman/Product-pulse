import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:software_system/screens/login.dart';

class SplashScreens extends StatelessWidget {
  const SplashScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1960fb), Color(0xFF3d37c1)
            // Color(0xFF0D47A1),
            // Color(0xFF6A1B9A), 
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AnimatedSplashScreen(
        duration: 3000,
        splash: Lottie.asset("assets/Ani.json"),
        nextScreen:  Login_screen(),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.transparent, 
        splashIconSize: 400,
      ),
    );
  }
}
