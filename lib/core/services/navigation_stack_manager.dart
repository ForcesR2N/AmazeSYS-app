import 'package:get/get.dart';
import '../../list-pages/models/list_item.dart';

class PageState {
  final ListItem? selectedItem;
  final List<ListItem> currentItems;
  final List<ListItem> childItems;
  final dynamic selectedDetail;
  final ListLevel level;
  final bool isShowingDetail;
  final DateTime timestamp;

  PageState({
    this.selectedItem,
    required this.currentItems,
    required this.childItems,
    this.selectedDetail,
    required this.level,
    required this.isShowingDetail,
    required this.timestamp,
  });

  bool get isStale => DateTime.now().difference(timestamp).inMinutes > 5;
}

class NavigationStackManager extends GetxService {
  final RxList<PageState> _pageStack = <PageState>[].obs;
  final Rxn<ListLevel> _rootLevel = Rxn<ListLevel>();
  final int maxStackSize = 10;

  List<PageState> get pageStack => _pageStack;
  ListLevel? get rootLevel => _rootLevel.value;
  
  ListLevel? get currentLevel {
    if (_pageStack.isNotEmpty) {
      final lastPage = _pageStack.last;
      return lastPage.selectedItem?.level.nextLevel ?? lastPage.level;
    }
    return _rootLevel.value;
  }

  void setRootLevel(ListLevel level) {
    clear();
    _rootLevel.value = level;
  }

  void pushPage({
    ListItem? selectedItem,
    required List<ListItem> currentItems,
    required List<ListItem> childItems,
    dynamic selectedDetail,
    required ListLevel level,
    required bool isShowingDetail,
  }) {
    // Remove stale pages (older than 5 minutes)
    _pageStack.removeWhere((page) => page.isStale);
    
    // Limit stack size to prevent memory issues
    if (_pageStack.length >= maxStackSize) {
      _pageStack.removeRange(0, _pageStack.length - maxStackSize + 1);
    }

    final pageState = PageState(
      selectedItem: selectedItem,
      currentItems: List.from(currentItems),
      childItems: List.from(childItems),
      selectedDetail: selectedDetail,
      level: level,
      isShowingDetail: isShowingDetail,
      timestamp: DateTime.now(),
    );

    _pageStack.add(pageState);
  }

  PageState? popPage() {
    if (_pageStack.isNotEmpty) {
      return _pageStack.removeLast();
    }
    return null;
  }

  bool canGoBack() {
    return _pageStack.isNotEmpty;
  }

  void clear() {
    _pageStack.clear();
    _rootLevel.value = null;
  }

  List<String> getBreadcrumbTexts() {
    final List<String> texts = [];
    
    for (final page in _pageStack) {
      if (page.selectedItem != null) {
        texts.add(page.selectedItem!.name);
      }
    }
    
    if (currentLevel != null) {
      texts.add(currentLevel!.displayName);
    }
    
    return texts;
  }

  String getBreadcrumbPath() {
    return getBreadcrumbTexts().join(' > ');
  }

  static Future<NavigationStackManager> init() async {
    return NavigationStackManager();
  }
}