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
          separatorBuilder: (_, __) => const SizedBox(height: FSizes.xs),
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
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: FSizes.md,
                    vertical: FSizes.xs,
                  ),
                  // ── Thumbnail ──
                  leading: GestureDetector(
                    onTap: () =>
                        Get.to(InspectionBodyTypeScreen(bodySide: body)),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(FSizes.borderRadiusSm),
                          child: CachedNetworkImage(
                            imageUrl: body.image,
                            width: 52,
                            height: 42,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 52,
                                height: 42,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 52,
                              height: 42,
                              color: FColors.grey.withValues(alpha: 0.1),
                              child: const Icon(Iconsax.car,
                                  color: FColors.grey, size: 20),
                            ),
                          ),
                        ),
                        // "Add" overlay badge
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: FColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 10),
                        ),
                      ],
                    ),
                  ),
                  // ── Title + subtitle ──
                  title: Text(
                    body.part.label(),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: hasNotes
                      ? Text(
                          '$noteCount ${FTexts.markerTitle.tr}',
                          style: Theme.of(context).textTheme.bodySmall?.apply(
                                color: FColors.primaryColor,
                              ),
                        )
                      : null,
                  // ── Note count badge ──
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasNotes)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: FColors.primaryColor.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(FSizes.borderRadiusLg),
                          ),
                          child: Text(
                            '$noteCount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: FColors.primaryColor,
                            ),
                          ),
                        ),
                      const SizedBox(width: FSizes.xs),
                      Icon(
                        Iconsax.arrow_down_1,
                        size: 18,
                        color: FColors.grey,
                      ),
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
                        padding:
                            const EdgeInsets.symmetric(vertical: FSizes.sm),
                        child: Text(
                          FTexts.markerAddPhoto.tr,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.apply(color: FColors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...body.notes.map((note) => _NoteItem(
                            note: note,
                            onEdit: () => controller.onCreateEdit(body, note),
                            onDelete: () => controller.onRemove(note),
                          )),
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
            // Note type chip
            if (note.type != null)
              Container(
                margin: const EdgeInsetsDirectional.only(end: FSizes.xs),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: FColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                ),
                child: Text(
                  note.type ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: FColors.warning,
                  ),
                ),
              ),
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
              const Icon(Iconsax.image, size: 16, color: FColors.grey),
            ],
            const SizedBox(width: FSizes.xs),
            // Edit
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(FSizes.sm),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Iconsax.edit_2, size: 16, color: FColors.warning),
              ),
            ),
            // Delete
            InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(FSizes.sm),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Iconsax.trash, size: 16, color: FColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
