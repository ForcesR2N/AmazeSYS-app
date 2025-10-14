import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../models/company_detail_model.dart';

class CompanyService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get company detail by ID
  Future<CompanyDetail?> getCompanyDetail(String companyId) async {
    try {
      final response = await _apiClient.get('/api/companies/$companyId');
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        try {
          final companyDetail = CompanyDetail.fromJson(response.data as Map<String, dynamic>);
          return companyDetail;
        } catch (parseError) {
          // Return null instead of throwing, let the controller handle it
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get all companies with pagination
  Future<List<CompanyDetail>> getCompanies({int skip = 0, int limit = 100}) async {
    try {
      final response = await _apiClient.get(
        '/api/companies/',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        final List<dynamic> companiesJson = response.data as List<dynamic>;
        return companiesJson
            .map((json) => CompanyDetail.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching companies: $e');
      return [];
    }
  }

  /// Get company categories
  Future<List<Map<String, dynamic>>> getCompanyCategories({int skip = 0, int limit = 100}) async {
    try {
      final response = await _apiClient.get(
        '/api/companies/categories/',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data as List);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching company categories: $e');
      return [];
    }
  }

  /// Create a new company
  Future<CompanyDetail> createCompany(Map<String, dynamic> companyData) async {
    try {
      final response = await _apiClient.post(
        '/api/companies/',
        data: companyData,
      );
      
      if (response.statusCode == ApiConstants.statusCreated && response.data != null) {
        return CompanyDetail.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create company: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating company: $e');
      throw Exception('Failed to create company: $e');
    }
  }

  /// Update an existing company
  Future<CompanyDetail> updateCompany(String companyId, Map<String, dynamic> companyData) async {
    try {
      final response = await _apiClient.put(
        '/api/companies/$companyId',
        data: companyData,
      );
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        return CompanyDetail.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update company: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating company: $e');
      throw Exception('Failed to update company: $e');
    }
  }

  /// Delete a company
  Future<bool> deleteCompany(String companyId) async {
    try {
      final response = await _apiClient.delete('/api/companies/$companyId');
      
      if (response.statusCode == ApiConstants.statusOk || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete company: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting company: $e');
      throw Exception('Failed to delete company: $e');
    }
  }
}