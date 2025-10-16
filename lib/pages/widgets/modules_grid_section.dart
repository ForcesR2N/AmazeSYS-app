import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/home_controller.dart';
import 'module_card.dart';

/// Grid section displaying all module cards
class ModulesGridSection extends StatelessWidget {
  const ModulesGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gridParams = _calculateGridParams(constraints.maxWidth);

            return Obx(
              () => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridParams.crossAxisCount,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: gridParams.aspectRatio,
                ),
                itemCount: controller.menuItems.length,
                itemBuilder: (context, index) {
                  return ModuleCard(
                    item: controller.menuItems[index],
                    index: index,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  _GridParams _calculateGridParams(double availableWidth) {
    const double minCardWidth = 160.0;
    final int crossAxisCount = (availableWidth / minCardWidth)
        .floor()
        .clamp(2, 3);

    final double cardWidth =
        (availableWidth - (AppSpacing.md * (crossAxisCount - 1))) /
            crossAxisCount;
    final double cardHeight = cardWidth * 1.2;
    final double aspectRatio = cardWidth / cardHeight;

    return _GridParams(
      crossAxisCount: crossAxisCount,
      aspectRatio: aspectRatio,
    );
  }
}

class _GridParams {
  final int crossAxisCount;
  final double aspectRatio;

  _GridParams({
    required this.crossAxisCount,
    required this.aspectRatio,
  });
}
