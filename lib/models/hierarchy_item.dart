enum HierarchyLevel {
  company,
  branch,
  warehouse,
  product;

  String get displayName {
    switch (this) {
      case HierarchyLevel.company:
        return 'Company';
      case HierarchyLevel.branch:
        return 'Branch';
      case HierarchyLevel.warehouse:
        return 'Warehouse';
      case HierarchyLevel.product:
        return 'Product';
    }
  }

  HierarchyLevel? get nextLevel {
    switch (this) {
      case HierarchyLevel.company:
        return HierarchyLevel.branch;
      case HierarchyLevel.branch:
        return HierarchyLevel.warehouse;
      case HierarchyLevel.warehouse:
        return HierarchyLevel.product;
      case HierarchyLevel.product:
        return null;
    }
  }

  String get icon {
    switch (this) {
      case HierarchyLevel.company:
        return '🏢';
      case HierarchyLevel.branch:
        return '🏪';
      case HierarchyLevel.warehouse:
        return '📦';
      case HierarchyLevel.product:
        return '📱';
    }
  }
}

class HierarchyItem {
  final String id;
  final String name;
  final String code;
  final String description;
  final HierarchyLevel level;
  final String? parentId;

  HierarchyItem({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.level,
    this.parentId,
  });

  String get displayName => '$name ($code)';

  factory HierarchyItem.fromJson(Map<String, dynamic> json) {
    return HierarchyItem(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      level: HierarchyLevel.values.firstWhere(
        (e) => e.name == json['level'],
      ),
      parentId: json['parentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'level': level.name,
      'parentId': parentId,
    };
  }
}