import '../models/list_item.dart';

class ListService {
  static final List<ListItem> _dummyData = [
    // Companies
    ListItem(
      id: 'comp1',
      name: 'PT Amazink Jakarta',
      code: 'AMZ-JKT',
      description: 'Main company in Jakarta',
      level: ListLevel.company,
    ),
    ListItem(
      id: 'comp2',
      name: 'PT Amazink Surabaya',
      code: 'AMZ-SBY',
      description: 'Branch company in Surabaya',
      level: ListLevel.company,
    ),
    ListItem(
      id: 'comp3',
      name: 'PT Amazink Bali',
      code: 'AMZ-BAL',
      description: 'Branch company in Bali',
      level: ListLevel.company,
    ),
    
    // Branches for comp1
    ListItem(
      id: 'branch1',
      name: 'Cabang Menteng',
      code: 'JKT-MTG-001',
      description: 'Branch office in Menteng area',
      level: ListLevel.branch,
      parentId: 'comp1',
    ),
    ListItem(
      id: 'branch2',
      name: 'Cabang Kemang',
      code: 'JKT-KMG-002',
      description: 'Branch office in Kemang area',
      level: ListLevel.branch,
      parentId: 'comp1',
    ),
    ListItem(
      id: 'branch3',
      name: 'Cabang Pluit',
      code: 'JKT-PLT-003',
      description: 'Branch office in Pluit area',
      level: ListLevel.branch,
      parentId: 'comp1',
    ),
    
    // Warehouses for branch1
    ListItem(
      id: 'wh1',
      name: 'Gudang Utama',
      code: 'MTG-WH-001',
      description: 'Main warehouse for Menteng branch',
      level: ListLevel.warehouse,
      parentId: 'branch1',
    ),
    ListItem(
      id: 'wh2',
      name: 'Gudang Cadangan',
      code: 'MTG-WH-002',
      description: 'Backup warehouse for Menteng branch',
      level: ListLevel.warehouse,
      parentId: 'branch1',
    ),
    ListItem(
      id: 'wh3',
      name: 'Gudang Export',
      code: 'MTG-WH-003',
      description: 'Export warehouse for Menteng branch',
      level: ListLevel.warehouse,
      parentId: 'branch1',
    ),
    
    // Products for wh1
    ListItem(
      id: 'prod1',
      name: 'Smartphone Android',
      code: 'SA-001',
      description: 'Latest Android smartphone',
      level: ListLevel.product,
      parentId: 'wh1',
    ),
    ListItem(
      id: 'prod2',
      name: 'Laptop Gaming',
      code: 'LG-002',
      description: 'High performance gaming laptop',
      level: ListLevel.product,
      parentId: 'wh1',
    ),
    ListItem(
      id: 'prod3',
      name: 'Tablet Pro',
      code: 'TP-003',
      description: 'Professional tablet device',
      level: ListLevel.product,
      parentId: 'wh1',
    ),
  ];

  Future<List<ListItem>> getItemsByLevel(ListLevel level) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _dummyData.where((item) => item.level == level && item.parentId == null).toList();
  }

  Future<List<ListItem>> getChildren(String parentId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _dummyData.where((item) => item.parentId == parentId).toList();
  }

  Future<List<ListItem>> getChildrenByLevel(String parentId, ListLevel childLevel) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _dummyData
        .where((item) => item.parentId == parentId && item.level == childLevel)
        .toList();
  }

  Future<List<ListItem>> searchItems(String query, ListLevel level, [String? parentId]) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _dummyData
        .where((item) =>
            item.level == level &&
            (parentId == null || item.parentId == parentId) &&
            (item.name.toLowerCase().contains(query.toLowerCase()) ||
             item.code.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }

  Future<ListItem?> getItemById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _dummyData.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasChildren(String parentId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _dummyData.any((item) => item.parentId == parentId);
  }
}