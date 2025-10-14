import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/company_detail_model.dart';
import '../services/company_service.dart';
import '../../core/widgets/base_form_page.dart';
import '../../core/widgets/custom_snackbar.dart';

class CompanyFormController extends BaseFormController {
  late final CompanyService _companyService;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController picNameController = TextEditingController();
  final TextEditingController picContactController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Reactive variables
  final RxString selectedCategoryId = ''.obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;

  // Form state
  CompanyDetail? _existingCompany;

  @override
  bool get isEditMode => _existingCompany != null;

  @override
  String get pageTitle => isEditMode ? 'Edit Company' : 'Create Company';

  @override
  String get entityName => 'Company';

  @override
  void onInit() {
    super.onInit();
    _companyService = Get.find<CompanyService>();
    _initializeFormData();
    _loadCategories();
    _setupFormListeners();

    // Ensure form population for edit mode
    if (_existingCompany != null) {
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

    // Listen to category changes
    ever(selectedCategoryId, (_) => markFormAsDirty());
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

    if (arguments != null && arguments['company'] != null) {
      _existingCompany = arguments['company'] as CompanyDetail;
    }
  }

  void _populateFormWithExistingData() {
    if (_existingCompany == null) return;

    nameController.text = _existingCompany!.name;
    codeController.text = _existingCompany!.code;
    descriptionController.text = _existingCompany!.description;
    addressController.text = _existingCompany!.address ?? '';
    picNameController.text = _existingCompany!.picName ?? '';
    picContactController.text = _existingCompany!.picContact ?? '';
    noteController.text = _existingCompany!.note ?? '';

    if (_existingCompany!.categoryId.isNotEmpty) {
      final categoryExists = categories.any(
        (cat) => cat['id'].toString() == _existingCompany!.categoryId,
      );

      if (categoryExists) {
        selectedCategoryId.value = _existingCompany!.categoryId;
      } else {
        categories.add({
          'id': _existingCompany!.categoryId,
          'name': _existingCompany!.categoryName ?? 'Unknown Category',
        });
        selectedCategoryId.value = _existingCompany!.categoryId;
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final apiCategories = await _companyService.getCompanyCategories();

      if (apiCategories.isNotEmpty) {
        categories.value = apiCategories;
      } else {
        _setFallbackCategories();
      }
    } catch (e) {
      _setFallbackCategories();
    }

    if (_existingCompany != null) {
      _populateFormWithExistingData();
    }
  }

  void _setFallbackCategories() {
    categories.value = [
      {'id': '1', 'name': 'Technology'},
      {'id': '2', 'name': 'Manufacturing'},
      {'id': '3', 'name': 'Retail'},
      {'id': '4', 'name': 'Healthcare'},
      {'id': '5', 'name': 'Finance'},
    ];
  }

  @override
  List<String> getValidationErrors() {
    List<String> errors = [];

    if (nameController.text.trim().isEmpty) {
      errors.add('Company Name');
    }
    if (codeController.text.trim().isEmpty) {
      errors.add('Company Code');
    }
    if (descriptionController.text.trim().isEmpty) {
      errors.add('Description');
    }
    if (selectedCategoryId.value.isEmpty) {
      errors.add('Category');
    }

    return errors;
  }

  @override
  Future<void> saveData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final companyData = {
        'name': nameController.text.trim(),
        'code_id': codeController.text.trim(),
        'description': descriptionController.text.trim(),
        'category_id': selectedCategoryId.value,
        'address': addressController.text.trim(),
        'pic_name': picNameController.text.trim(),
        'pic_contact': picContactController.text.trim(),
        'note': noteController.text.trim(),
      };

      if (isEditMode) {
        await _companyService.updateCompany(_existingCompany!.id, companyData);
      } else {
        await _companyService.createCompany(companyData);
      }

      // Mark form as clean and navigate back with success result
      markFormAsClean();
      Get.back(result: true);
    } catch (e) {
      errorMessage.value = 'Failed to save company: ${e.toString()}';
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
    selectedCategoryId.value = '';
    errorMessage.value = '';
    formKey.currentState?.reset();
  }
}
