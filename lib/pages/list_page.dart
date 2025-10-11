import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/list_controller.dart';
import '../models/list_item.dart';
import '../models/list_arguments.dart';
import '../widgets/skeleton_loader.dart';
import '../core/theme/app_theme.dart';
import 'product_detail_page.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with TickerProviderStateMixin {
  final ListController controller = Get.find<ListController>();
  final TextEditingController searchController = TextEditingController();

  late ListLevel level;
  ListItem? parentItem;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Toggle view state: true = detail view, false = list view
  bool _showDetailView = true;
  
  // Track if we should auto-switch due to empty details
  bool _hasValidDetails = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );

    final args = ListArguments.fromMap(Get.arguments as Map<String, dynamic>);
    level = args.level;
    parentItem = args.parentItem;

    // Listen to controller changes and validate details
    ever(Rx(() => controller.selectedItem), (selectedItem) {
      _checkDetailsValidityAndSetView();
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePageData();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Initialize page data and determine initial view
  Future<void> _initializePageData() async {
    try {
      if (parentItem != null) {
        // Load data for selected item and its children
        await controller.loadItemWithChildren(parentItem!);
        _checkDetailsValidityAndSetView();
      } else {
        // Load root items - no selected item, so show navigate view
        await controller.loadRootItems(level);
        _hasValidDetails = false;
        _showDetailView = false; // No parent item, show navigate first
      }
    } catch (e) {
      // On error, default to navigate view
      _hasValidDetails = false;
      _showDetailView = false;
    }
    
    if (mounted) setState(() {});
  }

  // Check if details are valid and set appropriate view
  void _checkDetailsValidityAndSetView() {
    final selectedItem = controller.selectedItem;
    
    // Check if details are valid
    _hasValidDetails = selectedItem != null && 
                     selectedItem.name.isNotEmpty && 
                     selectedItem.description.isNotEmpty;
    
    // Set initial view based on details validity
    if (_hasValidDetails) {
      _showDetailView = true; // Show details first if valid
    } else {
      _showDetailView = false; // Auto-switch to navigate if empty
    }
  }

  // Safe toggle with validation
  void _toggleView(bool showDetails) {
    if (showDetails && !_hasValidDetails) {
      // Don't switch to details if data is invalid
      Get.snackbar(
        'No Details Available',
        'Unable to load item details. Showing navigation instead.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.warningLight,
        colorText: AppTheme.warning,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    
    setState(() {
      _showDetailView = showDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            _buildHeaderSection(),
            _buildContentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: AppTheme.surface,
      surfaceTintColor: AppTheme.surface,
      elevation: 0,
      shadowColor: AppTheme.shadowLight,
      leading: Container(
        margin: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () => Get.back(),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: AppTheme.neutral700,
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            level.displayName,
            style: AppTypography.h4.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.neutral900,
            ),
          ),
          if (parentItem != null)
            Text(
              parentItem!.displayName,
              style: AppTypography.bodySmall.copyWith(
                color: AppTheme.neutral500,
              ),
            ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () => _showFilterOptions(),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Icon(
                  Icons.tune_outlined,
                  size: 20,
                  color: AppTheme.neutral700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppTheme.surface,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _buildBreadcrumb(),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSelectedItemCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSearchBar(),
                  const SizedBox(height: AppSpacing.md),
                  _buildToggleTabs(),
                ],
              ),
            ),
            Container(height: 1, color: AppTheme.border),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    List<String> breadcrumbs = ['Home'];
    if (parentItem != null) {
      breadcrumbs.add(parentItem!.level.displayName);
    }
    breadcrumbs.add(level.displayName);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.borderLight, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            color: AppTheme.neutral500,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              breadcrumbs.join(' › '),
              style: AppTypography.bodyMedium.copyWith(
                color: AppTheme.neutral600,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedItemCard() {
    return Obx(() {
      if (controller.selectedItem == null) return const SizedBox.shrink();

      final selectedItem = controller.selectedItem!;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.primaryLight],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                _getIconForLevel(selectedItem.level),
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedItem.displayName,
                    style: AppTypography.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    selectedItem.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppTheme.border, width: 1),
        boxShadow: AppShadows.card,
      ),
      child: Obx(
        () => TextField(
          controller: searchController,
          style: AppTypography.bodyLarge.copyWith(color: AppTheme.neutral900),
          decoration: InputDecoration(
            hintText:
                controller.selectedItem != null
                    ? 'Search ${controller.selectedItem!.level.nextLevel?.displayName ?? 'items'}...'
                    : 'Search ${level.displayName}...',
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppTheme.neutral400,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.search_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            suffixIcon:
                controller.searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        color: AppTheme.neutral400,
                      ),
                      onPressed: () {
                        searchController.clear();
                        controller.clearSearch();
                      },
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          onChanged: (query) {
            if (controller.selectedItem != null) {
              final nextLevel = controller.selectedItem!.level.nextLevel;
              if (nextLevel != null) {
                controller.searchWithDebounce(
                  query,
                  nextLevel,
                  parentId: controller.selectedItem!.id,
                );
              }
            } else {
              controller.searchWithDebounce(query, level);
            }
          },
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return SliverToBoxAdapter(
      child: AnimatedSwitcher(
        duration: AppAnimations.medium,
        switchInCurve: AppAnimations.easeOut,
        switchOutCurve: AppAnimations.easeOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _showDetailView ? _buildDetailView() : _buildListView(),
      ),
    );
  }

  Widget _buildListView() {
    return Obx(() {
      if (controller.isLoading) {
        return Container(
          key: const ValueKey('list'),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: SkeletonLoader.listItemSkeleton(),
              ),
            ),
          ),
        );
      }

      final itemsToShow = controller.selectedItem != null
          ? controller.childItems
          : controller.currentItems;

      if (itemsToShow.isEmpty) {
        return Container(
          key: const ValueKey('list'),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _buildEmptyState(),
        );
      }

      return Container(
        key: const ValueKey('list'),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: itemsToShow.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 200 + (index * 50)),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - value) * 20),
                  child: Opacity(
                    opacity: value,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildItemCard(item),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      );
    });
  }


  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(AppRadius.xxxl),
              ),
              child: Icon(
                controller.searchQuery.isNotEmpty
                    ? Icons.search_off_rounded
                    : Icons.inventory_2_outlined,
                size: 48,
                color: AppTheme.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              controller.searchQuery.isNotEmpty
                  ? 'No results found'
                  : 'No items available',
              style: AppTypography.h3.copyWith(
                color: AppTheme.neutral700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              controller.searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Items will appear here when available',
              style: AppTypography.bodyLarge.copyWith(
                color: AppTheme.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(ListItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: () => _handleItemTap(item),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getColorForLevel(item.level).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: _getColorForLevel(item.level).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getIconForLevel(item.level),
                    color: _getColorForLevel(item.level),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayName,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppTheme.neutral900,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppTheme.neutral500,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppTheme.borderLight, width: 1),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppTheme.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForLevel(ListLevel level) {
    switch (level) {
      case ListLevel.company:
        return Icons.business_outlined;
      case ListLevel.branch:
        return Icons.store_outlined;
      case ListLevel.warehouse:
        return Icons.warehouse_outlined;
      case ListLevel.product:
        return Icons.inventory_2_outlined;
    }
  }

  Color _getColorForLevel(ListLevel level) {
    switch (level) {
      case ListLevel.company:
        return AppTheme.primary;
      case ListLevel.branch:
        return AppTheme.success;
      case ListLevel.warehouse:
        return AppTheme.warning;
      case ListLevel.product:
        return const Color(0xFF8B5CF6);
    }
  }

  void _handleItemTap(ListItem item) {
    if (item.level == ListLevel.product) {
      // Navigate to product detail page
      Get.to(() => const ProductDetailPage(), arguments: item);
    } else {
      final nextLevel = item.level.nextLevel;
      if (nextLevel != null) {
        // Clean navigation: reset controller state before navigating
        controller.reset();
        
        // Navigate to next level with selected item as parent
        Get.to(
          () => const ListPage(),
          arguments: ListArguments(level: nextLevel, parentItem: item).toMap(),
        );
      } else {
        Get.snackbar(
          'Info',
          'No more levels available',
          backgroundColor: AppTheme.infoLight,
          colorText: AppTheme.info,
          borderRadius: AppRadius.lg,
          margin: const EdgeInsets.all(AppSpacing.md),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void _showFilterOptions() {
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter Options',
                          style: AppTypography.h3.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Coming soon...',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppTheme.neutral500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailView() {
    return Obx(() {
      if (controller.selectedItem == null) {
        return Container(
          key: const ValueKey('detail'),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.neutral100,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: 40,
                    color: AppTheme.neutral400,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'No Item Selected',
                  style: AppTypography.h3.copyWith(
                    color: AppTheme.neutral700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Select an item to view its details',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppTheme.neutral500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        key: const ValueKey('detail'),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildAdditionalInfoSection(),
          ],
        ),
      );
    });
  }

  Widget _buildInfoSection() {
    final item = controller.selectedItem!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INFORMATION',
          style: AppTypography.labelSmall.copyWith(
            color: AppTheme.neutral600,
            fontSize: 12,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Name', item.name),
              const SizedBox(height: AppSpacing.md),
              _buildInfoRow('Code', item.code),
              const SizedBox(height: AppSpacing.md),
              _buildInfoRow('Level', item.level.displayName),
              const SizedBox(height: AppSpacing.md),
              _buildInfoRow('Description', item.description),
              if (item.parentId != null) ...[
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow('Parent ID', item.parentId!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppTheme.neutral500,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: AppTheme.neutral900,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    final item = controller.selectedItem!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADDITIONAL INFORMATION',
          style: AppTypography.labelSmall.copyWith(
            color: AppTheme.neutral600,
            fontSize: 12,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('ID', item.id),
              const SizedBox(height: AppSpacing.md),
              _buildInfoRow('Display Name', item.displayName),
              const SizedBox(height: AppSpacing.md),
              _buildInfoRow('Category', '${item.level.displayName} Management'),
              const SizedBox(height: AppSpacing.md),
              _buildInfoRow('Created', 'System Generated'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'Details',
              isActive: _showDetailView,
              onTap: () => _toggleView(true),
              isDisabled: !_hasValidDetails,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton(
              label: 'Navigate',
              isActive: !_showDetailView,
              onTap: () => _toggleView(false),
              isDisabled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDisabled,
  }) {
    return AnimatedContainer(
      duration: AppAnimations.medium,
      curve: AppAnimations.easeInOut,
      decoration: BoxDecoration(
        gradient: isActive && !isDisabled
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, AppTheme.primaryLight],
              )
            : null,
        color: isDisabled 
            ? AppTheme.neutral100 
            : (isActive ? null : Colors.transparent),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: isActive && !isDisabled ? AppShadows.card : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: isDisabled ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isDisabled && label.contains('Details'))
                  Icon(
                    Icons.block,
                    size: 14,
                    color: AppTheme.neutral400,
                  ),
                if (isDisabled && label.contains('Details'))
                  const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: isDisabled 
                        ? AppTheme.neutral400
                        : (isActive ? Colors.white : AppTheme.neutral500),
                    fontWeight: isActive && !isDisabled 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
