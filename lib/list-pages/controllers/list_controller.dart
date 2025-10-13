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
  
  // Detail data
  final Rxn<dynamic> selectedDetail = Rxn<dynamic>();
  final RxBool isLoadingDetail = false.obs;
  final RxnString detailError = RxnString();
  
  // View state
  final RxBool isShowingDetail = false.obs;
  final RxBool hasValidDetails = false.obs;
  
  // General
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxnString errorMessage = RxnString();
  
  // Computed getters
  List<ListItem> get displayItems => selectedItem.value != null ? childItems : currentItems;
  bool get canToggleDetail => hasValidDetails.value;
  ListLevel? get currentLevel => selectedItem.value?.level.nextLevel ?? (currentItems.isNotEmpty ? currentItems.first.level : null);

  /// Load root level items (e.g., all companies)
  Future<void> loadRootItems(ListLevel level) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      selectedItem.value = null;
      selectedDetail.value = null;
      childItems.clear();
      
      // Add minimum loading time to show loading state
      final loadingFuture = _listService.getItemsByLevel(level);
      final minimumDelay = Future.delayed(const Duration(milliseconds: 800));
      
      await Future.wait([loadingFuture, minimumDelay]).then((results) {
        final items = results[0] as List<ListItem>;
        currentItems.value = items;
        isShowingDetail.value = false; // Show list
        hasValidDetails.value = false;
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
  Future<void> loadItemWithChildren(ListItem parentItem) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      selectedItem.value = parentItem; // Set context
      selectedDetail.value = null;
      childItems.clear();
      
      final nextLevel = parentItem.level.nextLevel;
      if (nextLevel != null) {
        // Add minimum loading time to show loading state
        final loadingFuture = _listService.getChildrenByLevel(parentItem.id, nextLevel);
        final minimumDelay = Future.delayed(const Duration(milliseconds: 600));
        
        await Future.wait([loadingFuture, minimumDelay]).then((results) {
          final children = results[0] as List<ListItem>;
          childItems.value = children;
        });
      }
      
      isShowingDetail.value = false; // Show children list first
      hasValidDetails.value = false;
    } catch (e) {
      errorMessage.value = NetworkHelper.getUserFriendlyErrorMessage(e);
      childItems.clear();
      print('Error loading children: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// User taps item (non-product), fetch detail and validate
  Future<void> selectItemAndValidate(ListItem item) async {
    selectedItem.value = item;
    isLoadingDetail.value = true;
    detailError.value = null;
    hasValidDetails.value = false;
    
    try {
      // Add minimum loading time to show loading state
      final detailFuture = _fetchDetailByLevel(item.id, item.level);
      final minimumDelay = Future.delayed(const Duration(milliseconds: 500));
      
      await Future.wait([detailFuture, minimumDelay]).then((results) {
        final detail = results[0];
        selectedDetail.value = detail;
        
        final isValid = _validateDetail(detail);
        hasValidDetails.value = isValid;
        
        if (isValid) {
          isShowingDetail.value = true; // Auto show detail
        } else {
          Get.snackbar(
            'Info', 
            'Detail not available for this item',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
          // Stay in list view
        }
      });
    } catch (e) {
      detailError.value = NetworkHelper.getUserFriendlyErrorMessage(e);
      hasValidDetails.value = false;
      print('Error loading detail: $e');
      // Stay in list view
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Toggle between detail and list view
  void toggleView() {
    if (!hasValidDetails.value) {
      Get.snackbar('Info', 'Detail not available');
      return;
    }
    isShowingDetail.value = !isShowingDetail.value;
  }

  /// Navigate to ProductDetailPage
  Future<void> navigateToProductDetail(ListItem product) async {
    // Navigate to ProductDetailPage and pass product as argument
    Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product);
  }

  /// Clear selection and back to list view
  void clearSelection() {
    selectedItem.value = null;
    selectedDetail.value = null;
    childItems.clear();
    isShowingDetail.value = false;
    hasValidDetails.value = false;
    detailError.value = null;
    errorMessage.value = null;
  }

  /// Retry loading root items
  Future<void> retryLoadRootItems() async {
    if (currentItems.isEmpty && !isLoading.value) {
      final level = currentLevel ?? ListLevel.company;
      await loadRootItems(level);
    }
  }

  /// Retry loading children items
  Future<void> retryLoadChildren() async {
    if (selectedItem.value != null && childItems.isEmpty && !isLoading.value) {
      await loadItemWithChildren(selectedItem.value!);
    }
  }

  /// Retry loading detail
  Future<void> retryLoadDetail() async {
    if (selectedItem.value != null && !isLoadingDetail.value) {
      await selectItemAndValidate(selectedItem.value!);
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

  /// Check if detail has required fields
  bool _validateDetail(dynamic detail) {
    return detail != null && 
           detail.name != null && 
           detail.name.toString().isNotEmpty;
  }
}