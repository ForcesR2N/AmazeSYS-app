// Type-safe navigation arguments helper for ListPage
// Ensures proper data passing between hierarchy navigation levels

import 'list_item.dart';

class ListArguments {
  final ListLevel level;
  final ListItem? parentItem;

  ListArguments({
    required this.level,
    this.parentItem,
  });

  // Convert to Map for GetX arguments
  Map<String, dynamic> toMap() {
    return {
      'level': level.name,
      'parentItem': parentItem?.toJson(),
    };
  }

  // Create from Map (GetX arguments)
  factory ListArguments.fromMap(Map<String, dynamic> map) {
    return ListArguments(
      level: ListLevel.values.firstWhere(
        (e) => e.name == map['level'],
      ),
      parentItem: map['parentItem'] != null 
        ? ListItem.fromJson(Map<String, dynamic>.from(map['parentItem']))
        : null,
    );
  }

  // Create copy with optional modifications
  ListArguments copyWith({
    ListLevel? level,
    ListItem? parentItem,
  }) {
    return ListArguments(
      level: level ?? this.level,
      parentItem: parentItem ?? this.parentItem,
    );
  }

  @override
  String toString() {
    return 'ListArguments(level: $level, parentItem: ${parentItem?.displayName})';
  }
}