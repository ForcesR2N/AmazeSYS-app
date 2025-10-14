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

  /// Create a new warehouse
  Future<WarehouseDetail> createWarehouse(Map<String, dynamic> warehouseData) async {
    try {
      final response = await _apiClient.post(
        '/api/warehouses/',
        data: warehouseData,
      );
      
      if (response.statusCode == ApiConstants.statusCreated && response.data != null) {
        return WarehouseDetail.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create warehouse: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating warehouse: $e');
      throw Exception('Failed to create warehouse: $e');
    }
  }

  /// Update an existing warehouse
  Future<WarehouseDetail> updateWarehouse(String warehouseId, Map<String, dynamic> warehouseData) async {
    try {
      final response = await _apiClient.put(
        '/api/warehouses/$warehouseId',
        data: warehouseData,
      );
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        return WarehouseDetail.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update warehouse: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating warehouse: $e');
      throw Exception('Failed to update warehouse: $e');
    }
  }

  /// Delete a warehouse
  Future<bool> deleteWarehouse(String warehouseId) async {
    try {
      final response = await _apiClient.delete('/api/warehouses/$warehouseId');
      
      if (response.statusCode == ApiConstants.statusOk || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete warehouse: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting warehouse: $e');
      throw Exception('Failed to delete warehouse: $e');
    }
  }
}