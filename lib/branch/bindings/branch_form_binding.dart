import 'package:get/get.dart';
import '../controllers/branch_form_controller.dart';
import '../services/branch_service.dart';

class BranchFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BranchService>(() => BranchService());
    Get.lazyPut<BranchFormController>(() => BranchFormController());
  }
}