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
import '../../core/services/navigation_stack_manager.dart';

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

  final NavigationStackManager _navigationManager = Get.find<NavigationStackManager>();

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
  ListLevel? get currentLevel => _navigationManager.currentLevel ?? 
      (currentItems.isNotEmpty ? currentItems.first.level : null);

  /// Load root level items (e.g., all companies)
  Future<void> loadRootItems(ListLevel level) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      selectedItem.value = null;
      selectedDetail.value = null;
      childItems.clear();
      _navigationManager.clear();

      // Add minimum loading time to show loading state
      final loadingFuture = _listService.getItemsByLevel(level);
      final minimumDelay = Future.delayed(const Duration(milliseconds: 800));

      await Future.wait([loadingFuture, minimumDelay]).then((results) {
        final items = results[0] as List<ListItem>;
        currentItems.value = items;
        // If we have items, automatically select the first one and show its detail
        if (items.isNotEmpty) {
          selectedItem.value = items.first;
          selectItemAndValidate(items.first);
        }
        isShowingDetail.value = true; // Always show detail view first
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

      selectedItem.value = parentItem;
      selectedDetail.value = null;
      childItems.clear();
      isLoadingDetail.value = true;

      final List<Future> futures = [];
      final nextLevel = parentItem.level.nextLevel;
      
      if (nextLevel != null) {
        futures.add(_listService.getChildrenByLevel(parentItem.id, nextLevel));
      }
      
      futures.add(_fetchDetailByLevel(parentItem.id, parentItem.level));
      futures.add(Future.delayed(const Duration(milliseconds: 600)));

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

            if (results.length > 1) {
              selectedDetail.value = results[results.length - 2];
            }
            
            if (addToStack) {
              _navigationManager.pushPage(
                selectedItem: selectedItem.value,
                currentItems: currentItems,
                childItems: childItems,
                selectedDetail: selectedDetail.value,
                level: parentItem.level,
                isShowingDetail: isShowingDetail.value,
              );
            }
          });

      isShowingDetail.value = true; // Always show detail view first, user can toggle to list
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
    final result = await Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product);
    
    // Handle post-navigation actions
    if (result != null) {
      if (result is bool && result == true) {
        // Data was modified, refresh the current view
        await refresh();
      } else if (result is Map && result['showDetailFirst'] == true) {
        // Show detail view
        isShowingDetail.value = true;
      }
    }
  }

  Future<void> navigateBack() async {
    if (_navigationManager.canGoBack()) {
      final poppedPage = _navigationManager.popPage();
      
      if (poppedPage != null) {
        isLoading.value = true;
        
        try {
          if (poppedPage.isStale) {
            await _restoreStalePageState(poppedPage);
          } else {
            _restoreFreshPageState(poppedPage);
          }
        } finally {
          isLoading.value = false;
        }
      } else {
        final rootLevel = _navigationManager.rootLevel;
        if (rootLevel != null) {
          await loadRootItems(rootLevel);
        }
      }
    } else {
      Get.back();
    }
  }

  /// Clear selection and back to detail view (auto-select first item)
  void clearSelection() {
    selectedItem.value = null;
    selectedDetail.value = null;
    childItems.clear();
    isShowingDetail.value = true;
    detailError.value = null;
    errorMessage.value = null;
    _navigationManager.clear();
    
    // Auto-select the first item if available
    if (currentItems.isNotEmpty) {
      selectedItem.value = currentItems.first;
      selectItemAndValidate(currentItems.first);
    }
  }

  /// Unified retry method - simpler approach
  Future<void> retry() async {
    if (selectedItem.value != null) {
      // Retry loading the selected item and its details - don't add to stack
      await loadItemWithChildren(selectedItem.value!, addToStack: false);
    } else if (currentLevel != null) {
      // Retry loading root items
      await loadRootItems(currentLevel!);
    }
  }

  /// Refresh current data
  Future<void> refresh() async {
    if (selectedItem.value != null) {
      // Refresh children data - don't add to stack
      await loadItemWithChildren(selectedItem.value!, addToStack: false);
    } else if (currentItems.isNotEmpty) {
      // Refresh root items
      final level = currentItems.first.level;
      await loadRootItems(level);
    }
  }

  /// Handle data modifications and refresh accordingly
  Future<void> handleDataModification({bool itemDeleted = false}) async {
    if (itemDeleted && selectedItem.value != null) {
      // If current item was deleted, go back to parent level
      await navigateBack();
    } else {
      // Otherwise just refresh current data
      await refresh();
    }
  }

  /// Restore fresh page state instantly (no API calls)
  void _restoreFreshPageState(PageState pageState) {
    selectedItem.value = pageState.selectedItem;
    currentItems.value = pageState.currentItems;
    childItems.value = pageState.childItems;
    selectedDetail.value = pageState.selectedDetail;
    isShowingDetail.value = true; // Always show detail first regardless of previous state
    errorMessage.value = null;
    detailError.value = null;
  }
  
  /// Restore stale page state with complete data refresh
  Future<void> _restoreStalePageState(PageState pageState) async {
    errorMessage.value = null;
    detailError.value = null;
    
    if (pageState.selectedItem != null) {
      // Scenario: User was viewing children of selectedItem
      // Need to restore: currentItems + childItems + selectedDetail
      await _restoreHierarchicalLevel(pageState);
    } else {
      // Scenario: User was at root level
      // Need to restore: currentItems only
      await _restoreRootLevel(pageState.level);
    }
  }
  
  /// Restore hierarchical level with complete data
  Future<void> _restoreHierarchicalLevel(PageState pageState) async {
    final selectedItemData = pageState.selectedItem!;
    selectedItem.value = selectedItemData;
    
    // Create futures for parallel loading
    final List<Future> futures = [];
    
    // 1. Fetch currentItems (parent level items that contain selectedItem)
    final parentLevel = _getParentLevel(selectedItemData.level);
    if (parentLevel != null) {
      // Find the parent container for selectedItem
      futures.add(_fetchParentLevelItems(selectedItemData, parentLevel));
    }
    
    // 2. Fetch childItems (children of selectedItem)
    final nextLevel = selectedItemData.level.nextLevel;
    if (nextLevel != null) {
      futures.add(_listService.getChildrenByLevel(selectedItemData.id, nextLevel));
    }
    
    // 3. Fetch selectedDetail (detail of selectedItem)
    futures.add(_fetchDetailByLevel(selectedItemData.id, selectedItemData.level));
    
    // 4. Add minimum loading time
    futures.add(Future.delayed(const Duration(milliseconds: 600)));
    
    try {
      final results = await Future.wait(futures).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Loading timeout after 15 seconds');
        },
      );
      
      int resultIndex = 0;
      
      // Process parent level items
      if (parentLevel != null) {
        final parentItems = results[resultIndex] as List<ListItem>;
        currentItems.value = parentItems;
        resultIndex++;
      }
      
      // Process child items
      if (nextLevel != null) {
        final children = results[resultIndex] as List<ListItem>;
        childItems.value = children;
        resultIndex++;
      } else {
        childItems.clear();
      }
      
      // Process selected detail
      selectedDetail.value = results[resultIndex];
      
      // Restore UI state - always show detail first
      isShowingDetail.value = true;
      
    } catch (e) {
      errorMessage.value = NetworkHelper.getUserFriendlyErrorMessage(e);
      print('Error restoring stale page state: $e');
    }
  }
  
  /// Restore root level items
  Future<void> _restoreRootLevel(ListLevel level) async {
    selectedItem.value = null;
    selectedDetail.value = null;
    childItems.clear();
    isShowingDetail.value = true;
    
    try {
      final loadingFuture = _listService.getItemsByLevel(level);
      final minimumDelay = Future.delayed(const Duration(milliseconds: 600));
      
      await Future.wait([loadingFuture, minimumDelay]).then((results) {
        final items = results[0] as List<ListItem>;
        currentItems.value = items;
        // Auto-select the first item and show its detail
        if (items.isNotEmpty) {
          selectedItem.value = items.first;
          selectItemAndValidate(items.first);
        }
      });
    } catch (e) {
      errorMessage.value = NetworkHelper.getUserFriendlyErrorMessage(e);
      currentItems.clear();
      print('Error restoring root level: $e');
    }
  }
  
  /// Fetch parent level items that contain the given item
  Future<List<ListItem>> _fetchParentLevelItems(ListItem childItem, ListLevel parentLevel) async {
    // If we know the parentId, we can fetch siblings directly
    if (childItem.parentId != null) {
      return await _listService.getChildrenByLevel(childItem.parentId!, childItem.level);
    }
    
    // Fallback: fetch all items at parent level (less efficient but works)
    return await _listService.getItemsByLevel(parentLevel);
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
