import 'package:get/get.dart';
import '../models/favorite_item_model.dart';
import '../services/favorites_service.dart';

class FavoritesController extends GetxController {
  final FavoritesService _favoritesService = Get.find<FavoritesService>();

  final RxList<FavoriteItemModel> favorites = <FavoriteItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  /// Load all favorites from local storage
  void loadFavorites() {
    try {
      isLoading.value = true;
      favorites.value = _favoritesService.getFavorites();
    } catch (e) {
      print('Error loading favorites: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get filtered favorites based on search query
  List<FavoriteItemModel> get filteredFavorites {
    if (searchQuery.value.isEmpty) {
      return favorites;
    }

    return favorites.where((item) {
      final query = searchQuery.value.toLowerCase();
      return item.productName.toLowerCase().contains(query) ||
          item.productDescription.toLowerCase().contains(query) ||
          (item.productCode?.toLowerCase().contains(query) ?? false) ||
          (item.categoryName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Remove item from favorites
  Future<void> removeFromFavorites(String productId) async {
    try {
      final success = await _favoritesService.removeFromFavorites(productId);
      if (success) {
        loadFavorites();
      }
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      await _favoritesService.clearAllFavorites();
      loadFavorites();
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }

  /// Refresh favorites list
  Future<void> refreshFavorites() async {
    try {
      isLoading.value = true;
      favorites.value = _favoritesService.getFavorites();
    } catch (e) {
      print('Error refreshing favorites: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
