import 'package:get/get.dart';
import '../models/hierarchy_item.dart';
import '../services/hierarchy_service.dart';

class HierarchyController extends GetxController {
  final HierarchyService _hierarchyService = HierarchyService();
  
  final RxList<HierarchyItem> _currentItems = <HierarchyItem>[].obs;
  final RxList<HierarchyItem> _childItems = <HierarchyItem>[].obs;
  final Rxn<HierarchyItem> _selectedItem = Rxn<HierarchyItem>();
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;

  List<HierarchyItem> get currentItems => _currentItems;
  List<HierarchyItem> get childItems => _childItems;
  HierarchyItem? get selectedItem => _selectedItem.value;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;

  Future<void> loadRootItems(HierarchyLevel level) async {
    try {
      _isLoading.value = true;
      _selectedItem.value = null;
      _childItems.clear();
      _searchQuery.value = '';
      
      final items = await _hierarchyService.getItemsByLevel(level);
      _currentItems.value = items;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load items: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadItemWithChildren(HierarchyItem item) async {
    try {
      _isLoading.value = true;
      _selectedItem.value = item;
      _searchQuery.value = '';
      
      final nextLevel = item.level.nextLevel;
      if (nextLevel != null) {
        final children = await _hierarchyService.getChildrenByLevel(item.id, nextLevel);
        _childItems.value = children;
      } else {
        _childItems.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load children: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> search(String query, HierarchyLevel level, [String? parentId]) async {
    try {
      _searchQuery.value = query;
      
      if (query.isEmpty) {
        if (parentId != null) {
          final children = await _hierarchyService.getChildrenByLevel(parentId, level);
          _childItems.value = children;
        } else {
          final items = await _hierarchyService.getItemsByLevel(level);
          _currentItems.value = items;
        }
      } else {
        final results = await _hierarchyService.searchItems(query, level, parentId);
        if (parentId != null) {
          _childItems.value = results;
        } else {
          _currentItems.value = results;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Search failed: $e');
    }
  }

  void clearSearch() {
    _searchQuery.value = '';
    if (_selectedItem.value != null) {
      loadItemWithChildren(_selectedItem.value!);
    }
  }

  void reset() {
    _currentItems.clear();
    _childItems.clear();
    _selectedItem.value = null;
    _isLoading.value = false;
    _searchQuery.value = '';
  }
}