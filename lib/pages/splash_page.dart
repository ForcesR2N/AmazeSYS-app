import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/controllers/auth_controller.dart';
import '../core/theme/app_theme.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Obx(() {
        // Show splash screen while initializing
        if (authController.isInitializing) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.business,
                    size: 60,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // App Name
                Text(
                  'AMAZESYS',
                  style: AppTypography.h1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                
                Text(
                  'Management System',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xxxl),
                
                // Loading Indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                Text(
                  'Initializing...',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }
        
        // After initialization, this widget will be replaced by navigation
        // but show a brief success state just in case
        return Center(
          child: Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.white,
          ),
        );
      }),
    );
  }
}