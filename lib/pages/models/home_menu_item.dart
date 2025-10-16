import 'package:flutter/material.dart';
import '../../list-pages/models/list_item.dart';

/// Model for home page menu items with type safety
class HomeMenuItem {
  final String name;
  final ListLevel level;
  final IconData icon;
  final Color color;
  final int count;

  const HomeMenuItem({
    required this.name,
    required this.level,
    required this.icon,
    required this.color,
    this.count = 0,
  });

  /// Get formatted count string (e.g., "1.5K" for 1500)
  String get formattedCount {
    if (count == 0) return '...';
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  /// Create a copy with updated values
  HomeMenuItem copyWith({
    String? name,
    ListLevel? level,
    IconData? icon,
    Color? color,
    int? count,
  }) {
    return HomeMenuItem(
      name: name ?? this.name,
      level: level ?? this.level,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      count: count ?? this.count,
    );
  }
}
