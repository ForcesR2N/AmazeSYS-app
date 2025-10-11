import 'dart:developer';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavbarController extends GetxController {
  late PageController pageController;
  late NotchBottomBarController notchBottomBarController;
  
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
    notchBottomBarController = NotchBottomBarController(index: 0);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changePage(int index) {
    log('Navigating to page $index');
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }
}