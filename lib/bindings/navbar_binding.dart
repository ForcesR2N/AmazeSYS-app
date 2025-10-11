import 'package:get/get.dart';
import '../controllers/navbar_controller.dart';
import '../controllers/auth_controller.dart';

class NavbarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavbarController>(() => NavbarController());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}