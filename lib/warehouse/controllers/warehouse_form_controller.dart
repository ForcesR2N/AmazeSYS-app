import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/warehouse_detail_model.dart';
import '../services/warehouse_service.dart';
import '../../core/widgets/base_form_page.dart';
import '../../core/widgets/custom_snackbar.dart';

class WarehouseFormController extends BaseFormController {
  late final WarehouseService _warehouseService;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController picNameController = TextEditingController();
  final TextEditingController picContactController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Reactive variables
  final RxString selectedBranchId = ''.obs;
  final RxList<Map<String, dynamic>> branches = <Map<String, dynamic>>[].obs;

  // Form state
  WarehouseDetail? _existingWarehouse;

  @override
  bool get isEditMode => _existingWarehouse != null;

  @override
  String get pageTitle => isEditMode ? 'Edit Warehouse' : 'Create Warehouse';

  @override
  String get entityName => 'Warehouse';

  @override
  void onInit() {
    super.onInit();
    _warehouseService = Get.find<WarehouseService>();
    _initializeFormData();
    _loadBranches();
    _setupFormListeners();

    // Ensure form population for edit mode
    if (_existingWarehouse != null) {
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
    addressController.addListener(() => markFormAsDirty());
    picNameController.addListener(() => markFormAsDirty());
    picContactController.addListener(() => markFormAsDirty());
    noteController.addListener(() => markFormAsDirty());

    // Listen to branch changes
    ever(selectedBranchId, (_) => markFormAsDirty());
  }

  @override
  void onClose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    picNameController.dispose();
    picContactController.dispose();
    noteController.dispose();
    super.onClose();
  }

  void _initializeFormData() {
    final arguments = Get.arguments as Map<String, dynamic>?;

    if (arguments != null && arguments['warehouse'] != null) {
      _existingWarehouse = arguments['warehouse'] as WarehouseDetail;
    }
  }

  void _populateFormWithExistingData() {
    if (_existingWarehouse == null) return;

    nameController.text = _existingWarehouse!.name;
    codeController.text = _existingWarehouse!.codeId ?? '';
    descriptionController.text = _existingWarehouse!.description;
    addressController.text = _existingWarehouse!.address ?? '';
    picNameController.text = _existingWarehouse!.picName ?? '';
    picContactController.text = _existingWarehouse!.picContact ?? '';
    noteController.text = _existingWarehouse!.note ?? '';

    selectedBranchId.value = _existingWarehouse!.branchId;
  }

  Future<void> _loadBranches() async {
    try {
      // You can implement branch endpoint later or use fallback data
      _setFallbackBranches();
    } catch (e) {
      _setFallbackBranches();
    }

    if (_existingWarehouse != null) {
      _populateFormWithExistingData();
    }
  }

  void _setFallbackBranches() {
    branches.value = [
      {'id': '1', 'name': 'Head Office'},
      {'id': '2', 'name': 'Branch A'},
      {'id': '3', 'name': 'Branch B'},
      {'id': '4', 'name': 'Branch C'},
    ];
  }

  @override
  List<String> getValidationErrors() {
    List<String> errors = [];

    if (nameController.text.trim().isEmpty) {
      errors.add('Warehouse Name');
    }
    if (descriptionController.text.trim().isEmpty) {
      errors.add('Description');
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

      final warehouseData = {
        'name': nameController.text.trim(),
        'code_id': codeController.text.trim().isNotEmpty ? codeController.text.trim() : null,
        'description': descriptionController.text.trim(),
        'branch_id': selectedBranchId.value,
        'address': addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
        'pic_name': picNameController.text.trim().isNotEmpty ? picNameController.text.trim() : null,
        'pic_contact': picContactController.text.trim().isNotEmpty ? picContactController.text.trim() : null,
        'note': noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
      };

      if (isEditMode) {
        await _warehouseService.updateWarehouse(_existingWarehouse!.id, warehouseData);
      } else {
        await _warehouseService.createWarehouse(warehouseData);
      }

      // Mark form as clean and navigate back with success result
      markFormAsClean();
      Get.back(result: true);
    } catch (e) {
      errorMessage.value = 'Failed to save warehouse: ${e.toString()}';
      CustomSnackbar.error(title: 'Error', message: errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void resetForm() {
    nameController.clear();
    codeController.clear();
    descriptionController.clear();
    addressController.clear();
    picNameController.clear();
    picContactController.clear();
    noteController.clear();
    selectedBranchId.value = '';
    errorMessage.value = '';
    formKey.currentState?.reset();
  }
}