import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hierarchy_controller.dart';
import '../models/hierarchy_item.dart';
import '../routes/app_pages.dart';

class HierarchyPage extends StatefulWidget {
  const HierarchyPage({super.key});

  @override
  State<HierarchyPage> createState() => _HierarchyPageState();
}

class _HierarchyPageState extends State<HierarchyPage> {
  final HierarchyController controller = Get.find<HierarchyController>();
  final TextEditingController searchController = TextEditingController();
  late HierarchyLevel currentLevel;

  @override
  void initState() {
    super.initState();
    final String levelArg = Get.arguments as String;
    currentLevel = HierarchyLevel.values.firstWhere((e) => e.name == levelArg);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.selectedItem == null) {
        controller.loadRootItems(currentLevel);
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentLevel.displayName.toUpperCase(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final selectedItem = controller.selectedItem;
              if (selectedItem != null) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF1E40AF).withOpacity(0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              selectedItem.level.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedItem.displayName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E40AF),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedItem.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            
            Obx(() => controller.selectedItem != null 
              ? const SizedBox(height: 16) 
              : const SizedBox.shrink()),
            
            Obx(() => TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: controller.selectedItem != null 
                  ? 'Search ${controller.selectedItem!.level.nextLevel?.displayName ?? 'items'}...'
                  : 'Search ${currentLevel.displayName}...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        controller.clearSearch();
                      },
                    )
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (query) {
                if (controller.selectedItem != null) {
                  final nextLevel = controller.selectedItem!.level.nextLevel;
                  if (nextLevel != null) {
                    controller.search(query, nextLevel, controller.selectedItem!.id);
                  }
                } else {
                  controller.search(query, currentLevel);
                }
              },
            )),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: Obx(() {
                if (controller.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1E40AF),
                    ),
                  );
                }

                final itemsToShow = controller.selectedItem != null 
                  ? controller.childItems 
                  : controller.currentItems;

                if (itemsToShow.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.searchQuery.isNotEmpty 
                            ? 'No items found for "${controller.searchQuery}"'
                            : 'No items available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: itemsToShow.length,
                  itemBuilder: (context, index) {
                    final item = itemsToShow[index];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1E40AF).withOpacity(0.1),
                          child: Text(
                            item.level.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        title: Text(
                          item.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          item.description,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        onTap: () async {
                          final nextLevel = item.level.nextLevel;
                          if (nextLevel != null) {
                            await controller.loadItemWithChildren(item);
                            currentLevel = nextLevel;
                          } else {
                            Get.snackbar(
                              'Info',
                              'No more levels available',
                              backgroundColor: const Color(0xFF1E40AF).withOpacity(0.1),
                              colorText: const Color(0xFF1E40AF),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}