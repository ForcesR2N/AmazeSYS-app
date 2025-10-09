import '../models/hierarchy_item.dart';

class HierarchyService {
  static final List<HierarchyItem> _dummyData = [
    // Companies
    HierarchyItem(
      id: 'comp1',
      name: 'PT Amazink Jakarta',
      code: 'AMZ-JKT',
      description: 'Main company in Jakarta',
      level: HierarchyLevel.company,
    ),
    HierarchyItem(
      id: 'comp2',
      name: 'PT Amazink Surabaya',
      code: 'AMZ-SBY',
      description: 'Branch company in Surabaya',
      level: HierarchyLevel.company,
    ),
    HierarchyItem(
      id: 'comp3',
      name: 'PT Amazink Bali',
      code: 'AMZ-BAL',
      description: 'Branch company in Bali',
      level: HierarchyLevel.company,
    ),
    
    // Branches for comp1
    HierarchyItem(
      id: 'branch1',
      name: 'Cabang Menteng',
      code: 'JKT-MTG-001',
      description: 'Branch office in Menteng area',
      level: HierarchyLevel.branch,
      parentId: 'comp1',
    ),
    HierarchyItem(
      id: 'branch2',
      name: 'Cabang Kemang',
      code: 'JKT-KMG-002',
      description: 'Branch office in Kemang area',
      level: HierarchyLevel.branch,
      parentId: 'comp1',
    ),
    HierarchyItem(
      id: 'branch3',
      name: 'Cabang Pluit',
      code: 'JKT-PLT-003',
      description: 'Branch office in Pluit area',
      level: HierarchyLevel.branch,
      parentId: 'comp1',
    ),
    
    // Warehouses for branch1
    HierarchyItem(
      id: 'wh1',
      name: 'Gudang Utama',
      code: 'MTG-WH-001',
      description: 'Main warehouse for Menteng branch',
      level: HierarchyLevel.warehouse,
      parentId: 'branch1',
    ),
    HierarchyItem(
      id: 'wh2',
      name: 'Gudang Cadangan',
      code: 'MTG-WH-002',
      description: 'Backup warehouse for Menteng branch',
      level: HierarchyLevel.warehouse,
      parentId: 'branch1',
    ),
    HierarchyItem(
      id: 'wh3',
      name: 'Gudang Export',
      code: 'MTG-WH-003',
      description: 'Export warehouse for Menteng branch',
      level: HierarchyLevel.warehouse,
      parentId: 'branch1',
    ),
    
    // Products for wh1
    HierarchyItem(
      id: 'prod1',
      name: 'Smartphone Android',
      code: 'SA-001',
      description: 'Latest Android smartphone',
      level: HierarchyLevel.product,
      parentId: 'wh1',
    ),
    HierarchyItem(
      id: 'prod2',
      name: 'Laptop Gaming',
      code: 'LG-002',
      description: 'High performance gaming laptop',
      level: HierarchyLevel.product,
      parentId: 'wh1',
    ),
    HierarchyItem(
      id: 'prod3',
      name: 'Tablet Pro',
      code: 'TP-003',
      description: 'Professional tablet device',
      level: HierarchyLevel.product,
      parentId: 'wh1',
    ),
  ];

  Future<List<HierarchyItem>> getItemsByLevel(HierarchyLevel level) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyData.where((item) => item.level == level && item.parentId == null).toList();
  }

  Future<List<HierarchyItem>> getChildren(String parentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyData.where((item) => item.parentId == parentId).toList();
  }

  Future<List<HierarchyItem>> getChildrenByLevel(String parentId, HierarchyLevel childLevel) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyData
        .where((item) => item.parentId == parentId && item.level == childLevel)
        .toList();
  }

  Future<List<HierarchyItem>> searchItems(String query, HierarchyLevel level, [String? parentId]) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyData
        .where((item) =>
            item.level == level &&
            (parentId == null || item.parentId == parentId) &&
            (item.name.toLowerCase().contains(query.toLowerCase()) ||
             item.code.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }

  Future<HierarchyItem?> getItemById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _dummyData.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasChildren(String parentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _dummyData.any((item) => item.parentId == parentId);
  }
}