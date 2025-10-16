import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/favorite_item_model.dart';

/// Service for managing favorite/wishlist products (Local Storage)
class FavoritesService extends GetxService {
  final GetStorage _storage = GetStorage();
  static const String _favoritesKey = 'favorites';

  /// Get all favorite products from local storage
  List<FavoriteItemModel> getFavorites() {
    try {
      final List<dynamic>? favoritesJson = _storage.read(_favoritesKey);
      if (favoritesJson == null || favoritesJson.isEmpty) {
        return [];
      }
      return favoritesJson
          .map((json) => FavoriteItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  /// Add a product to favorites
  Future<bool> addToFavorites(FavoriteItemModel item) async {
    try {
      final favorites = getFavorites();

      // Check if already exists
      if (favorites.any((fav) => fav.productId == item.productId)) {
        print('Product already in favorites');
        return false;
      }

      favorites.add(item);
      await _storage.write(_favoritesKey, favorites.map((e) => e.toJson()).toList());
      print('Product added to favorites');
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  /// Remove a product from favorites by product ID
  Future<bool> removeFromFavorites(String productId) async {
    try {
      final favorites = getFavorites();
      final initialLength = favorites.length;

      favorites.removeWhere((fav) => fav.productId == productId);

      if (favorites.length < initialLength) {
        await _storage.write(_favoritesKey, favorites.map((e) => e.toJson()).toList());
        print('Product removed from favorites');
        return true;
      }

      return false;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  /// Check if a product is in favorites
  bool isFavorite(String productId) {
    try {
      final favorites = getFavorites();
      return favorites.any((fav) => fav.productId == productId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  /// Toggle favorite status (add if not favorite, remove if favorite)
  Future<bool> toggleFavorite(FavoriteItemModel item) async {
    try {
      if (isFavorite(item.productId)) {
        return await removeFromFavorites(item.productId);
      } else {
        return await addToFavorites(item);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      await _storage.remove(_favoritesKey);
      print('All favorites cleared');
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }

  /// Get favorites count
  int getFavoritesCount() {
    return getFavorites().length;
  }
}
