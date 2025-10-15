import '../api/api_client.dart';
import '../api/api_constants.dart';

/// Location model classes
class Province {
  final String id;
  final String name;

  Province({required this.id, required this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class District {
  final String id;
  final String name;
  final String provinceId;

  District({required this.id, required this.name, required this.provinceId});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      provinceId: json['province_id']?.toString() ?? '',
    );
  }
}

class Subdistrict {
  final String id;
  final String name;
  final String districtId;

  Subdistrict({required this.id, required this.name, required this.districtId});

  factory Subdistrict.fromJson(Map<String, dynamic> json) {
    return Subdistrict(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      districtId: json['district_id']?.toString() ?? '',
    );
  }
}

class Ward {
  final String id;
  final String name;
  final String subdistrictId;

  Ward({required this.id, required this.name, required this.subdistrictId});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      subdistrictId: json['subdistrict_id']?.toString() ?? '',
    );
  }
}

class Zipcode {
  final String id;
  final String code;
  final String wardId;

  Zipcode({required this.id, required this.code, required this.wardId});

  factory Zipcode.fromJson(Map<String, dynamic> json) {
    return Zipcode(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      wardId: json['ward_id']?.toString() ?? '',
    );
  }
}

/// Location service for fetching location data
class LocationService {
  final ApiClient _apiClient = ApiClient.instance;

  // Cache for provinces (they rarely change)
  static List<Province>? _cachedProvinces;
  static DateTime? _provincesCacheTime;
  static const _cacheDuration = Duration(minutes: 30);

  /// Get all provinces with caching
  Future<List<Province>> getProvinces() async {
    try {
      // Check if cache is valid
      if (_cachedProvinces != null && _provincesCacheTime != null) {
        final cacheAge = DateTime.now().difference(_provincesCacheTime!);
        if (cacheAge < _cacheDuration) {
          print('✅ Using cached provinces (${_cachedProvinces!.length} items)');
          return _cachedProvinces!;
        }
      }

      // Fetch from API
      final response = await _apiClient.get('/api/locations/provinces');

      if (response.statusCode == ApiConstants.statusOk &&
          response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        final provinces = data
            .map((json) => Province.fromJson(json as Map<String, dynamic>))
            .toList();

        // Update cache
        _cachedProvinces = provinces;
        _provincesCacheTime = DateTime.now();
        print('✅ Cached ${provinces.length} provinces');

        return provinces;
      }
      return [];
    } catch (e) {
      print('❌ Error fetching provinces: $e');
      // Return cached data if available, even if expired
      return _cachedProvinces ?? [];
    }
  }

  /// Clear provinces cache (useful for testing or forced refresh)
  static void clearProvincesCache() {
    _cachedProvinces = null;
    _provincesCacheTime = null;
  }

  /// Get districts by province ID
  Future<List<District>> getDistrictsByProvince(String provinceId) async {
    try {
      final response = await _apiClient
          .get('/api/locations/provinces/$provinceId/districts');

      if (response.statusCode == ApiConstants.statusOk &&
          response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => District.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Error fetching districts: $e');
      return [];
    }
  }

  /// Get subdistricts by district ID
  Future<List<Subdistrict>> getSubdistrictsByDistrict(String districtId) async {
    try {
      final response = await _apiClient
          .get('/api/locations/districts/$districtId/subdistricts');

      if (response.statusCode == ApiConstants.statusOk &&
          response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => Subdistrict.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Error fetching subdistricts: $e');
      return [];
    }
  }

  /// Get wards by subdistrict ID
  Future<List<Ward>> getWardsBySubdistrict(String subdistrictId) async {
    try {
      final response = await _apiClient
          .get('/api/locations/subdistricts/$subdistrictId/wards');

      if (response.statusCode == ApiConstants.statusOk &&
          response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => Ward.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Error fetching wards: $e');
      return [];
    }
  }

  /// Get zipcodes by ward ID
  Future<List<Zipcode>> getZipcodesByWard(String wardId) async {
    try {
      final response =
          await _apiClient.get('/api/locations/wards/$wardId/zipcodes');

      if (response.statusCode == ApiConstants.statusOk &&
          response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => Zipcode.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Error fetching zipcodes: $e');
      return [];
    }
  }

  /// Get location by zipcode
  Future<Map<String, dynamic>?> getLocationByZipcode(String code) async {
    try {
      final response = await _apiClient.get('/api/locations/zipcode/$code');

      if (response.statusCode == ApiConstants.statusOk &&
          response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Error fetching location by zipcode: $e');
      return null;
    }
  }
}
