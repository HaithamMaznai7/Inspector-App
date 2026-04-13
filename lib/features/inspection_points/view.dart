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

  // ── compact tinted badge ────────────────────────────────────────────────────
  Widget _badge(String value, Color color) => Container(
    constraints: const BoxConstraints(minWidth: 32),
    padding: const EdgeInsets.symmetric(horizontal: FSizes.xs, vertical: FSizes.xxs),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
      border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
    ),
    alignment: Alignment.center,
    child: Text(
      value,
      style: TextStyle(
        color: color,
        fontSize: FSizes.fontSizeXs,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  // ── category icon ───────────────────────────────────────────────────────────
  Widget _catIcon(String iconUrl) {
    if (iconUrl.isEmpty) {
      return Icon(Iconsax.category, size: FSizes.iconInlineSm, color: FColors.primaryColor);
    }
    return _SvgNetworkIcon(url: iconUrl);
  }

  // ── summary stat tile ───────────────────────────────────────────────────────
  Widget _statTile(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(
        vertical: FSizes.sm,
        horizontal: FSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: FSizes.fontSizeLg),
          const SizedBox(height: FSizes.xs),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: FSizes.fontSizeMd,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : FColors.primaryColor.withValues(alpha: 0.05);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : FColors.grey.withValues(alpha: 0.55);

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

        final total = review.all;
        final answered = review.good + review.note;
        final progress = total > 0 ? answered / total : 0.0;
        final progressColor = progress == 1.0
            ? FColors.success
            : FColors.primaryColor;

        return RefreshIndicator(
          color: FColors.primaryColor,
          onRefresh: controller.onRefresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              FSizes.md,
              FSizes.sm,
              FSizes.md,
              FSizes.lg,
            ),
            children: [
              // ── Summary card ──────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.all(FSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + refresh
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            InspectionPage.pointsReview.tr,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Tooltip(
                          message: InspectionPage.resetPointsTitle.tr,
                          child: InkWell(
                            onTap: () => controller.generate(),
                            borderRadius: BorderRadius.circular(
                              FSizes.borderRadiusMd,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(FSizes.sm),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.07,
                                ),
                                borderRadius: BorderRadius.circular(
                                  FSizes.borderRadiusMd,
                                ),
                              ),
                              child: Icon(
                                Iconsax.refresh,
                                size: FSizes.iconSm,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: FSizes.sm),

                    // Progress bar + count label
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: FSizes.xs),
                    Text(
                      '$answered / $total',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: FSizes.sm),

                    // Three stat tiles
                    Row(
                      children: [
                        _statTile(
                          context,
                          label: FTexts.good.tr,
                          count: review.good,
                          color: FColors.success,
                          icon: Iconsax.tick_circle,
                        ),
                        const SizedBox(width: FSizes.xs),
                        _statTile(
                          context,
                          label: FTexts.notes.tr,
                          count: review.note,
                          color: FColors.warning,
                          icon: Iconsax.note_21,
                        ),
                        const SizedBox(width: FSizes.xs),
                        _statTile(
                          context,
                          label: FTexts.na.tr,
                          count: review.none,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.45,
                          ),
                          icon: Iconsax.minus_cirlce,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FSizes.sm),

              // ── Category rows ─────────────────────────────────────────────
              ...review.cats.map((cat) {
                final catTotal = cat.good + cat.note + cat.none;
                final catAnswered = cat.good + cat.note;
                final catProgress = catTotal > 0 ? catAnswered / catTotal : 0.0;
                final catProgressColor = catProgress == 1.0
                    ? FColors.success
                    : FColors.primaryColor.withValues(alpha: 0.7);

                return Padding(
                  padding: const EdgeInsets.only(bottom: FSizes.sm),
                  child: Material(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => controller.onEdit(cat: cat),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(
                            FSizes.borderRadiusLg,
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: FSizes.md,
                                vertical: FSizes.md,
                              ),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: FSizes.iconCircleSm,
                                    height: FSizes.iconCircleSm,
                                    decoration: BoxDecoration(
                                      color: FColors.primaryColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        FSizes.borderRadiusSm,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: _catIcon(cat.category.icon),
                                  ),
                                  const SizedBox(width: FSizes.md),

                                  // Title + sub-count
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cat.category.title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: FSizes.xxs),
                                        Text(
                                          '$catAnswered / $catTotal',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.4),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Badges (always LTR)
                                  Row(
                                    textDirection: TextDirection.ltr,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _badge('${cat.good}', FColors.success),
                                      const SizedBox(width: FSizes.xs),
                                      _badge('${cat.note}', FColors.warning),
                                      const SizedBox(width: FSizes.xs),
                                      _badge(
                                        '${cat.none}',
                                        theme.colorScheme.onSurface.withValues(
                                          alpha: 0.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Bottom progress strip
                            LinearProgressIndicator(
                              value: catProgress,
                              minHeight: 3,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                catProgressColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
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
        final raw = String.fromCharCodes(bytes);
        final svg = _simplifyForIcon(raw);
        _cache[widget.url] = svg;
        if (mounted) setState(() => _svgString = svg);
      } else {
        if (mounted) setState(() => _hasError = true);
      }
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  /// Strips the SVG down to only the coloured foreground paths so
  /// flutter_svg can render it as a simple monochrome icon.
  ///
  /// The S3 SVGs use CSS classes: `.cls-1{fill:#fff}` for white
  /// background/cutout shapes and `.cls-2`, `.cls-3` etc. for the
  /// actual icon shapes (gradient fills). We:
  ///  1. Find which classes have a white fill.
  ///  2. Remove all <path elements that use those classes.
  ///  3. Remove <defs entirely (styles, gradients, xlink refs).
  ///  4. Clean up leftover class/xlink attributes.
  ///
  /// The remaining paths default to black fill, and the colorFilter
  /// in build() recolours them to primaryColor.
  static String _simplifyForIcon(String svg) {
    // 1. Find CSS classes with white fills (#fff / #ffffff)
    final whiteClasses = <String>{};
    final styleMatch = RegExp(
      r'<style[^>]*>([\s\S]*?)</style>',
    ).firstMatch(svg);
    if (styleMatch != null) {
      final css = styleMatch.group(1)!;
      for (final m in RegExp(
        r'\.([\w-]+)\s*\{[^}]*fill\s*:\s*#(?:fff(?:fff)?)\b',
        caseSensitive: false,
      ).allMatches(css)) {
        whiteClasses.add(m.group(1)!);
      }
    }

    // 2. Remove <path> elements whose class is a white-fill class
    for (final cls in whiteClasses) {
      svg = svg.replaceAll(
        RegExp('<path[^>]*\\bclass="$cls"[^>]*/>', dotAll: true),
        '',
      );
    }

    // 3. Remove <defs>…</defs> entirely
    svg = svg.replaceAll(RegExp(r'<defs[\s\S]*?</defs>'), '');

    // 4. Remove leftover class attributes and xlink namespace
    svg = svg.replaceAll(RegExp(r'\s+class="[^"]*"'), '');
    svg = svg.replaceAll(RegExp(r'\s+xmlns:xlink="[^"]*"'), '');

    return svg;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Icon(Iconsax.category, size: FSizes.iconMd, color: FColors.primaryColor);
    }

    if (_svgString == null) {
      return const SizedBox(width: FSizes.iconMd, height: FSizes.iconMd);
    }

    return SvgPicture.string(
      _svgString!,
      width: FSizes.iconMd,
      height: FSizes.iconMd,
      fit: BoxFit.contain,
      colorFilter: const ColorFilter.mode(
        FColors.primaryColor,
        BlendMode.srcIn,
      ),
    );
  }
}
