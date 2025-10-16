import 'package:get/get.dart';
import '../../list-pages/models/list_item.dart';
import '../../list-pages/services/list_service.dart';
import '../models/home_menu_item.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Controller for managing home page state and business logic
class HomeController extends GetxController {
  final ListService _listService = ListService();

  // Observable state
  final RxList<HomeMenuItem> menuItems = <HomeMenuItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeMenuItems();
    loadCounts();
  }

  /// Initialize menu items with default configuration
  void _initializeMenuItems() {
    menuItems.value = [
      HomeMenuItem(
        name: 'Companies',
        level: ListLevel.company,
        icon: Icons.business_outlined,
        color: AppTheme.primary,
      ),
      HomeMenuItem(
        name: 'Branches',
        level: ListLevel.branch,
        icon: Icons.store_outlined,
        color: AppTheme.success,
      ),
      HomeMenuItem(
        name: 'Warehouses',
        level: ListLevel.warehouse,
        icon: Icons.warehouse_outlined,
        color: AppTheme.warning,
      ),
      HomeMenuItem(
        name: 'Products',
        level: ListLevel.product,
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF8B5CF6),
      ),
    ];
  }

  /// Load counts from API for all menu items
  Future<void> loadCounts() async {
    try {
      isLoading.value = true;

      // Load counts for each level concurrently
      final futures = menuItems.map((item) async {
        final items = await _listService.getItemsByLevel(item.level);
        return items.length;
      }).toList();

      final counts = await Future.wait(futures);

      // Update menu items with counts
      for (int i = 0; i < menuItems.length; i++) {
        menuItems[i] = menuItems[i].copyWith(count: counts[i]);
      }
    } catch (e) {
      print('Error loading counts: $e');
      // Keep default counts on error
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh counts (for pull-to-refresh)
  Future<void> refreshCounts() async {
    await loadCounts();
  }
}
