import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/list_item.dart';
import '../core/theme/app_theme.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> with TickerProviderStateMixin {
  late ListItem product;
  late AnimationController _heroController;
  late AnimationController _contentController;
  late Animation<double> _heroAnimation;
  late Animation<double> _contentAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    product = Get.arguments as ListItem;
    
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
    ).animate(CurvedAnimation(parent: _contentController, curve: AppAnimations.easeOut));

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
        slivers: [
          _buildHeroSection(),
          _buildContentSection(),
        ],
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
            onTap: () => Get.back(),
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
                    tag: 'product-${product.id}',
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
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      children: [
                        Text(
                          product.name,
                          style: AppTypography.h2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            product.code,
                            style: AppTypography.labelLarge.copyWith(
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
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
            margin: const EdgeInsets.only(top: -AppSpacing.lg),
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
                _buildQuickStats(),
                _buildDescriptionSection(),
                _buildDetailsSection(),
                _buildSpecificationsSection(),
                _buildActionButtons(),
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
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('4.8', 'Rating', Icons.star_outline, AppTheme.warning)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildStatCard('150+', 'Reviews', Icons.reviews_outlined, AppTheme.success)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildStatCard('24/7', 'Support', Icons.support_agent_outlined, const Color(0xFF8B5CF6))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
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
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Product Description', Icons.description_outlined),
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
              product.description,
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
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
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
                _buildDetailRow('Category', _extractCategory(product.description), true),
                _buildDetailRow('Stock Status', 'In Stock', false),
                _buildDetailRow('Availability', 'Available', false),
                _buildDetailRow('SKU', product.code, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Specifications', Icons.tune_outlined),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary.withOpacity(0.05),
                  AppTheme.primaryLight.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppTheme.primary.withOpacity(0.1), width: 1),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        Icons.price_check_outlined,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact for Pricing',
                            style: AppTypography.h4.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Get personalized pricing and volume discounts by contacting our sales team.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppTheme.neutral600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primary,
          ),
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
        border: isFirst ? null : const Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyLarge.copyWith(
              color: AppTheme.neutral600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(
              color: AppTheme.neutral900,
              fontWeight: FontWeight.w600,
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
          // Primary Action
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _showContactDialog(),
              icon: const Icon(Icons.phone_outlined, size: 20),
              label: Text(
                'Contact Sales',
                style: AppTypography.buttonLarge.copyWith(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: AppTheme.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Secondary Actions
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
              Expanded(
                child: _buildSecondaryButton(
                  'Compare',
                  Icons.compare_arrows_outlined,
                  () => _showCompareSnackbar(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: AppTypography.buttonMedium,
        ),
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

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
          ),
          title: Text(
            'Contact Sales Team',
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.neutral900,
            ),
          ),
          content: Text(
            'Our sales team will contact you within 24 hours with personalized pricing and product information.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppTheme.neutral600,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.neutral500,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTypography.buttonMedium,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Request Sent!',
                  'Our sales team will contact you soon.',
                  backgroundColor: AppTheme.successLight,
                  colorText: AppTheme.success,
                  borderRadius: AppRadius.lg,
                  margin: const EdgeInsets.all(AppSpacing.md),
                  icon: Icon(Icons.check_circle_outline, color: AppTheme.success),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(
                'Send Request',
                style: AppTypography.buttonMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                        _buildShareOption('WhatsApp', Icons.chat_outlined, AppTheme.success),
                        _buildShareOption('Email', Icons.email_outlined, AppTheme.primary),
                        _buildShareOption('Copy Link', Icons.link_outlined, AppTheme.warning),
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

  void _showCompareSnackbar() {
    Get.snackbar(
      'Added to Compare!',
      'Product added to comparison list',
      backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
      colorText: const Color(0xFF8B5CF6),
      borderRadius: AppRadius.lg,
      margin: const EdgeInsets.all(AppSpacing.md),
      icon: Icon(Icons.compare_arrows, color: const Color(0xFF8B5CF6)),
    );
  }
}