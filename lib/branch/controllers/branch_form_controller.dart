import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/branch_detail_model.dart';
import '../services/branch_service.dart';
import '../../core/widgets/base_form_page.dart';
import '../../core/widgets/custom_snackbar.dart';

class BranchFormController extends BaseFormController {
  late final BranchService _branchService;

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
    _initializeFormData();
    _loadCompanies();
    _setupFormListeners();

    // Ensure form population for edit mode
    if (_existingBranch != null) {
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

    // Listen to company changes
    ever(selectedCompanyId, (_) => markFormAsDirty());
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

    if (arguments != null && arguments['branch'] != null) {
      _existingBranch = arguments['branch'] as BranchDetail;
    }
  }

  void _populateFormWithExistingData() {
    if (_existingBranch == null) return;

    nameController.text = _existingBranch!.name;
    codeController.text = _existingBranch!.codeId ?? '';
    descriptionController.text = _existingBranch!.description;
    addressController.text = _existingBranch!.address ?? '';
    picNameController.text = _existingBranch!.picName ?? '';
    picContactController.text = _existingBranch!.picContact ?? '';
    noteController.text = _existingBranch!.note ?? '';

    selectedCompanyId.value = _existingBranch!.companyId;
  }

  Future<void> _loadCompanies() async {
    try {
      // You can implement company endpoint later or use fallback data
      _setFallbackCompanies();
    } catch (e) {
      _setFallbackCompanies();
    }

    if (_existingBranch != null) {
      _populateFormWithExistingData();
    }
  }

  void _setFallbackCompanies() {
    companies.value = [
      {'id': '1', 'name': 'Tech Corp'},
      {'id': '2', 'name': 'Manufacturing Ltd'},
      {'id': '3', 'name': 'Retail Solutions'},
      {'id': '4', 'name': 'Services Inc'},
    ];
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

      final branchData = {
        'name': nameController.text.trim(),
        'code_id': codeController.text.trim().isNotEmpty ? codeController.text.trim() : null,
        'description': descriptionController.text.trim(),
        'company_id': selectedCompanyId.value,
        'address': addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
        'pic_name': picNameController.text.trim().isNotEmpty ? picNameController.text.trim() : null,
        'pic_contact': picContactController.text.trim().isNotEmpty ? picContactController.text.trim() : null,
        'note': noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
      };

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
    selectedCompanyId.value = '';
    errorMessage.value = '';
    formKey.currentState?.reset();
  }
}