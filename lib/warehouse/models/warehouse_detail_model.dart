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
    this.createdAt,
    this.updatedAt,
  });

  factory WarehouseDetail.fromJson(Map<String, dynamic> json) {
    return WarehouseDetail(
      id: json['id'] as String,
      codeId: json['code_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      branchId: json['branch_id'] as String,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get street address (just the address field)
  String get streetAddress {
    return address?.isNotEmpty == true ? address! : '-';
  }

  /// Get full address string (complete with district, subdistrict, province)
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

    return addressParts.isNotEmpty ? addressParts.join(', ') : '-';
  }
}