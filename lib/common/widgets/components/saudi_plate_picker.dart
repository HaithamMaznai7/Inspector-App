import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/plate_converter.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Saudi license-plate input widget.
///
/// Each letter field accepts only the 17 valid Saudi plate letters.
/// Invalid characters are silently rejected with a shake animation.
/// Arabic input is auto-converted to the English equivalent.
/// Focus auto-advances / auto-backs between boxes.
class SaudiPlatePicker extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onChanged;

  const SaudiPlatePicker({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  State<SaudiPlatePicker> createState() => _SaudiPlatePickerState();
}

class _SaudiPlatePickerState extends State<SaudiPlatePicker> {
  final _letterCtrl = List.generate(3, (_) => TextEditingController());
  final _letterFocus = List.generate(3, (_) => FocusNode());
  final _digitCtrl = List.generate(4, (_) => TextEditingController());
  final _digitFocus = List.generate(4, (_) => FocusNode());

  bool _internalChange = false;

  @override
  void initState() {
    super.initState();
    _load();
    widget.controller.addListener(_onExternalControllerChanged);
  }

  @override
  void didUpdateWidget(SaudiPlatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onExternalControllerChanged);
      widget.controller.addListener(_onExternalControllerChanged);
      _load();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onExternalControllerChanged);
    for (final c in _letterCtrl) {
      c.dispose();
    }
    for (final f in _letterFocus) {
      f.dispose();
    }
    for (final c in _digitCtrl) {
      c.dispose();
    }
    for (final f in _digitFocus) {
      f.dispose();
    }
    super.dispose();
  }

  void _onExternalControllerChanged() {
    if (!_internalChange) setState(_load);
  }

  void _load() {
    final normalized = PlateConverter.normalize(widget.controller.text);
    final parsed = PlateConverter.parse(normalized);

    for (int i = 0; i < 3; i++) {
      if (i < parsed.letters.length) {
        final l = parsed.letters[i];
        _letterCtrl[i].text = PlateConverter.validLetters.contains(l) ? l : '';
      } else {
        _letterCtrl[i].text = '';
      }
    }

    for (int i = 0; i < 4; i++) {
      _digitCtrl[i].text = i < parsed.digits.length ? parsed.digits[i] : '';
    }
  }

  void _save() {
    final letters = _letterCtrl.map((c) => c.text).join();
    final digits = _digitCtrl.map((c) => c.text).join();

    _internalChange = true;
    widget.controller.text = '$letters $digits'.trim();
    _internalChange = false;

    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet =
        ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);
    final boxHeight = isTablet ? 62.0 : 54.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Input row ─────────────────────────────────────────────────────
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3 letter text-fields
              for (int i = 0; i < 3; i++) ...[
                Expanded(
                  child: _LetterTextField(
                    ctrl: _letterCtrl[i],
                    focus: _letterFocus[i],
                    idx: i,
                    allLetterFocus: _letterFocus,
                    firstDigitFocus: _digitFocus[0],
                    isDark: isDark,
                    boxHeight: boxHeight,
                    onChanged: () => setState(_save),
                  ),
                ),
                if (i < 2) const SizedBox(width: 6),
              ],

              // Separator
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: _FieldDivider(isDark: isDark, height: boxHeight - 4),
              ),

              // 4 digit text-fields
              for (int i = 0; i < 4; i++) ...[
                Expanded(
                  child: _DigitBox(
                    ctrl: _digitCtrl[i],
                    focus: _digitFocus,
                    idx: i,
                    isDark: isDark,
                    boxHeight: boxHeight,
                    onChanged: () => setState(_save),
                    onBackToLetters: i == 0
                        ? () => _letterFocus[2].requestFocus()
                        : null,
                  ),
                ),
                if (i < 3) const SizedBox(width: 6),
              ],
            ],
          ),
        ),

        // ── Sub-labels ────────────────────────────────────────────────────
        Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'plateLettersLabel'.tr,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: FColors.darkGrey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  flex: 4,
                  child: Text(
                    'plateNumbersLabel'.tr,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: FColors.darkGrey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Error text ────────────────────────────────────────────────────
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: FSizes.xs),
            child: Text(
              widget.errorText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: FColors.error),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Letter text-field ─────────────────────────────────────────────────────────

class _LetterTextField extends StatefulWidget {
  final TextEditingController ctrl;
  final FocusNode focus;
  final int idx;
  final List<FocusNode> allLetterFocus;
  final FocusNode firstDigitFocus;
  final bool isDark;
  final double boxHeight;
  final VoidCallback onChanged;

  const _LetterTextField({
    required this.ctrl,
    required this.focus,
    required this.idx,
    required this.allLetterFocus,
    required this.firstDigitFocus,
    required this.isDark,
    required this.boxHeight,
    required this.onChanged,
  });

  @override
  State<_LetterTextField> createState() => _LetterTextFieldState();
}

