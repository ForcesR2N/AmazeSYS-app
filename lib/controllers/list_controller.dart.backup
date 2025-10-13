import 'dart:async';
import 'package:get/get.dart';
import '../models/list_item.dart';
import '../services/list_service.dart';

class ListController extends GetxController {
  final ListService _listService = ListService();
  
  final RxList<ListItem> _currentItems = <ListItem>[].obs;
  final RxList<ListItem> _childItems = <ListItem>[].obs;
  final Rxn<ListItem> _selectedItem = Rxn<ListItem>();
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  
  Timer? _debounce;

  List<ListItem> get currentItems => _currentItems;
  List<ListItem> get childItems => _childItems;
  ListItem? get selectedItem => _selectedItem.value;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;

  Future<void> loadRootItems(ListLevel level) async {
    try {
      _isLoading.value = true;
      _selectedItem.value = null;
      _childItems.clear();
      _searchQuery.value = '';
      
      final items = await _listService.getItemsByLevel(level);
      _currentItems.value = items;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load items: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadItemWithChildren(ListItem item) async {
    try {
      _isLoading.value = true;
      _selectedItem.value = item;
      _searchQuery.value = '';
      
      final nextLevel = item.level.nextLevel;
      if (nextLevel != null) {
        final children = await _listService.getChildrenByLevel(item.id, nextLevel);
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

  Future<void> search(String query, ListLevel level, [String? parentId]) async {
    try {
      _searchQuery.value = query;
      
      if (query.isEmpty) {
        if (parentId != null) {
          final children = await _listService.getChildrenByLevel(parentId, level);
          _childItems.value = children;
        } else {
          final items = await _listService.getItemsByLevel(level);
          _currentItems.value = items;
        }
      } else {
        final results = await _listService.searchItems(query, level, parentId);
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

  // Debounced search to avoid rapid API calls
  void searchWithDebounce(String query, ListLevel level, {String? parentId}) {
    // Cancel existing timer if active
    _debounce?.cancel();
    
    // Create new timer with 300ms delay
    _debounce = Timer(const Duration(milliseconds: 300), () {
      search(query, level, parentId);
    });
  }

  void reset() {
    _currentItems.clear();
    _childItems.clear();
    _selectedItem.value = null;
    _isLoading.value = false;
    _searchQuery.value = '';
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}