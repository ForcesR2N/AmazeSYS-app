import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_detail_model.dart';
import '../services/product_service.dart';
import '../../core/widgets/base_form_page.dart';
import '../../core/widgets/custom_snackbar.dart';

class ProductFormController extends BaseFormController {
  late final ProductService _productService;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Reactive variables
  final RxString selectedWarehouseId = ''.obs;
  final RxString selectedBranchId = ''.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxList<Map<String, dynamic>> warehouses = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> branches = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;

  // Form state
  ProductDetail? _existingProduct;

  @override
  bool get isEditMode => _existingProduct != null;

  @override
  String get pageTitle => isEditMode ? 'Edit Product' : 'Create Product';

  @override
  String get entityName => 'Product';

  @override
  void onInit() {
    super.onInit();
    _productService = Get.find<ProductService>();
    _initializeFormData();
    _loadDropdownData();
    _setupFormListeners();

    // Ensure form population for edit mode
    if (_existingProduct != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _populateFormWithExistingData();
      });
    }
  }

  void _setupFormListeners() {
    // Add listeners to text controllers to track changes
    nameController.addListener(() => markFormAsDirty());
    codeController.addListener(() => markFormAsDirty());
    descriptionController.addListener(() => markFormAsDirty());
    noteController.addListener(() => markFormAsDirty());

    // Listen to dropdown changes
    ever(selectedWarehouseId, (_) => markFormAsDirty());
    ever(selectedBranchId, (_) => markFormAsDirty());
    ever(selectedCategoryId, (_) => markFormAsDirty());
  }

  @override
  void onClose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    noteController.dispose();
    super.onClose();
  }

  void _initializeFormData() {
    final arguments = Get.arguments as Map<String, dynamic>?;

    if (arguments != null && arguments['product'] != null) {
      _existingProduct = arguments['product'] as ProductDetail;
    }
  }

  void _populateFormWithExistingData() {
    if (_existingProduct == null) return;

    nameController.text = _existingProduct!.name;
    codeController.text = _existingProduct!.codeId ?? '';
    descriptionController.text = _existingProduct!.description;
    noteController.text = _existingProduct!.note ?? '';

    selectedWarehouseId.value = _existingProduct!.warehouseId;
    selectedBranchId.value = _existingProduct!.branchId;
    if (_existingProduct!.categoryId?.isNotEmpty == true) {
      selectedCategoryId.value = _existingProduct!.categoryId!;
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      // Load warehouses, branches, and categories
      // You can implement these endpoints later or use fallback data
      _setFallbackData();
    } catch (e) {
      _setFallbackData();
    }

    if (_existingProduct != null) {
      _populateFormWithExistingData();
    }
  }

  void _setFallbackData() {
    warehouses.value = [
      {'id': '1', 'name': 'Main Warehouse'},
      {'id': '2', 'name': 'Secondary Warehouse'},
      {'id': '3', 'name': 'Storage Facility A'},
    ];

    branches.value = [
      {'id': '1', 'name': 'Head Office'},
      {'id': '2', 'name': 'Branch A'},
      {'id': '3', 'name': 'Branch B'},
    ];

    categories.value = [
      {'id': '1', 'name': 'Electronics'},
      {'id': '2', 'name': 'Furniture'},
      {'id': '3', 'name': 'Supplies'},
      {'id': '4', 'name': 'Equipment'},
    ];
  }

  @override
  List<String> getValidationErrors() {
    List<String> errors = [];

    if (nameController.text.trim().isEmpty) {
      errors.add('Product Name');
    }
    if (descriptionController.text.trim().isEmpty) {
      errors.add('Description');
    }
    if (selectedWarehouseId.value.isEmpty) {
      errors.add('Warehouse');
    }
    if (selectedBranchId.value.isEmpty) {
      errors.add('Branch');
    }

    return errors;
  }

  @override
  Future<void> saveData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final productData = {
        'name': nameController.text.trim(),
        'code_id': codeController.text.trim().isNotEmpty ? codeController.text.trim() : null,
        'description': descriptionController.text.trim(),
        'warehouse_id': selectedWarehouseId.value,
        'branch_id': selectedBranchId.value,
        'category_id': selectedCategoryId.value.isNotEmpty ? selectedCategoryId.value : null,
        'note': noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
      };

      if (isEditMode) {
        await _productService.updateProduct(_existingProduct!.id, productData);
      } else {
        await _productService.createProduct(productData);
      }

      // Mark form as clean and navigate back with success result
      markFormAsClean();
      Get.back(result: true);
    } catch (e) {
      errorMessage.value = 'Failed to save product: ${e.toString()}';
      CustomSnackbar.error(message: errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void resetForm() {
    nameController.clear();
    codeController.clear();
    descriptionController.clear();
    noteController.clear();
    selectedWarehouseId.value = '';
    selectedBranchId.value = '';
    selectedCategoryId.value = '';
    errorMessage.value = '';
    formKey.currentState?.reset();
  }
}