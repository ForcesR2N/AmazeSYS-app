import 'package:get/get.dart';
import '../../list-pages/models/list_item.dart';
import '../models/product_detail_model.dart';
import '../services/product_service.dart';
import '../../core/services/navigation_stack_manager.dart';
import '../../favorites/services/favorites_service.dart';
import '../../favorites/models/favorite_item_model.dart';
import '../../core/widgets/custom_snackbar.dart';

class ProductDetailController extends GetxController {
  final NavigationStackManager _navigationManager = Get.find<NavigationStackManager>();
  final ProductService _productService = ProductService();
  late final FavoritesService _favoritesService;

  late ListItem product;
  final Rxn<ProductDetail> productDetail = Rxn<ProductDetail>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool isFavorite = false.obs;

  @override
  void onInit() {
    super.onInit();
    product = Get.arguments as ListItem;

    // Initialize favorites service
    if (!Get.isRegistered<FavoritesService>()) {
      Get.put(FavoritesService());
    }
    _favoritesService = Get.find<FavoritesService>();

    loadProductDetail();
    checkFavoriteStatus();
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

  /// Check if product is in favorites
  void checkFavoriteStatus() {
    isFavorite.value = _favoritesService.isFavorite(product.id);
  }

  /// Toggle favorite status
  Future<void> toggleFavorite() async {
    try {
      final favoriteItem = FavoriteItemModel(
        productId: product.id,
        productName: productDetail.value?.name ?? product.name,
        productDescription: productDetail.value?.description ?? product.description,
        productCode: productDetail.value?.codeId ?? product.code,
        categoryName: productDetail.value?.categoryName,
      );

      final success = await _favoritesService.toggleFavorite(favoriteItem);

      if (success) {
        checkFavoriteStatus();

        if (isFavorite.value) {
          CustomSnackbar.success(
            message: 'Product added to favorites',
          );
        } else {
          CustomSnackbar.info(
            message: 'Product removed from favorites',
          );
        }
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      CustomSnackbar.error(
        message: 'Failed to update favorites',
      );
    }
  }
}