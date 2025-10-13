import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/branch_detail_model.dart';

class BranchService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get branch detail by ID
  Future<BranchDetail?> getBranchDetail(String branchId) async {
    try {
      final response = await _apiClient.get('/api/branches/$branchId')
          .timeout(const Duration(seconds: 30));
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        return BranchDetail.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load branch detail: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching branch detail: $e');
      rethrow;
    }
  }

  /// Get all branches with pagination
  Future<List<BranchDetail>> getBranches({int skip = 0, int limit = 100}) async {
    try {
      final response = await _apiClient.get(
        '/api/branches/',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        final List<dynamic> branchesJson = response.data as List<dynamic>;
        return branchesJson
            .map((json) => BranchDetail.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load branches: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching branches: $e');
      rethrow;
    }
  }
}