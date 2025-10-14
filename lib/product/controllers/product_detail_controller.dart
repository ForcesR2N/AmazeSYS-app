import 'package:get/get.dart';
import '../../list-pages/models/list_item.dart';
import '../models/product_detail_model.dart';
import '../services/product_service.dart';
import '../../core/services/navigation_stack_manager.dart';

class ProductDetailController extends GetxController {
  final NavigationStackManager _navigationManager = Get.find<NavigationStackManager>();
  final ProductService _productService = ProductService();

  late ListItem product;
  final Rxn<ProductDetail> productDetail = Rxn<ProductDetail>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    product = Get.arguments as ListItem;
    loadProductDetail();
  }

  Future<void> loadProductDetail() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final detailFuture = _productService.getProductDetail(product.id);
      final minimumDelay = Future.delayed(const Duration(milliseconds: 800));

      await Future.wait([detailFuture, minimumDelay]).then((results) {
        final detail = results[0] as ProductDetail?;
        productDetail.value = detail;
      });
    } catch (e) {
      errorMessage.value = 'Failed to load product detail: $e';
      print('Error loading product detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retry() async {
    await loadProductDetail();
  }

  void navigateBack() {
    // When going back from product detail, ensure the parent list shows detail view first
    Get.back(result: {'showDetailFirst': true});
  }
}