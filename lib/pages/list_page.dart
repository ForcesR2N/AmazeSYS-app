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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (parentItem != null) {
        controller.loadItemWithChildren(parentItem!);
      } else {
        controller.loadRootItems(level);
      }
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
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
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: Obx(() => _buildContent()),
    );
  }

  Widget _buildContent() {
    if (controller.isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: SkeletonLoader.listItemSkeleton(),
          ),
          childCount: 5,
        ),
      );
    }

    final itemsToShow =
        controller.selectedItem != null
            ? controller.childItems
            : controller.currentItems;

    if (itemsToShow.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = itemsToShow[index];
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
      }, childCount: itemsToShow.length),
    );
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
      Get.to(() => const ProductDetailPage(), arguments: item);
    } else {
      final nextLevel = item.level.nextLevel;
      if (nextLevel != null) {
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
}
