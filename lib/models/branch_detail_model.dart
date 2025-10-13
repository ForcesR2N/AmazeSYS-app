class BranchDetail {
  final String id;
  final String? codeId;
  final String name;
  final String description;
  final String companyId;
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

  final DateTime? createdAt;
  final DateTime? updatedAt;

  BranchDetail({
    required this.id,
    this.codeId,
    required this.name,
    required this.description,
    required this.companyId,
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
    this.createdAt,
    this.updatedAt,
  });

  factory BranchDetail.fromJson(Map<String, dynamic> json) {
    return BranchDetail(
      id: json['id'] as String,
      codeId: json['code_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      companyId: json['company_id'] as String,
      address: json['address'] as String?,
      picName: json['pic_name'] as String?,
      picContact: json['pic_contact'] as String?,
      note: json['note'] as String?,
      provinceId: json['province_id'] as String?,
      provinceName: json['province_name'] as String?,
      districtId: json['district_id'] as String?,
      districtName: json['district_name'] as String?,
      subdistrictId: json['subdistrict_id'] as String?,
      subdistrictName: json['subdistrict_name'] as String?,
      wardId: json['ward_id'] as String?,
      wardName: json['ward_name'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code_id': codeId,
      'name': name,
      'description': description,
      'company_id': companyId,
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
    
    return addressParts.join(', ');
  }
}