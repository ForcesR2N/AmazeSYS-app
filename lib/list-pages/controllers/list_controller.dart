import 'package:get/get.dart';
import '../models/list_item.dart';
import '../../company/models/company_detail_model.dart';
import '../../branch/models/branch_detail_model.dart';
import '../../warehouse/models/warehouse_detail_model.dart';
import '../../product/models/product_detail_model.dart';
import '../services/list_service.dart';
import '../../company/services/company_service.dart';
import '../../branch/services/branch_service.dart';
import '../../warehouse/services/warehouse_service.dart';
import '../../product/services/product_service.dart';
import '../../utils/network_helper.dart';
import '../../routes/app_pages.dart';
import '../../core/theme/app_theme.dart';

class ListController extends GetxController {
  final ListService _listService = ListService();
  final CompanyService _companyService = CompanyService();
  final BranchService _branchService = BranchService();
  final WarehouseService _warehouseService = WarehouseService();
  final ProductService _productService = ProductService();

  // List data
  final RxList<ListItem> currentItems = <ListItem>[].obs;
  final RxList<ListItem> childItems = <ListItem>[].obs;
  final Rxn<ListItem> selectedItem = Rxn<ListItem>();

  // Navigation stack to track parent items for proper back navigation
  final List<ListItem> _navigationStack = [];

  // Detail data
  final Rxn<dynamic> selectedDetail = Rxn<dynamic>();
  final RxBool isLoadingDetail = false.obs;
  final RxnString detailError = RxnString();

  // View state
  final RxBool isShowingDetail = false.obs;

  // General
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxnString errorMessage = RxnString();

  // Computed getters
  List<ListItem> get displayItems =>
      selectedItem.value != null ? childItems : currentItems;
  ListLevel? get currentLevel =>
      selectedItem.value?.level.nextLevel ??
      (currentItems.isNotEmpty ? currentItems.first.level : null);

  /// Load root level items (e.g., all companies)
  Future<void> loadRootItems(ListLevel level) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      selectedItem.value = null;
      selectedDetail.value = null;
      childItems.clear();
      _navigationStack
          .clear(); // Clear navigation stack when loading root items

      // Add minimum loading time to show loading state
      final loadingFuture = _listService.getItemsByLevel(level);
      final minimumDelay = Future.delayed(const Duration(milliseconds: 800));

