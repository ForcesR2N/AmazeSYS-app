import '../models/list_item.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';

class ListService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get items by level from API
  Future<List<ListItem>> getItemsByLevel(ListLevel level) async {
    try {
      String endpoint = _getEndpointForLevel(level);
      final response = await _apiClient.get(endpoint);
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        final List<dynamic> items = response.data as List<dynamic>;
        return items.map((json) => _mapToListItem(json, level)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching items by level: $e');
      return [];
    }
  }

  /// Get children items for a parent ID
  Future<List<ListItem>> getChildren(String parentId) async {
    // Implementation depends on the API structure
    // For now, we'll need to determine the child level based on parent
    // This might need to be updated based on actual API endpoints
    try {
      // This is a placeholder - you might need to adjust based on actual API
      return [];
    } catch (e) {
      print('Error fetching children: $e');
      return [];
    }
  }

  /// Get children by specific level
  Future<List<ListItem>> getChildrenByLevel(String parentId, ListLevel childLevel) async {
    try {
      String endpoint = _getEndpointForLevel(childLevel);
      final response = await _apiClient.get(endpoint);
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        final List<dynamic> items = response.data as List<dynamic>;
        return items
            .map((json) => _mapToListItem(json, childLevel))
            .where((item) => _matchesParent(item, parentId, childLevel))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching children by level: $e');
      return [];
    }
  }

  /// Search items with query
  Future<List<ListItem>> searchItems(String query, ListLevel level, [String? parentId]) async {
    try {
      String endpoint = _getEndpointForLevel(level);
      final response = await _apiClient.get(endpoint);
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        final List<dynamic> items = response.data as List<dynamic>;
        return items
            .map((json) => _mapToListItem(json, level))
            .where((item) => 
                (parentId == null || _matchesParent(item, parentId, level)) &&
                (item.name.toLowerCase().contains(query.toLowerCase()) ||
                 item.code.toLowerCase().contains(query.toLowerCase())))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching items: $e');
      return [];
    }
  }

  /// Get single item by ID
  Future<ListItem?> getItemById(String id) async {
    try {
      // Try each level endpoint to find the item
      for (ListLevel level in ListLevel.values) {
        String endpoint = '${_getEndpointForLevel(level)}/$id';
        try {
          final response = await _apiClient.get(endpoint);
          if (response.statusCode == ApiConstants.statusOk && response.data != null) {
            return _mapToListItem(response.data as Map<String, dynamic>, level);
          }
        } catch (e) {
          // Continue to next level
          continue;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching item by ID: $e');
      return null;
    }
  }

  /// Check if item has children
  Future<bool> hasChildren(String parentId) async {
    try {
      // Check each child level
      for (ListLevel level in ListLevel.values) {
        final children = await getChildrenByLevel(parentId, level);
        if (children.isNotEmpty) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking children: $e');
      return false;
    }
  }

  /// Get API endpoint for each level
  String _getEndpointForLevel(ListLevel level) {
    switch (level) {
      case ListLevel.company:
        return '/api/companies/';
      case ListLevel.branch:
        return '/api/branches/';
      case ListLevel.warehouse:
        return '/api/warehouses/';
      case ListLevel.product:
        return '/api/products/';
    }
  }

  /// Map API response to ListItem
  ListItem _mapToListItem(Map<String, dynamic> json, ListLevel level) {
    return ListItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      level: level,
      parentId: _getParentId(json, level),
    );
  }

  /// Extract parent ID based on level
  String? _getParentId(Map<String, dynamic> json, ListLevel level) {
    switch (level) {
      case ListLevel.company:
        return null; // Companies don't have parents
      case ListLevel.branch:
        return json['company_id'] as String?;
      case ListLevel.warehouse:
        return json['branch_id'] as String?;
      case ListLevel.product:
        return json['warehouse_id'] as String?;
    }
  }

  /// Check if item matches parent
  bool _matchesParent(ListItem item, String parentId, ListLevel level) {
    return item.parentId == parentId;
  }
}