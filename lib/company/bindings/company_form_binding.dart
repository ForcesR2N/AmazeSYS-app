import 'package:get/get.dart';
import '../controllers/company_form_controller.dart';
import '../services/company_service.dart';

class CompanyFormBinding extends Bindings {
  @override
  void dependencies() {
    // CompanyService is now registered globally in main.dart
    // Register CompanyFormController with immediate initialization
    Get.put<CompanyFormController>(CompanyFormController());
  }
}