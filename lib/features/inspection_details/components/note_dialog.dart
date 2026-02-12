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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: (_isFinished ? FColors.primaryColor : FColors.error)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFinished ? Iconsax.send_1 : Iconsax.close_circle,
                color: _isFinished ? FColors.primaryColor : FColors.error,
                size: 24,
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
            const SizedBox(height: FSizes.lg),

            // ── Text field ──
            TextField(
              controller: _controller,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: InspectionPage.noteOptionalHint.tr,
                hintStyle: theme.textTheme.bodySmall?.apply(color: FColors.grey),
                filled: true,
                fillColor: FColors.grey.withValues(alpha: 0.06),
                contentPadding: const EdgeInsets.all(FSizes.md),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  borderSide: BorderSide(
                    color: FColors.grey.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  borderSide: BorderSide(
                    color: FColors.grey.withValues(alpha: 0.2),
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
                      foregroundColor: FColors.grey,
                      side: BorderSide(color: FColors.grey.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(InspectionPage.cancelBtn.tr),
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: _controller.text.trim()),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
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
