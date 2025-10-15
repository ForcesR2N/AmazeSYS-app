enum ListLevel {
  company,
  branch,
  warehouse,
  product;

  String get displayName {
    switch (this) {
      case ListLevel.company:
        return 'Company';
      case ListLevel.branch:
        return 'Branch';
      case ListLevel.warehouse:
        return 'Warehouse';
      case ListLevel.product:
        return 'Product';
    }
  }

  ListLevel? get nextLevel {
    switch (this) {
      case ListLevel.company:
        return ListLevel.branch;
      case ListLevel.branch:
        return ListLevel.warehouse;
      case ListLevel.warehouse:
        return ListLevel.product;
      case ListLevel.product:
        return null;
    }
  }

  String get icon {
    switch (this) {
      case ListLevel.company:
        return '🏢';
      case ListLevel.branch:
        return '🏪';
      case ListLevel.warehouse:
        return '📦';
      case ListLevel.product:
        return '📱';
    }
  }
}

class ListItem {
  final String id;
  final String name;
  final String code;
  final String description;
  final ListLevel level;
  final String? parentId;

  ListItem({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.level,
    this.parentId,
  });

  String get displayName => '$name ($code)';

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code_id']?.toString() ?? json['code']?.toString() ?? '', // API uses 'code_id'
      description: json['description']?.toString() ?? '',
      level: ListLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => ListLevel.company,
      ),
      parentId: json['parentId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code_id': code,
      'description': description,
      'level': level.name,
      'parentId': parentId,
    };
  }
}