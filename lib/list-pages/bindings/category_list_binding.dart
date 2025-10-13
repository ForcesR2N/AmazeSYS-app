import 'package:get/get.dart';
import '../controllers/category_list_controller.dart';
import '../services/list_service.dart';

class CategoryListBinding extends Bindings {
  @override
  void dependencies() {
    // Register ListService if not already registered
    if (!Get.isRegistered<ListService>()) {
      Get.lazyPut<ListService>(() => ListService());
    }
    
    // Register CategoryListController
    Get.lazyPut<CategoryListController>(() => CategoryListController());
  }
}