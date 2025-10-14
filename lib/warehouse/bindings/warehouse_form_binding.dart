import 'package:get/get.dart';
import '../controllers/warehouse_form_controller.dart';
import '../services/warehouse_service.dart';

class WarehouseFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WarehouseService>(() => WarehouseService());
    Get.lazyPut<WarehouseFormController>(() => WarehouseFormController());
  }
}