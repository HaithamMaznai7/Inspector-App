import 'package:cached_network_image/cached_network_image.dart';
import 'package:fahis_inspector/util/helpers/cached_image_key.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fahis_inspector/features/inspection_body_notes/components/editing_screen.dart';
import 'package:fahis_inspector/features/inspection_body_notes/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';

// Build a {value: label} lookup from cached body-note-types so we can show
// the human-readable label (e.g. "Scratch") beside each marker row instead
// of the raw Selection.value stored on Marker.type (e.g. "scratch"). Same
// pattern as inspection_body_notes_review.dart — labels are i18n-driven so
// resolving at render time keeps markers locale-correct.
Map<String, String> _buildTypeLabels() {
  if (!Hive.isBoxOpen('Assets')) return const {};
  final raw = Hive.box<List>('Assets').get('Assets-BodyNoteTypes');
  if (raw is! List) return const {};
  final map = <String, String>{};
  for (final item in raw) {
    if (item is Map) {
      final id = item['id'];
      if (id == null) continue;
      final label = (item['name'] ?? item['label'])?.toString();
      if (label != null && label.isNotEmpty) map['$id'] = label;
    }
  }
  return map;
}

class InspectionBodyTypeResults extends StatelessWidget {
  const InspectionBodyTypeResults({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionBodyController>(
      init: InspectionBodyBinding().instance,
      autoRemove: false,
      builder: (controller) {
        return Obx(() {
          final isLoading = controller.isLoading.value;
          final bodySides = controller.bodySides;

          if (isLoading && bodySides.isEmpty) {
            return const _BodyNotesSkeleton();
          }
          if (bodySides.isEmpty) {
            return const _BodyNotesEmpty();
          }

          // Wrap in ValueListenableBuilder so the type-label chip rebuilds
          // when OfflineSyncService finishes prefetching the body-note-types
          // asset. Without this the editor list shows raw ids ("4") on a
          // cold start until the screen is left and re-entered.
          Widget buildList(Map<String, String> typeLabels) =>
              ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.md,
              vertical: FSizes.sm,
            ),
            itemCount: bodySides.length,
            separatorBuilder: (_, _) => const SizedBox(height: FSizes.xs),
            itemBuilder: (context, index) {
              final body = bodySides[index];
            final noteCount = body.notes.length;
            final hasNotes = noteCount > 0;

            return Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                side: BorderSide(
                  color: hasNotes
                      ? FColors.primaryColor.withValues(alpha: 0.25)
                      : FColors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Theme(
                // Remove the default ExpansionTile divider
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: FSizes.md,
                    vertical: FSizes.xs,
                  ),
                  // ── Thumbnail ──
                  leading: GestureDetector(
                    onTap: () =>
                        Get.to(() => InspectionBodyTypeScreen(bodySide: body)),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            FSizes.borderRadiusSm,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: body.image,
                            cacheKey: stableCacheKey(body.image),
                            width: FSizes.iconCircleLg,
                            height: FSizes.iconCircleSm,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: FSizes.iconCircleLg,
                                height: FSizes.iconCircleSm,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (_, _, _) => Container(
                              width: FSizes.iconCircleLg,
                              height: FSizes.iconCircleSm,
                              color: FColors.grey.withValues(alpha: 0.1),
                              child: const Icon(
                                Iconsax.car,
                                color: FColors.grey,
                                size: FSizes.iconInlineSm,
                              ),
                            ),
                          ),
                        ),
                        // "Add" overlay badge
                        Container(
                          padding: const EdgeInsets.all(FSizes.xxs),
                          decoration: const BoxDecoration(
                            color: FColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: FSizes.iconXs,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Title + subtitle ──
                  title: Text(
                    body.part.label(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: hasNotes
                      ? Text(
                          '$noteCount ${FTexts.markerTitle.tr}',
                          style: Theme.of(context).textTheme.bodySmall?.apply(
                            color: FColors.primaryColor,
                          ),
                        )
                      : null,
                  // ── Expand arrow ──
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.arrow_down_1, size: FSizes.fontSizeLg, color: FColors.grey),
                    ],
                  ),
                  showTrailingIcon: false,
                  childrenPadding: const EdgeInsets.only(
                    left: FSizes.md,
                    right: FSizes.md,
                    bottom: FSizes.sm,
                  ),
                  children: [
                    if (!hasNotes)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: FSizes.sm,
                        ),
                        child: Text(
                          FTexts.markerAddPhoto.tr,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.apply(color: FColors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...body.notes.map(
                        (note) => _NoteItem(
                          note: note,
                          typeLabel: note.type == null
                              ? null
                              : (typeLabels[note.type] ?? note.type),
                          onEdit: () => controller.onCreateEdit(body, note),
                          onDelete: () => controller.onRemove(note),
                        ),
                      ),
                  ],
                ),
              ),
            );
            },
          );

          if (Hive.isBoxOpen('Assets')) {
            return ValueListenableBuilder(
              valueListenable: Hive.box<List>('Assets').listenable(
                keys: const ['Assets-BodyNoteTypes'],
              ),
              builder: (_, _, _) => buildList(_buildTypeLabels()),
            );
          }
          return buildList(const {});
        });
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton + empty state
// ─────────────────────────────────────────────────────────────────────────────

class _BodyNotesSkeleton extends StatelessWidget {
  const _BodyNotesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.md,
        vertical: FSizes.sm,
      ),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: FSizes.xs),
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: FSizes.buttonHeightLg,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          ),
        ),
      ),
    );
  }
}

