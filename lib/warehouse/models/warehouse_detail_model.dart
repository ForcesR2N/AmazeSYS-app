class WarehouseDetail {
  final String id;
  final String? codeId;
  final String name;
  final String description;
  final String branchId;
  final String? address;
  final String? picName;
  final String? picContact;
  final String? note;

  // Location data
  final String? provinceId;
  final String? provinceName;
  final String? districtId;
  final String? districtName;
  final String? subdistrictId;
  final String? subdistrictName;
  final String? wardId;
  final String? wardName;
  final String? zipcodeId;
  final String? zipcode;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  WarehouseDetail({
    required this.id,
    this.codeId,
    required this.name,
    required this.description,
    required this.branchId,
    this.address,
    this.picName,
    this.picContact,
    this.note,
    this.provinceId,
    this.provinceName,
    this.districtId,
    this.districtName,
    this.subdistrictId,
    this.subdistrictName,
    this.wardId,
    this.wardName,
    this.zipcodeId,
    this.zipcode,
    this.createdAt,
    this.updatedAt,
  });

  factory WarehouseDetail.fromJson(Map<String, dynamic> json) {
    try {
      // 🔥 SMART PARSING - Support both flat and nested structure

      // Province - check nested object first, then fallback to flat
      String? provinceId;
      String? provinceName;
      if (json['province'] != null && json['province'] is Map) {
        final province = json['province'] as Map<String, dynamic>;
        provinceId = province['id']?.toString();
        provinceName = province['name']?.toString();
      } else {
        provinceId = json['province_id']?.toString();
        provinceName = json['province_name']?.toString();
      }

      // District - check nested object first, then fallback to flat
      String? districtId;
      String? districtName;
      if (json['district'] != null && json['district'] is Map) {
        final district = json['district'] as Map<String, dynamic>;
        districtId = district['id']?.toString();
        districtName = district['name']?.toString();
      } else {
        districtId = json['district_id']?.toString();
        districtName = json['district_name']?.toString();
      }

      // Subdistrict - check nested object first, then fallback to flat
      String? subdistrictId;
      String? subdistrictName;
      if (json['subdistrict'] != null && json['subdistrict'] is Map) {
        final subdistrict = json['subdistrict'] as Map<String, dynamic>;
        subdistrictId = subdistrict['id']?.toString();
        subdistrictName = subdistrict['name']?.toString();
      } else {
        subdistrictId = json['subdistrict_id']?.toString();
        subdistrictName = json['subdistrict_name']?.toString();
      }

      // Ward - check nested object first, then fallback to flat
      String? wardId;
      String? wardName;
      if (json['ward'] != null && json['ward'] is Map) {
        final ward = json['ward'] as Map<String, dynamic>;
        wardId = ward['id']?.toString();
        wardName = ward['name']?.toString();
      } else {
        wardId = json['ward_id']?.toString();
        wardName = json['ward_name']?.toString();
      }

      // Zipcode - check nested object first, then fallback to flat
      String? zipcodeId;
      String? zipcode;
      if (json['zipcode'] != null && json['zipcode'] is Map) {
        final zipcodeObj = json['zipcode'] as Map<String, dynamic>;
        zipcodeId = zipcodeObj['id']?.toString();
        zipcode = zipcodeObj['code']?.toString();
      } else {
        zipcodeId = json['zipcode_id']?.toString();
        zipcode = json['zipcode']?.toString();
      }

      return WarehouseDetail(
        id: json['id']?.toString() ?? '',
        codeId: json['code_id']?.toString(),
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        branchId: json['branch_id']?.toString() ?? '',
        address: json['address']?.toString(),
        picName: json['pic_name']?.toString(),
        picContact: json['pic_contact']?.toString(),
        note: json['note']?.toString(),
        provinceId: provinceId,
        provinceName: provinceName,
        districtId: districtId,
        districtName: districtName,
        subdistrictId: subdistrictId,
        subdistrictName: subdistrictName,
        wardId: wardId,
        wardName: wardName,
        zipcodeId: zipcodeId,
        zipcode: zipcode,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
      );
    } catch (e) {
      print('❌ WarehouseDetail.fromJson error: $e');
      // Return a minimal valid object instead of throwing
      return WarehouseDetail(
        id: json['id']?.toString() ?? 'unknown',
        name: json['name']?.toString() ?? 'Unknown Warehouse',
        description: json['description']?.toString() ?? 'No description',
        branchId: json['branch_id']?.toString() ?? '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code_id': codeId,
      'name': name,
      'description': description,
      'branch_id': branchId,
      'address': address,
      'pic_name': picName,
      'pic_contact': picContact,
      'note': note,
      'province_id': provinceId,
      'province_name': provinceName,
      'district_id': districtId,
      'district_name': districtName,
      'subdistrict_id': subdistrictId,
      'subdistrict_name': subdistrictName,
      'ward_id': wardId,
      'ward_name': wardName,
      'zipcode_id': zipcodeId,
      'zipcode': zipcode,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get street address (just the address field)
  String get streetAddress {
    return address?.isNotEmpty == true ? address! : '-';
  }

  /// Get full address string (complete with district, subdistrict, province, zipcode)
  String get fullAddress {
    List<String> addressParts = [];

    // Start with street address
    if (address?.isNotEmpty == true) addressParts.add(address!);

    // Add ward (kelurahan)
    if (wardName?.isNotEmpty == true) addressParts.add('Kel. $wardName');

    // Add subdistrict (kecamatan)
    if (subdistrictName?.isNotEmpty == true) addressParts.add('Kec. $subdistrictName');

    // Add district (kabupaten/kota)
    if (districtName?.isNotEmpty == true) addressParts.add(districtName!);

    // Add province
    if (provinceName?.isNotEmpty == true) addressParts.add(provinceName!);

    // Add zipcode
    if (zipcode?.isNotEmpty == true) addressParts.add(zipcode!);

    return addressParts.isNotEmpty ? addressParts.join(', ') : '-';
  }
}