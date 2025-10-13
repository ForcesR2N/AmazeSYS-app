import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/product_detail_model.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get product detail by ID
  Future<ProductDetail?> getProductDetail(String productId) async {
    try {
      final response = await _apiClient.get('/api/products/$productId')
          .timeout(const Duration(seconds: 30));
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        return ProductDetail.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load product detail: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product detail: $e');
      rethrow;
    }
  }

  /// Get all products with pagination
  Future<List<ProductDetail>> getProducts({int skip = 0, int limit = 100}) async {
    try {
      final response = await _apiClient.get(
        '/api/products/',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        final List<dynamic> productsJson = response.data as List<dynamic>;
        return productsJson
            .map((json) => ProductDetail.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load products: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }
}