class _BodyNotesEmpty extends StatelessWidget {
  const _BodyNotesEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Iconsax.note,
              size: FSizes.xl,
              color: FColors.darkGrey,
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              InspectionPage.bodyNotesEmpty.tr,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: FColors.darkGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single note row inside the expansion
// ─────────────────────────────────────────────────────────────────────────────

class _NoteItem extends StatelessWidget {
  const _NoteItem({
    required this.note,
    required this.typeLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final dynamic note;
  final String? typeLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Future<void> _confirmDelete(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? FColors.dark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        title: Text(
          InspectionPage.deleteBodyNote.tr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? FColors.light : FColors.dark,
          ),
        ),
        content: Text(
          InspectionPage.deleteBodyNoteConfirm.tr,
          style: TextStyle(
            color: isDark ? FColors.grey : FColors.darkGrey,
            fontSize: FSizes.fontSizeSm,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              FTexts.cancelBtn.tr,
              style: const TextStyle(color: FColors.darkGrey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              FTexts.deleteBtn.tr,
              style: const TextStyle(
                color: FColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete();
  }

  @override
  Widget build(BuildContext context) {
    // `note` is typed dynamic (accepted as Marker) so we can read the
    // transient isPending flag without importing the model here.
    final bool isPending = note.isPending == true;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: FSizes.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.sm,
          vertical: FSizes.xs,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
          border: Border.all(
            color: isPending
                ? FColors.warning.withValues(alpha: 0.35)
                : FColors.grey.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            // Type label (chip) + note text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if ((typeLabel != null && typeLabel!.isNotEmpty) || isPending)
                    Padding(
                      padding: const EdgeInsets.only(bottom: FSizes.xxs),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPending) ...[
                            const Icon(
                              Iconsax.cloud_minus,
                              size: FSizes.iconXs,
                              color: FColors.warning,
                            ),
                            const SizedBox(width: FSizes.xxs),
                          ],
                          if (typeLabel != null && typeLabel!.isNotEmpty)
                            Text(
                              '• $typeLabel',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.apply(
                                    color: isPending
                                        ? FColors.warning
                                        : FColors.primaryColor,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  Text(
                    note.note ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Note image indicator
            if (note.image != null) ...[
              const SizedBox(width: FSizes.xs),
              const Icon(Iconsax.image, size: FSizes.iconSm, color: FColors.grey),
            ],
            const SizedBox(width: FSizes.xs),
            // Edit
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(FSizes.sm),
              child: const Padding(
                padding: EdgeInsets.all(FSizes.xs),
                child: Icon(Iconsax.edit_2, size: FSizes.iconSm, color: FColors.warning),
              ),
            ),
            // Delete
            InkWell(
              onTap: () => _confirmDelete(context),
              borderRadius: BorderRadius.circular(FSizes.sm),
              child: const Padding(
                padding: EdgeInsets.all(FSizes.xs),
                child: Icon(Iconsax.trash, size: FSizes.iconSm, color: FColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
