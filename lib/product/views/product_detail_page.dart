import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../list-pages/models/list_item.dart';
import '../models/product_detail_model.dart';
import '../services/product_service.dart';
import '../../core/theme/app_theme.dart';
import '../../list-pages/widgets/skeleton_loader.dart';
import '../controllers/product_detail_controller.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductDetailController controller = Get.put(ProductDetailController());
    
    return WillPopScope(
      onWillPop: () async {
        controller.navigateBack();
        return false;
      },
      child: _ProductDetailPageContent(),
    );
  }
}

class _ProductDetailPageContent extends StatefulWidget {
  @override
  State<_ProductDetailPageContent> createState() => _ProductDetailPageContentState();
}

class _ProductDetailPageContentState extends State<_ProductDetailPageContent>
    with TickerProviderStateMixin {
  final ProductDetailController controller = Get.find<ProductDetailController>();

  late AnimationController _heroController;
  late AnimationController _contentController;
  late Animation<double> _heroAnimation;
  late Animation<double> _contentAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _contentController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: AppAnimations.easeOut),
    );

    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: AppAnimations.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: AppAnimations.easeOut),
    );

    // Start animations
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _contentController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [_buildHeroSection(), _buildContentSection()],
      ),
    );
  }

  Widget _buildHeroSection() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppTheme.surface,
      surfaceTintColor: AppTheme.surface,
      leading: Container(
        margin: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () => controller.navigateBack(),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: AppTheme.neutral700,
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.card,
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () => _showShareOptions(),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Icon(
                  Icons.share_outlined,
                  size: 20,
                  color: AppTheme.neutral700,
                ),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _heroAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary,
                  AppTheme.primaryLight,
                  const Color(0xFF60A5FA),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Hero(
                    tag: 'product-${controller.product.id}',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppRadius.xxxl),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 8),
                            blurRadius: 32,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        Text(
                          controller.product.name,
                          style: AppTypography.h2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _contentAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.only(top: 0),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xxxl),
                topRight: Radius.circular(AppRadius.xxxl),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),
                Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingState();
                  } else if (controller.errorMessage.value != null) {
                    return _buildErrorState();
                  } else if (controller.productDetail.value != null) {
                    return Column(
                      children: [
                        _buildQuickStats(),
                        _buildDescriptionSection(),
                        _buildDetailsSection(),
                        _buildActionButtons(),
                      ],
                    );
                  } else {
                    return _buildNoDataState();
                  }
                }),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
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
              '4.8',
              'Rating',
              Icons.star_outline,
              AppTheme.warning,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildStatCard(
              '150+',
              'Reviews',
              Icons.reviews_outlined,
              AppTheme.success,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildStatCard(
              '24/7',
              'Support',
              Icons.support_agent_outlined,
              const Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
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

  Widget _buildDescriptionSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Product Description',
            Icons.description_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.card,
              border: Border.all(color: AppTheme.border, width: 1),
            ),
            child: Text(
              controller.productDetail.value?.description ?? controller.product.description,
              style: AppTypography.bodyLarge.copyWith(
                color: AppTheme.neutral700,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Product Details', Icons.info_outline),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.card,
              border: Border.all(color: AppTheme.border, width: 1),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  'Category',
                  controller.productDetail.value?.categoryName ??
                      _extractCategory(controller.product.description),
                  true,
                ),
                _buildDetailRow('Stock Status', 'In Stock', false),
                _buildDetailRow('Availability', 'Available', false),
                _buildDetailRow(
                  'SKU',
                  controller.productDetail.value?.codeId ?? controller.product.code,
                  false,
                ),
                if (controller.productDetail.value?.warehouseId != null)
                  _buildDetailRow(
                    'Warehouse ID',
                    controller.productDetail.value!.warehouseId,
                    false,
                  ),
                if (controller.productDetail.value?.branchId != null)
                  _buildDetailRow('Branch ID', controller.productDetail.value!.branchId, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 20, color: AppTheme.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.neutral900,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isFirst) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border:
            isFirst
                ? null
                : const Border(
                  top: BorderSide(color: AppTheme.border, width: 1),
                ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodyLarge.copyWith(
                color: AppTheme.neutral600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.bodyLarge.copyWith(
                color: AppTheme.neutral900,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  'Add to Wishlist',
                  Icons.favorite_outline,
                  () => _showWishlistSnackbar(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: AppTypography.buttonMedium),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primary,
          side: BorderSide(color: AppTheme.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
    );
  }

  String _extractCategory(String description) {
    if (description.toLowerCase().contains('smartphone') ||
        description.toLowerCase().contains('phone')) {
      return 'Electronics - Mobile';
    } else if (description.toLowerCase().contains('laptop') ||
        description.toLowerCase().contains('computer')) {
      return 'Electronics - Computing';
    } else if (description.toLowerCase().contains('tablet')) {
      return 'Electronics - Tablets';
    } else {
      return 'General Products';
    }
  }

  void _showShareOptions() {
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
                        Text(
                          'Share Product',
                          style: AppTypography.h3.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildShareOption(
                              'WhatsApp',
                              Icons.chat_outlined,
                              AppTheme.success,
                            ),
                            _buildShareOption(
                              'Email',
                              Icons.email_outlined,
                              AppTheme.primary,
                            ),
                            _buildShareOption(
                              'Copy Link',
                              Icons.link_outlined,
                              AppTheme.warning,
                            ),
                          ],
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

  Widget _buildShareOption(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Get.back();
        Get.snackbar(
          'Shared!',
          'Product shared via $label',
          backgroundColor: color.withOpacity(0.1),
          colorText: color,
          borderRadius: AppRadius.lg,
          margin: const EdgeInsets.all(AppSpacing.md),
          icon: Icon(Icons.share_outlined, color: color),
        );
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppTheme.neutral600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showWishlistSnackbar() {
    Get.snackbar(
      'Added to Wishlist!',
      'Product has been saved to your wishlist',
      backgroundColor: AppTheme.errorLight,
      colorText: AppTheme.error,
      borderRadius: AppRadius.lg,
      margin: const EdgeInsets.all(AppSpacing.md),
      icon: Icon(Icons.favorite, color: AppTheme.error),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Quick stats skeleton
          Row(
            children: [
              Expanded(child: SkeletonLoader.detailCardSkeleton()),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: SkeletonLoader.detailCardSkeleton()),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: SkeletonLoader.detailCardSkeleton()),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Description skeleton
          SkeletonLoader.detailCardSkeleton(),
          const SizedBox(height: AppSpacing.xl),
          // Details skeleton
          SkeletonLoader.detailCardSkeleton(),
          const SizedBox(height: AppSpacing.xl),
          // Specifications skeleton
          SkeletonLoader.detailCardSkeleton(),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Error Loading Product',
              style: AppTypography.h3.copyWith(
                color: AppTheme.neutral700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              controller.errorMessage.value ?? 'Unknown error occurred',
              style: AppTypography.bodyMedium.copyWith(
                color: AppTheme.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: controller.retry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Container(
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
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: AppTheme.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Product Not Found',
              style: AppTypography.h3.copyWith(
                color: AppTheme.neutral700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Product information is not available',
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
}
