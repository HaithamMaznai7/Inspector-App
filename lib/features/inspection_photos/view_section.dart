import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:fahis_inspector/features/inspection_photos/components/photo_upload_shimmer.dart';
import 'package:fahis_inspector/features/inspection_photos/controller.dart';
import 'package:fahis_inspector/models/photo.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';

import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

// ignore_for_file: avoid_print
void _log(String msg) {
  if (kDebugMode) print('[PHOTOS_UI] $msg');
}

/// Tabbed photo album section shown inside the inspection steps screen.
///
/// Layout:
/// - Category pill tabs at the top (one per photo type from API)
/// - 3-column photo grid per tab (empty / uploading / uploaded states)
/// - "Add Photo" outlined button at the bottom when slots are available
class AlbumPhotos extends StatelessWidget {
  const AlbumPhotos({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionPhotosController>(
      init: InspectionPhotosBinding().instance,
      builder: (controller) {
        return Obx(() {
          final isLoading = controller.isLoading.value;
          final allPhotos = controller.photos;

          if (isLoading && allPhotos.isEmpty) {
            return const _PhotoGridShimmer();
          }

          final categories = controller.categories;
          final currentCategory = controller.category.value;

          if (categories.isEmpty) {
            return _EmptyState(controller: controller);
          }

          final catPhotos = allPhotos
              .where((p) => p.type == currentCategory)
              .toList();

          return Column(
            children: [
              // ── Category pill tabs ──
              _CategoryTabs(
                controller: controller,
                categories: categories,
                currentCategory: currentCategory,
              ),

              // ── Photo grid ──
              Expanded(
                child: _PhotoGrid(controller: controller, photos: catPhotos),
              ),
            ],
          );
        });
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category pill tabs
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.controller,
    required this.categories,
    required this.currentCategory,
  });

  final InspectionPhotosController controller;
  final List<String> categories;
  final String? currentCategory;

  String _localizeCategory(String? cat) {
    if (cat == null) return InspectionPage.photosTitle.tr;
    switch (cat.toLowerCase()) {
      case 'exterior':
        return InspectionPage.photoCategoryExterior.tr;
      case 'interior':
        return InspectionPage.photoCategoryInterior.tr;
      default:
        return cat;
    }
  }

  bool get _hasUploaded => controller.photos.any((p) => p.image != null);

  void _confirmDeleteAll(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? FColors.dark : FColors.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.sm),
              decoration: BoxDecoration(
                color: FColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.trash,
                color: FColors.error,
                size: FSizes.fontSizeLg,
              ),
            ),
            const SizedBox(width: FSizes.sm),
            Expanded(
              child: Text(
                InspectionPage.deleteAllPhotos.tr,
                style: Theme.of(
                  ctx,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          InspectionPage.deleteAllPhotosConfirm.tr,
          style: Theme.of(ctx).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              FTexts.cancelBtn.tr,
              style: TextStyle(
                color: isDark ? FColors.grey : FColors.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.deleteAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
              ),
            ),
            child: Text(
              FTexts.deleteBtn.tr,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.md,
        vertical: FSizes.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: FColors.grey.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Category chips ──
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = cat == currentCategory;
                  final catPhotos = controller.photos
                      .where((p) => p.type == cat)
                      .toList();
                  final uploaded = catPhotos
                      .where((p) => p.image != null)
                      .length;
                  final total = catPhotos.length;

                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: FSizes.xs),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_localizeCategory(cat)),
                          const SizedBox(width: FSizes.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: FSizes.xs,
                              vertical: FSizes.dividerHeight,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : FColors.primaryColor.withValues(
                                      alpha: 0.15,
                                    ),
                              borderRadius: BorderRadius.circular(
                                FSizes.borderRadiusMd,
                              ),
                            ),
                            child: Text(
                              '$uploaded/$total',
                              style: TextStyle(
                                fontSize: FSizes.fontSizeXs,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : FColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : FColors.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: FSizes.fontSizeSm,
                      ),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: FColors.primaryColor,
                      backgroundColor: FColors.primaryColor.withValues(
                        alpha: 0.08,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? FColors.primaryColor
                            : FColors.primaryColor.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          FSizes.borderRadiusLg,
                        ),
                      ),
                      onSelected: (_) {
                        _log(
                          'chip tapped → $cat (was: ${controller.category.value})',
                        );
                        controller.category.value = cat;
                        controller.update();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Delete-all button — only visible when any photo is uploaded ──
          if (_hasUploaded) ...[
            const SizedBox(width: FSizes.xs),
            Obx(
              () => controller.isResetting.value
                  ? const SizedBox(
                      width: FSizes.xl,
                      height: FSizes.xl,
                      child: Padding(
                        padding: EdgeInsets.all(FSizes.sm),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: FColors.error,
                        ),
                      ),
                    )
                  : Tooltip(
                      message: InspectionPage.deleteAllPhotos.tr,
                      child: InkWell(
                        onTap: () => _confirmDeleteAll(context),
                        borderRadius: BorderRadius.circular(
                          FSizes.borderRadiusLg,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(FSizes.sm),
                          decoration: BoxDecoration(
                            color: FColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              FSizes.borderRadiusLg,
                            ),
                            border: Border.all(
                              color: FColors.error.withValues(
                                alpha: isDark ? 0.25 : 0.2,
                              ),
                            ),
                          ),
                          child: const Icon(
                            Iconsax.trash,
                            color: FColors.error,
                            size: FSizes.iconSm,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Photo grid
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.controller, required this.photos});

  final InspectionPhotosController controller;
  final List<Photo> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.camera,
              size: FSizes.iconCircleMd,
              color: FColors.grey.withValues(alpha: 0.35),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              InspectionPage.noPhotosYet.tr,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.apply(color: FColors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(FSizes.md),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: FSizes.sm,
        mainAxisSpacing: FSizes.sm,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final photo = photos[index];
        final isUploading = controller.uploadingIds.contains(photo.id);
        return _PhotoGridCell(
          photo: photo,
          isUploading: isUploading,
          onTap: isUploading
              ? null
              : photo.image != null
              ? () => _showFullImage(context, photo)
              : () => controller.picking(photo),
          onDelete: photo.image != null
              ? () => _confirmDelete(context, controller, photo)
              : null,
        );
      },
    );
  }

  static void _showFullImage(BuildContext context, Photo photo) {
    final url = photo.image!;
    showImageViewer(
      context,
      CachedNetworkImageProvider(url.startsWith('//') ? 'https:$url' : url),
      useSafeArea: true,
      swipeDismissible: true,
    );
  }

  static void _confirmDelete(
    BuildContext context,
    InspectionPhotosController controller,
    Photo photo,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(InspectionPage.deletePhoto.tr),
        content: Text(InspectionPage.deletePhotoConfirm.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              InspectionPage.cancelBtn.tr,
              style: TextStyle(color: FColors.darkGrey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.delete(photo);
            },
            child: Text(
              FTexts.deleteBtn.tr,
              style: const TextStyle(color: FColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single photo grid cell
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoGridCell extends StatelessWidget {
  const _PhotoGridCell({
    required this.photo,
    required this.isUploading,
    required this.onTap,
    required this.onDelete,
  });

  final Photo photo;
  final bool isUploading;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  bool get _hasImage => photo.image != null || photo.file != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildCard(context)),
        const SizedBox(height: FSizes.xs),
        Text(
          photo.title,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    // ── Uploading state: shimmer, not tappable ──
    if (isUploading) {
      return LayoutBuilder(
        builder: (context, constraints) => ClipRRect(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          child: PhotoUploadShimmer(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            borderRadius: FSizes.borderRadiusLg,
          ),
        ),
      );
    }

    // ── Uploaded state ──
    if (_hasImage) {
      return GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              child: photo.file != null
                  ? Image.file(photo.file!, fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: photo.image!,
                      fit: BoxFit.cover,
                      placeholder: (ctx, _) => _shimmerPlaceholder(ctx),
                      errorWidget: (_, _, _) => _placeholder(),
                    ),
            ),
            // Delete badge — top-start
            PositionedDirectional(
              top: FSizes.xs,
              start: FSizes.xs,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(FSizes.xs),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.trash,
                    color: FColors.error,
                    size: FSizes.fontSizeSm,
                  ),
                ),
              ),
            ),
            // Checkmark badge — bottom-end
            PositionedDirectional(
              bottom: FSizes.xs,
              end: FSizes.xs,
              child: Container(
                padding: const EdgeInsets.all(FSizes.xs),
                decoration: const BoxDecoration(
                  color: FColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: FSizes.iconXs,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Empty state: dashed border, camera icon, tappable ──
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: FColors.primaryColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            Iconsax.camera,
            color: FColors.primaryColor,
            size: FSizes.iconMd,
          ),
        ),
      ),
    );
  }

  Widget _shimmerPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
      child: Container(color: isDark ? Colors.grey[800] : Colors.white),
    );
  }

  Widget _placeholder() {
    return Container(
      color: FColors.grey.withValues(alpha: 0.15),
      child: const Center(
        child: Icon(Iconsax.image, color: FColors.grey, size: FSizes.iconMd),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-grid shimmer shown while photos are loading for the first time
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoGridShimmer extends StatelessWidget {
  const _PhotoGridShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[600]! : Colors.grey[100]!;

    return Column(
      children: [
        // ── Fake tab-bar shimmer ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.sm,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: FColors.grey.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: List.generate(2, (i) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: FSizes.xs),
                child: Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: FSizes.buttonWidth,
                    height: FSizes.xl,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(
                        FSizes.borderRadiusLg,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // ── Fake photo grid shimmer ──
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(FSizes.md),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: FSizes.sm,
              mainAxisSpacing: FSizes.sm,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, _) => Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state (no categories loaded yet)
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.controller});

  final InspectionPhotosController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.camera,
            size: FSizes.iconCircleMd,
            color: FColors.grey.withValues(alpha: 0.35),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            InspectionPage.noPhotosYet.tr,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.apply(color: FColors.grey),
          ),
        ],
      ),
    );
  }
}
