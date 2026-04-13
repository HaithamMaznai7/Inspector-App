import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fahis_inspector/features/inspection_body_notes/components/editing_screen.dart';
import 'package:fahis_inspector/features/inspection_body_notes/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionBodyTypeResults extends StatelessWidget {
  const InspectionBodyTypeResults({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionBodyController>(
      init: InspectionBodyBinding().instance,
      autoRemove: false,
      builder: (controller) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.sm,
          ),
          itemCount: controller.bodySides.length,
          separatorBuilder: (_, _) => const SizedBox(height: FSizes.xs),
          itemBuilder: (context, index) {
            final body = controller.bodySides[index];
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
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single note row inside the expansion
// ─────────────────────────────────────────────────────────────────────────────

class _NoteItem extends StatelessWidget {
  const _NoteItem({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final dynamic note;
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
          border: Border.all(color: FColors.grey.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            // Note text
            Expanded(
              child: Text(
                note.note ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
