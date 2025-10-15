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
          // 🔍 DEBUG PRINT - Response Structure
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('📡 Company Detail Response - ID: $companyId');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('Status: ${response.statusCode}');
          print('Response Type: ${response.data.runtimeType}');
          print('\n📄 Full Response:');
          print(response.data);

          final data = response.data as Map<String, dynamic>;

          // Print location fields - both flat and nested
          print('\n📍 Location Fields Detection:');

          // Check if nested or flat structure
          if (data['province'] != null && data['province'] is Map) {
            print('  ✅ Using NESTED structure');
            print('  province: ${data['province']}');
            print('  district: ${data['district']}');
            print('  subdistrict: ${data['subdistrict']}');
            print('  ward: ${data['ward']}');
            print('  zipcode: ${data['zipcode']}');
          } else {
            print('  ✅ Using FLAT structure');
            print('  province_id: ${data['province_id']} | province_name: ${data['province_name']}');
            print('  district_id: ${data['district_id']} | district_name: ${data['district_name']}');
            print('  subdistrict_id: ${data['subdistrict_id']} | subdistrict_name: ${data['subdistrict_name']}');
            print('  ward_id: ${data['ward_id']} | ward_name: ${data['ward_name']}');
            print('  zipcode_id: ${data['zipcode_id']} | zipcode: ${data['zipcode']}');
          }
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

          final companyDetail = CompanyDetail.fromJson(data);

          // Print parsed model
          print('✅ Parsed CompanyDetail:');
          print('  Street Address: ${companyDetail.streetAddress}');
          print('  Full Address: ${companyDetail.fullAddress}');
          print('  Province: ${companyDetail.provinceName} (${companyDetail.provinceId})');
          print('  District: ${companyDetail.districtName} (${companyDetail.districtId})');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

          return companyDetail;
        } catch (parseError) {
          print('❌ Parse Error: $parseError');
          // Return null instead of throwing, let the controller handle it
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Error fetching company detail: $e');
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
        // 🔍 DEBUG PRINT - List Response
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📡 Companies List Response');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('Status: ${response.statusCode}');
        print('Response Type: ${response.data.runtimeType}');

        final List<dynamic> companiesJson = response.data as List<dynamic>;
        print('📊 Total Companies: ${companiesJson.length}');

        if (companiesJson.isNotEmpty) {
          print('\n🔍 First Company Sample:');
          final firstCompany = companiesJson.first as Map<String, dynamic>;
          print('  ID: ${firstCompany['id']}');
          print('  Name: ${firstCompany['name']}');
          print('  Code ID: ${firstCompany['code_id']}');
          print('  Province: ${firstCompany['province_name']} (${firstCompany['province_id']})');
          print('  District: ${firstCompany['district_name']} (${firstCompany['district_id']})');
        }
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

        return companiesJson
            .map((json) => CompanyDetail.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Error fetching companies: $e');
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