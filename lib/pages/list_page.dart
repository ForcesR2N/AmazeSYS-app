import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/list_controller.dart';
import '../models/list_item.dart';
import '../models/list_arguments.dart';
import '../widgets/skeleton_loader.dart';
import 'product_detail_page.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final ListController controller = Get.find<ListController>();
  final TextEditingController searchController = TextEditingController();
  
  late ListLevel level;
  ListItem? parentItem;

  @override
  void initState() {
    super.initState();
    
    final args = ListArguments.fromMap(Get.arguments as Map<String, dynamic>);
    level = args.level;
    parentItem = args.parentItem;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (parentItem != null) {
        controller.loadItemWithChildren(parentItem!);
      } else {
        controller.loadRootItems(level);
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1E40AF),
                    Color(0xFF3B82F6),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      children: [
                        // Breadcrumb
                        _buildBreadcrumb(),
                        
                        const SizedBox(height: 24),
                        
                        // Selected Item Card (if exists)
                        Obx(() => controller.selectedItem != null 
                          ? _buildSelectedItemCard() 
                          : _buildLevelIntroCard()),
                        
                        const SizedBox(height: 24),
                        
                        // Search Bar
                        _buildSearchBar(),
                      ],
                    ),
                  ),
                  // Bottom curved decoration
                  Container(
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content Section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            sliver: Obx(() => _buildContent()),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF1E40AF),
      foregroundColor: Colors.white,
      title: Text(
        level.displayName.toUpperCase(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    List<String> breadcrumbs = [];
    if (parentItem != null) {
      breadcrumbs.add(parentItem!.level.displayName);
    }
    breadcrumbs.add(level.displayName);

    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          color: Colors.white.withOpacity(0.8),
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            breadcrumbs.join(' › '),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedItemCard() {
    final selectedItem = controller.selectedItem!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                selectedItem.level.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedItem.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  selectedItem.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
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
  }

  Widget _buildLevelIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                level.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse ${level.displayName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select ${level.displayName.toLowerCase()} to view details',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => TextField(
        controller: searchController,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: controller.selectedItem != null 
            ? 'Search ${controller.selectedItem!.level.nextLevel?.displayName ?? 'items'}...'
            : 'Search ${level.displayName}...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E40AF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.search,
              color: Color(0xFF1E40AF),
              size: 20,
            ),
          ),
          suffixIcon: controller.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Color(0xFF64748B),
                ),
                onPressed: () {
                  searchController.clear();
                  controller.clearSearch();
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (query) {
          if (controller.selectedItem != null) {
            final nextLevel = controller.selectedItem!.level.nextLevel;
            if (nextLevel != null) {
              controller.searchWithDebounce(query, nextLevel, parentId: controller.selectedItem!.id);
            }
          } else {
            controller.searchWithDebounce(query, level);
          }
        },
      )),
    );
  }

  Widget _buildContent() {
    if (controller.isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SkeletonLoader.listItemSkeleton(),
          ),
          childCount: 5,
        ),
      );
    }

    final itemsToShow = controller.selectedItem != null 
      ? controller.childItems 
      : controller.currentItems;

    if (itemsToShow.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = itemsToShow[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildItemCard(item),
          );
        },
        childCount: itemsToShow.length,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1E40AF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              controller.searchQuery.isNotEmpty 
                ? Icons.search_off 
                : Icons.inventory_2_outlined,
              size: 60,
              color: const Color(0xFF1E40AF).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            controller.searchQuery.isNotEmpty 
              ? 'No results found'
              : 'No items available',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.isNotEmpty 
              ? 'Try adjusting your search terms'
              : 'Items will appear here when available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(ListItem item) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _handleItemTap(item),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E40AF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              item.level.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Arrow
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E40AF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Color(0xFF1E40AF),
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

  void _handleItemTap(ListItem item) {
    if (item.level == ListLevel.product) {
      Get.to(() => const ProductDetailPage(), arguments: item);
    } else {
      final nextLevel = item.level.nextLevel;
      if (nextLevel != null) {
        Get.to(
          () => const ListPage(),
          arguments: ListArguments(
            level: nextLevel,
            parentItem: item,
          ).toMap(),
        );
      } else {
        Get.snackbar(
          'Info',
          'No more levels available',
          backgroundColor: const Color(0xFF1E40AF).withOpacity(0.1),
          colorText: const Color(0xFF1E40AF),
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}