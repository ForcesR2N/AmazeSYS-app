class CompanyDetail {
  final String id;
  final String name;
  final String code;
  final String description;
  final String categoryId;
  final String? categoryName;
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

  CompanyDetail({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.categoryId,
    this.categoryName,
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

  factory CompanyDetail.fromJson(Map<String, dynamic> json) {
    try {
      return CompanyDetail(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        code: json['code_id']?.toString() ?? json['code']?.toString() ?? '', // API uses 'code_id'
        description: json['description']?.toString() ?? '',
        categoryId: json['category_id']?.toString() ?? '',
        categoryName: json['category_name']?.toString(),
        address: json['address']?.toString(),
        picName: json['pic_name']?.toString(),
        picContact: json['pic_contact']?.toString(),
        note: json['note']?.toString(),
        provinceId: json['province_id']?.toString(),
        provinceName: json['province_name']?.toString(),
        districtId: json['district_id']?.toString(),
        districtName: json['district_name']?.toString(),
        subdistrictId: json['subdistrict_id']?.toString(),
        subdistrictName: json['subdistrict_name']?.toString(),
        wardId: json['ward_id']?.toString(),
        wardName: json['ward_name']?.toString(),
        zipcodeId: json['zipcode_id']?.toString(),
        zipcode: json['zipcode']?.toString(),
        createdAt: json['created_at'] != null 
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null 
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
      );
    } catch (e) {
      print('🚨 Error parsing CompanyDetail JSON: $e');
      print('🚨 Raw JSON: $json');
      // Return a minimal valid object instead of throwing
      return CompanyDetail(
        id: json['id']?.toString() ?? 'unknown',
        name: json['name']?.toString() ?? 'Unknown Company',
        code: json['code_id']?.toString() ?? json['code']?.toString() ?? 'N/A',
        description: json['description']?.toString() ?? 'No description',
        categoryId: json['category_id']?.toString() ?? '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'category_id': categoryId,
      'category_name': categoryName,
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

  /// Get full address string
  String get fullAddress {
    List<String> addressParts = [];
    
    if (address?.isNotEmpty == true) addressParts.add(address!);
    if (wardName?.isNotEmpty == true) addressParts.add(wardName!);
    if (subdistrictName?.isNotEmpty == true) addressParts.add(subdistrictName!);
    if (districtName?.isNotEmpty == true) addressParts.add(districtName!);
    if (provinceName?.isNotEmpty == true) addressParts.add(provinceName!);
    if (zipcode?.isNotEmpty == true) addressParts.add(zipcode!);
    
    return addressParts.join(', ');
  }
}