import 'dart:io';

import 'package:fahis_inspector/features/inspection_points/controller.dart';
import 'package:fahis_inspector/models/review_point.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionPointResults extends StatelessWidget {
  const InspectionPointResults({super.key});

  Widget _buildBadge(String value, Color color) {
    return Container(
      width: FSizes.iconMd + FSizes.xs,
      height: FSizes.iconMd + FSizes.xs,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: FSizes.fontSizeSm - 1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String iconUrl) {
    if (iconUrl.isEmpty) {
      return Icon(Iconsax.category, size: 24, color: FColors.primaryColor);
    }
    return _SvgNetworkIcon(url: iconUrl);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionPointsController>(
      init: InspectionPointsBinding().instance,
      builder: (controller) {
        final review = controller.review.value ?? ReviewPoint.set([]);
        final isLoading = controller.isLoading.value;
        if (isLoading) {
          return Center(
            child: CircularProgressIndicator(color: FColors.primaryColor),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.md,
              vertical: FSizes.sm,
            ),
            children: [
              // Header card with summary
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                  side: BorderSide(color: FColors.grey),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.md,
                    vertical: FSizes.sm,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => controller.generate(),
                        icon: const Icon(Iconsax.refresh),
                        tooltip: InspectionPage.resetPointsTitle.tr,
                        style: IconButton.styleFrom(
                          backgroundColor: FColors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                          ),
                        ),
                      ),
                      const SizedBox(width: FSizes.sm),
                      Expanded(
                        child: Text(
                          InspectionPage.pointsReview.tr,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        textDirection: TextDirection.ltr,
                        children: [
                          _buildBadge('${review.good}', FColors.success),
                          const SizedBox(width: FSizes.xs),
                          _buildBadge('${review.note}', FColors.warning),
                          const SizedBox(width: FSizes.xs),
                          _buildBadge('${review.none}', FColors.darkGrey),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: FSizes.xs),

              // Category list
              ...review.cats.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(bottom: FSizes.xs),
                  child: Card(
                    elevation: 1,
                    shadowColor: FColors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    ),
                    child: InkWell(
                      onTap: () => controller.onEdit(cat: cat),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.md,
                          vertical: FSizes.md,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: FSizes.iconCircleSm,
                              height: FSizes.iconCircleSm,
                              decoration: BoxDecoration(
                                color: FColors.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                              ),
                              alignment: Alignment.center,
                              child: _buildCategoryIcon(cat.category.icon),
                            ),
                            const SizedBox(width: FSizes.md),
                            Expanded(
                              child: Text(
                                cat.category.title,
                                style: Theme.of(context).textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              textDirection: TextDirection.ltr,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildBadge('${cat.good}', FColors.success),
                                const SizedBox(width: FSizes.xs),
                                _buildBadge('${cat.note}', FColors.warning),
                                const SizedBox(width: FSizes.xs),
                                _buildBadge('${cat.none}', FColors.darkGrey),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SvgNetworkIcon extends StatefulWidget {
  final String url;
  const _SvgNetworkIcon({required this.url});

  @override
  State<_SvgNetworkIcon> createState() => _SvgNetworkIconState();
}

class _SvgNetworkIconState extends State<_SvgNetworkIcon> {
  static final Map<String, String> _cache = {};

  String? _svgString;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  Future<void> _loadSvg() async {
    if (_cache.containsKey(widget.url)) {
      if (mounted) setState(() => _svgString = _cache[widget.url]);
      return;
    }

    try {
      final request = await HttpClient().getUrl(Uri.parse(widget.url));
      final response = await request.close();
      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        var svg = String.fromCharCodes(bytes);
        // Remove <style> blocks that flutter_svg cannot handle
        svg = svg.replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>'), '');
        _cache[widget.url] = svg;
        if (mounted) setState(() => _svgString = svg);
      } else {
        if (mounted) setState(() => _hasError = true);
      }
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Icon(Iconsax.category, size: 24, color: FColors.primaryColor);
    }

    if (_svgString == null) {
      return const SizedBox(width: FSizes.iconMd, height: FSizes.iconMd);
    }

    return SvgPicture.string(
      _svgString!,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      colorFilter: const ColorFilter.mode(
        FColors.primaryColor,
        BlendMode.srcIn,
      ),
    );
  }
}
