import 'package:get/get.dart';
import '../controllers/hierarchy_controller.dart';

class HierarchyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HierarchyController>(
      () => HierarchyController(),
    );
  }
}