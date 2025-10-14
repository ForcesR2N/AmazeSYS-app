import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../auth/controllers/auth_controller.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e), // Dark blue
              Color(0xFF16213e), // Darker blue
              Color(0xFF0f0f23), // Almost black
            ],
          ),
        ),
        child: Center(
          child: Lottie.asset(
            'asset/animation-splash-screen.json',
            fit: BoxFit.contain,
            repeat: false,
            animate: true,
          ),
        ),
      ),
    );
  }
}