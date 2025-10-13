import 'dart:developer';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/navbar_controller.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavbarController controller = Get.find<NavbarController>();

    return AnimatedNotchBottomBar(
      notchBottomBarController: controller.notchBottomBarController,
      showLabel: true,
      textOverflow: TextOverflow.visible,
      maxLine: 1,
      shadowElevation: 8,
      kBottomRadius: 0.0,
      notchColor: AppTheme.primary,
      removeMargins: true,
      bottomBarWidth: MediaQuery.of(context).size.width,
      showShadow: true,
      durationInMilliSeconds: 300,
      itemLabelStyle: AppTypography.labelSmall.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
      elevation: 4,
      bottomBarItems: [
        BottomBarItem(
          inActiveItem: Icon(Icons.home_outlined, size: 24),
          activeItem: Icon(Icons.home, color: AppTheme.surface, size: 24),
          itemLabel: 'Home',
        ),
        BottomBarItem(
          inActiveItem: Icon(Icons.table_chart_outlined, size: 24),
          activeItem: Icon(
            Icons.table_chart,
            color: AppTheme.surface,
            size: 24,
          ),
          itemLabel: 'Table',
        ),
        BottomBarItem(
          inActiveItem: Icon(
            Icons.person_outline,
            color: AppTheme.neutral500,
            size: 24,
          ),
          activeItem: Icon(Icons.person, color: AppTheme.surface, size: 24),
          itemLabel: 'Profile',
        ),
      ],
      onTap: (index) {
        log('Bottom bar tapped: index $index');
        controller.changePage(index);
      },
      kIconSize: 24.0,
    );
  }
}
