import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/list_item.dart';
import '../services/list_service.dart';
import '../../routes/app_pages.dart';
import '../models/list_arguments.dart';

class CategoryListController extends GetxController {
  final ListService _listService = ListService();

  // Observable state variables
  final RxList<ListItem> allItems = <ListItem>[].obs;
  final RxList<ListItem> filteredItems = <ListItem>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  
  // Current level being displayed
  late final ListLevel currentLevel;

  @override
  void onInit() {
    super.onInit();
    
    // Get level from route arguments
    final levelArg = Get.arguments;
    if (levelArg is ListLevel) {
      currentLevel = levelArg;
    } else if (levelArg is String) {
      currentLevel = ListLevel.values.firstWhere((e) => e.name == levelArg);
    } else {
      currentLevel = ListLevel.company; // Default fallback
    }
    
    // Set up search listener
    searchQuery.listen(_filterItems);
    
    // Load items on initialization
    loadItems();
  }

  /// Load items from API for the current level
  Future<void> loadItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final items = await _listService.getItemsByLevel(currentLevel);
      
      allItems.assignAll(items);
      _filterItems(searchQuery.value);
      
    } catch (e) {
      errorMessage.value = 'Failed to load ${currentLevel.displayName}s. Please try again.';
      print('Error loading items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter items based on search query
  void _filterItems(String query) {
    if (query.isEmpty) {
      filteredItems.assignAll(allItems);
    } else {
      final filtered = allItems.where((item) {
        final queryLower = query.toLowerCase();
        return item.name.toLowerCase().contains(queryLower) ||
               item.code.toLowerCase().contains(queryLower) ||
               item.description.toLowerCase().contains(queryLower);
      }).toList();
      filteredItems.assignAll(filtered);
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Navigate to appropriate page based on item level
  void navigateToDetail(ListItem item) {
    if (item.level == ListLevel.product) {
      // Navigate directly to ProductDetailPage for products
      Get.toNamed(Routes.PRODUCT_DETAIL, arguments: item);
    } else {
      // Navigate to ListPage with the item as selectedItem for company/branch/warehouse
      final nextLevel = item.level.nextLevel;
      if (nextLevel != null) {
        final args = ListArguments(
          level: nextLevel,
          parentItem: item,
        );
        Get.toNamed(Routes.LIST, arguments: args.toMap());
      }
    }
  }

  /// Refresh items (pull-to-refresh)
  Future<void> refreshItems() async {
    await loadItems();
  }

  /// Get title for the page based on current level
  String get pageTitle {
    switch (currentLevel) {
      case ListLevel.company:
        return 'Companies';
      case ListLevel.branch:
        return 'Branches';
      case ListLevel.warehouse:
        return 'Warehouses';
      case ListLevel.product:
        return 'Products';
    }
  }

  /// Get search placeholder text
  String get searchPlaceholder {
    return 'Search ${currentLevel.displayName.toLowerCase()}s...';
  }

  /// Get icon for current level
  IconData get levelIcon {
    switch (currentLevel) {
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

  /// Get color for current level
  Color get levelColor {
    switch (currentLevel) {
      case ListLevel.company:
        return const Color(0xFF1A56DB); // AppTheme.primary
      case ListLevel.branch:
        return const Color(0xFF10B981); // AppTheme.success
      case ListLevel.warehouse:
        return const Color(0xFFF59E0B); // AppTheme.warning
      case ListLevel.product:
        return const Color(0xFF8B5CF6); // Purple
    }
  }
}