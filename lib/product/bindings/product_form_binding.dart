import 'package:get/get.dart';
import '../controllers/product_form_controller.dart';
import '../services/product_service.dart';

class ProductFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductService>(() => ProductService());
    Get.lazyPut<ProductFormController>(() => ProductFormController());
  }
}