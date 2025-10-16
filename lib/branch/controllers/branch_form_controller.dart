import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/branch_detail_model.dart';
import '../services/branch_service.dart';
import '../../list-pages/services/list_service.dart';
import '../../list-pages/models/list_item.dart';
import '../../core/widgets/base_form_page.dart';
import '../../core/widgets/custom_snackbar.dart';
import '../../core/widgets/location_form_widget.dart';

class BranchFormController extends BaseFormController {
  late final BranchService _branchService;
  late final LocationFormController _locationController;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController picNameController = TextEditingController();
  final TextEditingController picContactController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Reactive variables
  final RxString selectedCompanyId = ''.obs;
  final RxList<Map<String, dynamic>> companies = <Map<String, dynamic>>[].obs;

  // Form state
  BranchDetail? _existingBranch;

  @override
  bool get isEditMode => _existingBranch != null;

  @override
  String get pageTitle => isEditMode ? 'Edit Branch' : 'Create Branch';

  @override
  String get entityName => 'Branch';

  @override
  void onInit() {
    super.onInit();
    _branchService = Get.find<BranchService>();

    // Initialize location controller with unique tag
    _locationController = Get.put(
      LocationFormController(),
      tag: 'branch_location',
    );

    _initializeFormData();
    _setupFormListeners();

    // Load companies and populate form immediately (no delay!)
    _loadCompanies();
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

    // Listen to company changes
    ever(selectedCompanyId, (_) => markFormAsDirty());

    // Listen to location changes
    ever(_locationController.selectedProvince, (_) => markFormAsDirty());
    ever(_locationController.selectedDistrict, (_) => markFormAsDirty());
    ever(_locationController.selectedSubdistrict, (_) => markFormAsDirty());
    ever(_locationController.selectedWard, (_) => markFormAsDirty());
    ever(_locationController.selectedZipcode, (_) => markFormAsDirty());
  }

  void _initializeFormData() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    String? branchId = arguments?['id'] as String?;

    if (branchId != null) {
      _loadBranchData(branchId);
    } else if (arguments?['branch'] != null) {
      _existingBranch = arguments!['branch'] as BranchDetail;
      _populateFormWithExistingData();
    }
  }

  Future<void> _loadBranchData(String branchId) async {
    try {
      isLoading.value = true;
      final branch = await _branchService.getBranchDetail(branchId);
      if (branch != null) {
        _existingBranch = branch;
        await _populateFormWithExistingData();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error loading branch data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _populateFormWithExistingData() async {
    if (_existingBranch == null) return;

    // Populate text fields immediately (no delay)
    nameController.text = _existingBranch!.name;
    codeController.text = _existingBranch!.codeId ?? '';
    descriptionController.text = _existingBranch!.description;
    addressController.text = _existingBranch!.address ?? '';
    picNameController.text = _existingBranch!.picName ?? '';
    picContactController.text = _existingBranch!.picContact ?? '';
    noteController.text = _existingBranch!.note ?? '';

    selectedCompanyId.value = _existingBranch!.companyId;

    // Load location data in parallel (optimized!)
    await _locationController.loadExistingLocation(
      provinceId: _existingBranch!.provinceId,
      districtId: _existingBranch!.districtId,
      subdistrictId: _existingBranch!.subdistrictId,
      wardId: _existingBranch!.wardId,
      zipcodeId: _existingBranch!.zipcodeId,
    );
  }

  Future<void> _loadCompanies() async {
    try {
      final listService = Get.find<ListService>();
      final companyList = await listService.getItemsByLevel(ListLevel.company);

      if (companyList.isNotEmpty) {
        companies.value =
            companyList
                .map((company) => {'id': company.id, 'name': company.name})
                .toList();
      } else {
        _setFallbackCompanies();
      }
    } catch (e) {
      print('Error loading companies: $e');
      _setFallbackCompanies();
    }

    // Populate form immediately after companies are loaded
    if (_existingBranch != null) {
      await _populateFormWithExistingData();
    }
  }

  void _setFallbackCompanies() {
    if (_existingBranch != null) {
      // In edit mode, make sure we have the actual company in the list
      companies.value = [
        {'id': _existingBranch!.companyId, 'name': 'Selected Company'},
      ];
    } else {
      // In create mode, use test data
      companies.value = [
        {'id': '1', 'name': 'Tech Corp'},
        {'id': '2', 'name': 'Manufacturing Ltd'},
        {'id': '3', 'name': 'Retail Solutions'},
        {'id': '4', 'name': 'Services Inc'},
      ];
    }
  }

  @override
  List<String> getValidationErrors() {
    List<String> errors = [];

    if (nameController.text.trim().isEmpty) {
      errors.add('Branch Name');
    }
    if (descriptionController.text.trim().isEmpty) {
      errors.add('Description');
    }
    if (selectedCompanyId.value.isEmpty) {
      errors.add('Company');
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

      final branchData = {
        'name': nameController.text.trim(),
        'code_id':
            codeController.text.trim().isNotEmpty
                ? codeController.text.trim()
                : null,
        'description': descriptionController.text.trim(),
        'company_id': selectedCompanyId.value,
        'address':
            addressController.text.trim().isNotEmpty
                ? addressController.text.trim()
                : null,
        'pic_name':
            picNameController.text.trim().isNotEmpty
                ? picNameController.text.trim()
                : null,
        'pic_contact':
            picContactController.text.trim().isNotEmpty
                ? picContactController.text.trim()
                : null,
        'note':
            noteController.text.trim().isNotEmpty
                ? noteController.text.trim()
                : null,
        ...locationData,
      };

      print('Branch Data being sent: $branchData');

      if (isEditMode) {
        await _branchService.updateBranch(_existingBranch!.id, branchData);
      } else {
        await _branchService.createBranch(branchData);
      }

      // Mark form as clean and navigate back with success result
      markFormAsClean();
      Get.back(result: true);
    } catch (e) {
      errorMessage.value = 'Failed to save branch: ${e.toString()}';
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
    selectedCompanyId.value = '';
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
    Get.delete<LocationFormController>(tag: 'branch_location');
    super.onClose();
  }
}
