import 'package:get/get.dart';
import '../controllers/favorites_controller.dart';
import '../services/favorites_service.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesService>(() => FavoritesService());
    Get.lazyPut<FavoritesController>(() => FavoritesController());
  }
}
