import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../models/warehouse_detail_model.dart';

class WarehouseService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get warehouse detail by ID
  Future<WarehouseDetail?> getWarehouseDetail(String warehouseId) async {
    try {
      final response = await _apiClient.get('/api/warehouses/$warehouseId')
          .timeout(const Duration(seconds: 30));
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        return WarehouseDetail.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load warehouse detail: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching warehouse detail: $e');
      rethrow;
    }
  }

  /// Get all warehouses with pagination
  Future<List<WarehouseDetail>> getWarehouses({int skip = 0, int limit = 100}) async {
    try {
      final response = await _apiClient.get(
        '/api/warehouses/',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        final List<dynamic> warehousesJson = response.data as List<dynamic>;
        return warehousesJson
            .map((json) => WarehouseDetail.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load warehouses: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching warehouses: $e');
      rethrow;
    }
  }
}