class _LetterTextFieldState extends State<_LetterTextField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    // Oscillates left–right 3 times, tapering to zero.
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _triggerShake() => _shakeCtrl.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    final letter = widget.ctrl.text;
    final arabic = letter.isNotEmpty
        ? PlateConverter.letterToArabic(letter)
        : null;

    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BoxShell(
            isDark: widget.isDark,
            hasValue: letter.isNotEmpty,
            height: widget.boxHeight,
            child: TextField(
              controller: widget.ctrl,
              focusNode: widget.focus,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.text,
              autocorrect: false,
              enableSuggestions: false,
              inputFormatters: [
                _SaudiPlateLetterFormatter(onRejected: _triggerShake),
              ],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: widget.isDark ? FColors.light : FColors.dark,
                height: 1,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) {
                widget.onChanged();
                if (v.isNotEmpty) {
                  if (widget.idx < 2) {
                    widget.allLetterFocus[widget.idx + 1].requestFocus();
                  } else {
                    widget.firstDigitFocus.requestFocus();
                  }
                } else {
                  if (widget.idx > 0) {
                    widget.allLetterFocus[widget.idx - 1].requestFocus();
                  }
                }
              },
              onTap: () => widget.ctrl.selection = TextSelection(
                baseOffset: 0,
                extentOffset: widget.ctrl.text.length,
              ),
            ),
          ),
          // Fixed-height slot keeps digit boxes aligned even when no letter yet.
          SizedBox(
            height: 18,
            child: arabic != null
                ? Center(
                    child: Text(
                      arabic,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: FColors.primaryColor,
                        height: 1,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/// Accepts only the 17 valid Saudi plate letters (English or Arabic).
/// Calls [onRejected] for every character that doesn't pass, so the
/// parent widget can trigger haptic / visual feedback.
class _SaudiPlateLetterFormatter extends TextInputFormatter {
  final VoidCallback? onRejected;

  const _SaudiPlateLetterFormatter({this.onRejected});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final char = newValue.text[newValue.text.length - 1];

    // Arabic letter → convert to English equivalent
    final fromArabic = PlateConverter.arabicToEnglishMap[char];
    if (fromArabic != null) {
      return TextEditingValue(
        text: fromArabic,
        selection: const TextSelection.collapsed(offset: 1),
      );
    }

    // English letter → must be one of the 17 valid Saudi plate letters
    final upper = char.toUpperCase();
    if (PlateConverter.validLetters.contains(upper)) {
      return TextEditingValue(
        text: upper,
        selection: const TextSelection.collapsed(offset: 1),
      );
    }

    // Invalid — reject and notify for visual feedback
    onRejected?.call();
    return oldValue;
  }
}

// ── Digit box ─────────────────────────────────────────────────────────────────

class _DigitBox extends StatelessWidget {
  final TextEditingController ctrl;
  final List<FocusNode> focus;
  final int idx;
  final bool isDark;
  final double boxHeight;
  final VoidCallback onChanged;
  final VoidCallback? onBackToLetters;

  const _DigitBox({
    required this.ctrl,
    required this.focus,
    required this.idx,
    required this.isDark,
    required this.boxHeight,
    required this.onChanged,
    this.onBackToLetters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BoxShell(
          isDark: isDark,
          hasValue: ctrl.text.isNotEmpty,
          height: boxHeight,
          child: TextField(
            controller: ctrl,
            focusNode: focus[idx],
            maxLength: 1,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? FColors.light : FColors.dark,
              height: 1,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) {
              onChanged();
              if (v.isNotEmpty && idx < 3) focus[idx + 1].requestFocus();
              if (v.isEmpty && idx > 0) focus[idx - 1].requestFocus();
              if (v.isEmpty && idx == 0) onBackToLetters?.call();
            },
            onTap: () => ctrl.selection = TextSelection(
              baseOffset: 0,
              extentOffset: ctrl.text.length,
            ),
          ),
        ),
        // Spacer matching the letter-box Arabic-translation slot height
        const SizedBox(height: 18),
      ],
    );
  }
}

// ── Shared shell ──────────────────────────────────────────────────────────────

class _BoxShell extends StatelessWidget {
  final bool isDark;
  final bool hasValue;
  final double height;
  final Widget child;

  const _BoxShell({
    required this.isDark,
    required this.hasValue,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? FColors.darkGrey.withValues(alpha: 0.2)
            : FColors.grey.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
        border: Border.all(
          color: hasValue
              ? FColors.primaryColor.withValues(alpha: 0.5)
              : isDark
              ? FColors.grey.withValues(alpha: 0.3)
              : FColors.grey.withValues(alpha: 0.5),
          width: hasValue ? 1.5 : 1.0,
        ),
      ),
      child: child,
    );
  }
}

// ── Divider between letters and digits ───────────────────────────────────────

class _FieldDivider extends StatelessWidget {
  final bool isDark;
  final double height;

  const _FieldDivider({required this.isDark, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 2,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? FColors.grey.withValues(alpha: 0.3)
            : FColors.grey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
