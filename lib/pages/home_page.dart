import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../navbar/controllers/navbar_controller.dart';
import '../navbar/widgets/bottom_navbar.dart';
import '../favorites/views/favorites_page.dart';
import '../profile/views/profile_page.dart';
import '../core/theme/app_theme.dart';
import 'controllers/home_controller.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/modules_grid_section.dart';

/// Main home page with navigation to different modules
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final NavbarController _navbarController;
  late final HomeController _homeController;
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final FocusNode _focusNode;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
    _setupFocusNode();
    _setupAutoRefresh();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      body: PageView(
        controller: _navbarController.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildHomeContent(),
          const FavoritesPage(),
          const ProfilePage(),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: const BottomNavbar(),
    );
  }

  Widget _buildHomeContent() {
    return Focus(
      focusNode: _focusNode,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: RefreshIndicator(
              onRefresh: _homeController.refreshCounts,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: const [
                  HomeAppBar(),
                  ModulesGridSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Private helper methods

  void _initializeControllers() {
    if (!Get.isRegistered<NavbarController>()) {
      Get.put(NavbarController());
    }
    _navbarController = Get.find<NavbarController>();
    _homeController = Get.find<HomeController>();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: AppAnimations.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: AppAnimations.easeOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  void _setupFocusNode() {
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _setupAutoRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFirstLoad) {
        _focusNode.requestFocus();
        _isFirstLoad = false;
      }

      // Listen to bottom navigation changes
      ever(_navbarController.currentIndex, (int index) {
        if (index == 0) {
          _focusNode.requestFocus();
          _homeController.loadCounts();
        }
      });
    });
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _homeController.loadCounts();
    }
  }
}
