import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();

    Timer(Duration(seconds: 12), () => Navigator.pushReplacementNamed(context, '/login'));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFFFF5722),// deep orange
              Color(0xFFFF5722),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'lib/assets/animations/foodie.json',
                  height: 140,
                ),
                SizedBox(height: 12),
                Text(
                  'homemade goodness delivered to your doorstep',
                  style: TextStyle(
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFFBC02D),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Lottie.asset(
                  'lib/assets/animations/plate_loader.json',
                  height: 60,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
