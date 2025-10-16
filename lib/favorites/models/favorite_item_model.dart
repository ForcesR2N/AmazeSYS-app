class FavoriteItemModel {
  final String productId;
  final String productName;
  final String productDescription;
  final String? productCode;
  final String? categoryName;
  final DateTime addedAt;

  FavoriteItemModel({
    required this.productId,
    required this.productName,
    required this.productDescription,
    this.productCode,
    this.categoryName,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  factory FavoriteItemModel.fromJson(Map<String, dynamic> json) {
    return FavoriteItemModel(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? 'Unknown Product',
      productDescription: json['product_description']?.toString() ?? '',
      productCode: json['product_code']?.toString(),
      categoryName: json['category_name']?.toString(),
      addedAt: json['added_at'] != null
          ? DateTime.tryParse(json['added_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_description': productDescription,
      'product_code': productCode,
      'category_name': categoryName,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
