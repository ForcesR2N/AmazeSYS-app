class ProductDetail {
  final String id;
  final String? codeId;
  final String name;
  final String description;
  final String warehouseId;
  final String branchId;
  final String? categoryId;
  final String? categoryName;
  final String? note;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductDetail({
    required this.id,
    this.codeId,
    required this.name,
    required this.description,
    required this.warehouseId,
    required this.branchId,
    this.categoryId,
    this.categoryName,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'] as String,
      codeId: json['code_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      warehouseId: json['warehouse_id'] as String,
      branchId: json['branch_id'] as String,
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      note: json['note'] as String?,
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
      'warehouse_id': warehouseId,
      'branch_id': branchId,
      'category_id': categoryId,
      'category_name': categoryName,
      'note': note,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}