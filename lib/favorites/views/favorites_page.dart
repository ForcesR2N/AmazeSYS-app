import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/favorites_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_snackbar.dart';
import '../../list-pages/models/list_item.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final FavoritesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(FavoritesController());
    // Auto refresh when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.neutral900,
          ),
        ),
        backgroundColor: AppTheme.surface,
        surfaceTintColor: AppTheme.surface,
        elevation: 0,
        actions: [
          Obx(
            () =>
                controller.favorites.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _showClearAllDialog(context, controller),
                      tooltip: 'Clear all favorites',
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredItems = controller.filteredFavorites;

              if (filteredItems.isEmpty) {
                return _buildEmptyState(controller);
              }

              return RefreshIndicator(
                onRefresh: () async {
                  CustomSnackbar.info(message: 'Refreshing favorites...');
                  await controller.refreshFavorites();
                  CustomSnackbar.success(message: 'Favorites refreshed');
                },
                color: AppTheme.primary,
                backgroundColor: AppTheme.surface,
                displacement: 20,
                strokeWidth: 3,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _buildFavoriteCard(item, controller, context);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(FavoritesController controller) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search favorites...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppTheme.neutral400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.neutral400,
            size: 20,
          ),
          suffixIcon: Obx(
            () =>
                controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        color: AppTheme.neutral400,
                        size: 20,
                      ),
                      onPressed: () => controller.updateSearchQuery(''),
                    )
                    : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: AppTheme.surfaceContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            borderSide: BorderSide(color: AppTheme.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            borderSide: BorderSide(color: AppTheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(
    item,
    FavoritesController controller,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          onTap: () => _navigateToProductDetail(item),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppTheme.neutral900,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (item.productCode != null &&
                          item.productCode!.isNotEmpty)
                        Text(
                          'Code: ${item.productCode}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppTheme.neutral500,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (item.categoryName != null &&
                          item.categoryName!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            item.categoryName!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppTheme.warning,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Added ${_formatDate(item.addedAt)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppTheme.neutral400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.error,
                    size: 20,
                  ),
                  onPressed: () => _showRemoveDialog(context, item, controller),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(FavoritesController controller) {
    final isSearching = controller.searchQuery.value.isNotEmpty;

    return Center(
      child: Padding(
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
                isSearching ? Icons.search_off_rounded : Icons.favorite_outline,
                size: 48,
                color: AppTheme.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isSearching ? 'No results found' : 'No favorites yet',
              style: AppTypography.h3.copyWith(
                color: AppTheme.neutral700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isSearching
                  ? 'Try different search terms'
                  : 'Add products to your favorites to see them here',
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

  void _navigateToProductDetail(item) {
    final listItem = ListItem(
      id: item.productId,
      name: item.productName,
      code: item.productCode ?? '',
      description: item.productDescription,
      level: item.level,
    );
    Get.toNamed('/product-detail', arguments: listItem);
  }

  void _showRemoveDialog(
    BuildContext context,
    item,
    FavoritesController controller,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove from Favorites'),
            content: Text('Remove "${item.productName}" from your favorites?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  controller.removeFromFavorites(item.productId);
                  Get.back();
                  CustomSnackbar.success(
                    message: 'Product removed from favorites',
                  );
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: AppTheme.error),
                ),
              ),
            ],
          ),
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    FavoritesController controller,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Favorites'),
            content: const Text(
              'Are you sure you want to clear all favorites?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  controller.clearAllFavorites();
                  Get.back();
                  CustomSnackbar.success(message: 'All favorites cleared');
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: AppTheme.error),
                ),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }
}
