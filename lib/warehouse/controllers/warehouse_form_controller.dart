import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/warehouse_detail_model.dart';
import '../services/warehouse_service.dart';
import '../../core/widgets/base_form_page.dart';
import '../../core/widgets/custom_snackbar.dart';
import '../../core/widgets/location_form_widget.dart';

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

  late final LocationFormController _locationController;

  @override
  void onInit() {
    super.onInit();
    _warehouseService = Get.find<WarehouseService>();

    // Initialize location controller with unique tag
    _locationController = Get.put(LocationFormController(), tag: 'warehouse_location');

    _initializeFormData();
    _setupFormListeners();

    // Load branches and populate form immediately (no delay!)
    _loadBranches();
  }

  LocationFormController get locationController => _locationController;

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

    // Listen to location changes
    ever(_locationController.selectedProvince, (_) => markFormAsDirty());
    ever(_locationController.selectedDistrict, (_) => markFormAsDirty());
    ever(_locationController.selectedSubdistrict, (_) => markFormAsDirty());
    ever(_locationController.selectedWard, (_) => markFormAsDirty());
    ever(_locationController.selectedZipcode, (_) => markFormAsDirty());
  }


  void _initializeFormData() {
    final arguments = Get.arguments as Map<String, dynamic>?;

    if (arguments != null && arguments['warehouse'] != null) {
      _existingWarehouse = arguments['warehouse'] as WarehouseDetail;
    }
  }

  Future<void> _populateFormWithExistingData() async {
    if (_existingWarehouse == null) return;

    // Populate text fields immediately (no delay)
    nameController.text = _existingWarehouse!.name;
    codeController.text = _existingWarehouse!.codeId ?? '';
    descriptionController.text = _existingWarehouse!.description;
    addressController.text = _existingWarehouse!.address ?? '';
    picNameController.text = _existingWarehouse!.picName ?? '';
    picContactController.text = _existingWarehouse!.picContact ?? '';
    noteController.text = _existingWarehouse!.note ?? '';

    selectedBranchId.value = _existingWarehouse!.branchId;

    // Load location data in parallel (optimized!)
    await _locationController.loadExistingLocation(
      provinceId: _existingWarehouse!.provinceId,
      districtId: _existingWarehouse!.districtId,
      subdistrictId: _existingWarehouse!.subdistrictId,
      wardId: _existingWarehouse!.wardId,
      zipcodeId: _existingWarehouse!.zipcodeId,
    );
  }

  Future<void> _loadBranches() async {
    try {
      // You can implement branch endpoint later or use fallback data
      _setFallbackBranches();
    } catch (e) {
      _setFallbackBranches();
    }

    // Populate form immediately after branches are loaded
    if (_existingWarehouse != null) {
      await _populateFormWithExistingData();
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

      // Get location data from location controller
      final locationData = _locationController.getLocationData();

      // DEBUG: Log location data being sent
      print('📍 Location Data: $locationData');
      print('📍 Province: ${_locationController.selectedProvince.value?.id} - ${_locationController.selectedProvince.value?.name}');
      print('📍 District: ${_locationController.selectedDistrict.value?.id} - ${_locationController.selectedDistrict.value?.name}');
      print('📍 Subdistrict: ${_locationController.selectedSubdistrict.value?.id} - ${_locationController.selectedSubdistrict.value?.name}');
      print('📍 Ward: ${_locationController.selectedWard.value?.id} - ${_locationController.selectedWard.value?.name}');
      print('📍 Zipcode: ${_locationController.selectedZipcode.value?.id} - ${_locationController.selectedZipcode.value?.code}');

      final warehouseData = {
        'name': nameController.text.trim(),
        'code_id': codeController.text.trim().isNotEmpty ? codeController.text.trim() : null,
        'description': descriptionController.text.trim(),
        'branch_id': selectedBranchId.value,
        'address': addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
        'pic_name': picNameController.text.trim().isNotEmpty ? picNameController.text.trim() : null,
        'pic_contact': picContactController.text.trim().isNotEmpty ? picContactController.text.trim() : null,
        'note': noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
        ...locationData,
      };

      print('📦 Warehouse Data being sent: $warehouseData');

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
    addressController.clear();
    picNameController.clear();
    picContactController.clear();
    noteController.clear();
    selectedBranchId.value = '';
    errorMessage.value = '';
    _locationController.reset();
    formKey.currentState?.reset();
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
    Get.delete<LocationFormController>(tag: 'warehouse_location');
    super.onClose();
  }
}