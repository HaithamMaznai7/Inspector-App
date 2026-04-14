import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NoteInputDialog extends StatefulWidget {
  final String status;
  final String? note;

  const NoteInputDialog({super.key, required this.status, this.note});

  @override
  State<NoteInputDialog> createState() => _NoteInputDialogState();
}

class _NoteInputDialogState extends State<NoteInputDialog> {
  final TextEditingController _controller = TextEditingController();

  bool get _isFinished => widget.status == 'finished';

  @override
  void initState() {
    super.initState();
    _controller.text = widget.note ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: FSizes.lg),
      child: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──
            Container(
              width: FSizes.iconCircleLg,
              height: FSizes.iconCircleLg,
              decoration: BoxDecoration(
                color: (_isFinished ? FColors.primaryColor : FColors.error)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFinished ? Iconsax.send_1 : Iconsax.close_circle,
                color: _isFinished ? FColors.primaryColor : FColors.error,
                size: FSizes.iconMd,
              ),
            ),
            const SizedBox(height: FSizes.md),

            // ── Title ──
            Text(
              _isFinished
                  ? InspectionPage.generalNoteTitle.tr
                  : InspectionPage.rejectionNoteTitle.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              _isFinished
                  ? InspectionPage.submitConfirmSubtitle.tr
                  : InspectionPage.rejectConfirmSubtitle.tr,
              style: theme.textTheme.bodySmall?.apply(color: FColors.darkGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.lg),

            // ── Label ──
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      InspectionPage.addNoteLabel.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: FSizes.xs),
                  Flexible(
                    child: Text(
                      '(${InspectionPage.optionalTag.tr})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.apply(
                        color: FColors.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.sm),

            // ── Text field ──
            TextField(
              controller: _controller,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: InspectionPage.noteOptionalHint.tr,
                hintStyle: theme.textTheme.bodySmall?.apply(
                  color: FColors.darkGrey,
                ),
                filled: true,
                fillColor: FColors.grey.withValues(alpha: 0.06),
                contentPadding: const EdgeInsets.all(FSizes.md),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(
                      255,
                      120,
                      120,
                      120,
                    ).withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(
                      255,
                      70,
                      70,
                      70,
                    ).withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  borderSide: const BorderSide(color: FColors.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: FSizes.lg),

            // ── Buttons ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: null),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 102, 101, 101),
                      side: BorderSide(color: FColors.darkGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          FSizes.borderRadiusMd,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: FSizes.iconXs),
                    ),
                    child: Text(InspectionPage.cancelBtn.tr),
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: _controller.text.trim()),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: FSizes.iconXs),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          FSizes.borderRadiusMd,
                        ),
                      ),
                    ),
                    child: Text(InspectionPage.confirmSubmit.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
