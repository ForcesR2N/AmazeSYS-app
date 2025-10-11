import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/navbar_controller.dart';
import '../models/list_item.dart';
import '../models/list_arguments.dart';
import '../routes/app_pages.dart';
import '../core/theme/app_theme.dart';
import '../widgets/bottom_navbar.dart';
import 'table_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  late final NavbarController navbarController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> menuItems = [
    {
      'name': 'Companies',
      'level': 'company',
      'icon': Icons.business_outlined,
      'count': '12',
      'color': AppTheme.primary,
    },
    {
      'name': 'Branches',
      'level': 'branch',
      'icon': Icons.store_outlined,
      'count': '48',
      'color': AppTheme.success,
    },
    {
      'name': 'Warehouses',
      'level': 'warehouse',
      'icon': Icons.warehouse_outlined,
      'count': '156',
      'color': AppTheme.warning,
    },
    {
      'name': 'Products',
      'level': 'product',
      'icon': Icons.inventory_2_outlined,
      'count': '2.3K',
      'color': Color(0xFF8B5CF6),
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize navbar controller if not already done
    if (!Get.isRegistered<NavbarController>()) {
      Get.put(NavbarController());
    }
    navbarController = Get.find<NavbarController>();

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

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomePage(),
      const TablePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      body: PageView(
        controller: navbarController.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      extendBody: true,
      bottomNavigationBar: const BottomNavbar(),
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              _buildQuickStats(),
              _buildModulesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AMAZESYS',
                  style: AppTypography.h3.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Management',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppTheme.neutral500,
                  ),
                ),
              ],
            ),
            _buildProfileButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () => _showProfileMenu(context),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primarySurface,
                  child: Text(
                    (authController.currentUser?.name ?? 'U')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: AppTypography.labelMedium.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Active',
                '24/7',
                Icons.schedule_outlined,
                AppTheme.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                'Modules',
                '4',
                Icons.dashboard_outlined,
                AppTheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                'Items',
                '2.5K+',
                Icons.inventory_outlined,
                AppTheme.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.h4.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppTheme.neutral500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Modules',
                      style: AppTypography.h2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Access your business operations',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppTheme.neutral500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate optimal card dimensions based on screen width
                const double minCardWidth = 160.0;
                const double maxCardWidth = 200.0;
                final double availableWidth = constraints.maxWidth;
                final int crossAxisCount = (availableWidth / minCardWidth)
                    .floor()
                    .clamp(2, 3);
                final double cardWidth =
                    (availableWidth - (AppSpacing.md * (crossAxisCount - 1))) /
                    crossAxisCount;
                final double cardHeight =
                    cardWidth * 1.2; // Better aspect ratio for content

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: cardWidth / cardHeight,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    return _buildModuleCard(menuItems[index], index);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> item, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: AppShadows.card,
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  onTap: () => _handleModuleTap(item),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with icon and count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon container - flexible size
                            Flexible(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: (item['color'] as Color).withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: item['color'] as Color,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            // Count badge - constrained
                            Container(
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                maxWidth: 60,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                                border: Border.all(
                                  color: AppTheme.borderLight,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                item['count'],
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppTheme.neutral600,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),

                        // Spacing
                        const SizedBox(height: AppSpacing.lg),

                        // Title - constrained height
                        Flexible(
                          child: Text(
                            item['name'],
                            style: AppTypography.h4.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleModuleTap(Map<String, dynamic> item) {
    final level = ListLevel.values.firstWhere((e) => e.name == item['level']);
    final args = ListArguments(level: level);
    Get.toNamed(Routes.LIST, arguments: args.toMap());
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xxl),
                topRight: Radius.circular(AppRadius.xxl),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppTheme.neutral300,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppTheme.primarySurface,
                          child: Text(
                            (authController.currentUser?.name ?? 'U')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: AppTypography.h3.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Obx(
                          () => Text(
                            authController.currentUser?.name ?? 'User',
                            style: AppTypography.h4.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Obx(
                          () => Text(
                            authController.currentUser?.email ?? '',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppTheme.neutral500,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showLogoutDialog(context);
                            },
                            icon: const Icon(Icons.logout_outlined),
                            label: const Text('Sign Out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.error,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(AppSpacing.md),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
          ),
          title: Text(
            'Sign Out',
            style: AppTypography.h3.copyWith(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to sign out of your account?',
            style: AppTypography.bodyLarge.copyWith(color: AppTheme.neutral600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.neutral500,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              child: Text('Cancel', style: AppTypography.buttonMedium),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authController.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text('Sign Out', style: AppTypography.buttonMedium),
            ),
          ],
        );
      },
    );
  }
}