      await Future.wait([loadingFuture, minimumDelay]).then((results) {
        final items = results[0] as List<ListItem>;
        currentItems.value = items;
        isShowingDetail.value = false; // Show list view first
      });
    } catch (e) {
      errorMessage.value = NetworkHelper.getUserFriendlyErrorMessage(e);
      currentItems.clear();
      print('Error loading root items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load children of a parent item
  Future<void> loadItemWithChildren(
    ListItem parentItem, {
    bool addToStack = true,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // Add current parent to navigation stack for back navigation (only if not coming from back navigation)
      if (addToStack) {
        _navigationStack.add(parentItem);
      }

      selectedItem.value = parentItem; // Set context
      selectedDetail.value = null;
      childItems.clear();
      isLoadingDetail.value = true;

      // Create futures for both children and parent detail
      final List<Future> futures = [];

      final nextLevel = parentItem.level.nextLevel;
      if (nextLevel != null) {
        futures.add(_listService.getChildrenByLevel(parentItem.id, nextLevel));
      }

      // Also load the parent item's detail
      futures.add(_fetchDetailByLevel(parentItem.id, parentItem.level));

      // Add minimum loading time to show loading state
      futures.add(Future.delayed(const Duration(milliseconds: 600)));

      // Add timeout for the entire operation (15 seconds best practice)
      await Future.wait(futures)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Loading timeout after 15 seconds');
            },
          )
          .then((results) {
            if (nextLevel != null && results.isNotEmpty) {
              final children = results[0] as List<ListItem>;
              childItems.value = children;
            }

            // Set the parent detail (second future result)
            if (results.length > 1) {
              selectedDetail.value =
                  results[results.length -
                      2]; // Detail is second-to-last (before delay)
            }
          });

      isShowingDetail.value =
          false; // Show list view first, user can toggle to detail
    } catch (e) {
      errorMessage.value = NetworkHelper.getUserFriendlyErrorMessage(e);
      childItems.clear();
      print('Error loading children: $e');
    } finally {
      isLoading.value = false;
      isLoadingDetail.value = false; // Clear detail loading state
    }
  }

  /// User taps item (non-product), fetch detail and validate
  Future<void> selectItemAndValidate(ListItem item) async {
    selectedItem.value = item;
    isLoadingDetail.value = true;
    detailError.value = null;

    try {
      // Add minimum loading time to show loading state
      final detailFuture = _fetchDetailByLevel(item.id, item.level);
      final minimumDelay = Future.delayed(const Duration(milliseconds: 500));

      final results = await Future.wait([detailFuture, minimumDelay]).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Detail loading timeout after 15 seconds');
        },
      );
      final detail = results[0];

      // Set the detail regardless of whether it's null or not
      selectedDetail.value = detail;

      if (detail != null) {
        print('✅ Company detail loaded successfully: ${detail.toString()}');
      } else {
        print(
          '⚠️ Company detail is null - will show "no data available" screen',
        );
      }
    } catch (e) {
      print('💥 Exception during detail loading: $e');
      // Don't set error state, just keep the detail tab available
      // The UI will show "no data available" if selectedDetail is null
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Toggle between detail and list view
  void toggleView() {
    isShowingDetail.value = !isShowingDetail.value;

    // If switching to detail view and no detail loaded yet, load it
    if (isShowingDetail.value &&
        selectedItem.value != null &&
        selectedDetail.value == null &&
        !isLoadingDetail.value) {
      selectItemAndValidate(selectedItem.value!);
    }
  }

  /// Navigate to ProductDetailPage
  Future<void> navigateToProductDetail(ListItem product) async {
    // Navigate to ProductDetailPage and pass product as argument
    Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product);
  }

  /// Smart hierarchical back navigation
  Future<void> navigateBack() async {
    if (_navigationStack.isNotEmpty) {
      // Pop the current item from stack
      _navigationStack.removeLast();

      if (_navigationStack.isNotEmpty) {
        // If there's still a parent in stack, go back to that parent's level
        final parentItem = _navigationStack.last;
        await loadItemWithChildren(parentItem, addToStack: false);
      } else {
        // If stack is empty, go back to root level (currentItems)
        selectedItem.value = null;
        selectedDetail.value = null;
        childItems.clear();
        isShowingDetail.value = false;
        detailError.value = null;
        errorMessage.value = null;

        // Show the root level items that should be in currentItems
        if (currentItems.isEmpty && currentLevel != null) {
          await loadRootItems(currentLevel!);
        }
      }
    } else {
      // If we're at root level, go back to previous page (CategoryListPage)
      Get.back();
    }
  }

  /// Get parent level for hierarchical navigation
  ListLevel? _getParentLevel(ListLevel currentLevel) {
    switch (currentLevel) {
      case ListLevel.product:
        return ListLevel.warehouse;
      case ListLevel.warehouse:
        return ListLevel.branch;
      case ListLevel.branch:
        return ListLevel.company;
      case ListLevel.company:
        return null; // Company is root level
    }
  }

  /// Clear selection and back to list view
  void clearSelection() {
    selectedItem.value = null;
    selectedDetail.value = null;
    childItems.clear();
    isShowingDetail.value = false;
    detailError.value = null;
    errorMessage.value = null;
    _navigationStack.clear(); // Clear navigation stack
  }

  /// Unified retry method - simpler approach
  Future<void> retry() async {
    if (selectedItem.value != null) {
      // Retry loading the selected item and its details
      await loadItemWithChildren(selectedItem.value!);
    } else if (currentLevel != null) {
      // Retry loading root items
      await loadRootItems(currentLevel!);
    }
  }

  /// Refresh current data
  Future<void> refresh() async {
    if (selectedItem.value != null) {
      // Refresh children data
      await loadItemWithChildren(selectedItem.value!);
    } else if (currentItems.isNotEmpty) {
      // Refresh root items
      final level = currentItems.first.level;
      await loadRootItems(level);
    }
  }

  /// Fetch full detail based on level
  Future<dynamic> _fetchDetailByLevel(String id, ListLevel level) async {
    switch (level) {
      case ListLevel.company:
        return await _companyService.getCompanyDetail(id);
      case ListLevel.branch:
        return await _branchService.getBranchDetail(id);
      case ListLevel.warehouse:
        return await _warehouseService.getWarehouseDetail(id);
      case ListLevel.product:
        throw Exception('Product details should use ProductDetailPage');
    }
  }
}
