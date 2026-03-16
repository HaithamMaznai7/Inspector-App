import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/plate_converter.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Saudi license-plate input widget.

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
  final _digitCtrl = TextEditingController();
  final _digitFocus = FocusNode();
  final _letterCtrl = TextEditingController();
  final _letterFocus = FocusNode();

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
    _digitCtrl.dispose();
    _digitFocus.dispose();
    _letterCtrl.dispose();
    _letterFocus.dispose();
    super.dispose();
  }

  void _onExternalControllerChanged() {
    if (!_internalChange) setState(_load);
  }

  void _load() {
    final normalized = PlateConverter.normalize(widget.controller.text);
    final parsed = PlateConverter.parse(normalized);
    _digitCtrl.text = parsed.digits;
    _letterCtrl.text = parsed.letters;
  }

  void _save() {
    final letters = _letterCtrl.text;
    final digits = _digitCtrl.text;
    _internalChange = true;
    widget.controller.text = '$letters $digits'.trim();
    _internalChange = false;
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final boxHeight = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 54,
      tablet: 60,
      desktop: 64,
    );
    final fontSize = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 20,
      tablet: 22,
      desktop: 24,
    );
    final arabicFontSize = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 12,
      tablet: 13,
      desktop: 14,
    );
    final gap = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 6,
      tablet: 8,
      desktop: 10,
    );
    final dividerMargin = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 10,
      tablet: 14,
      desktop: 16,
    );
    final maxWidth = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: double.infinity,
      tablet: 400,
      desktop: 440,
    );

    // Saudi plates: numbers first, then letters.
    // Visual order: [1][2][3][4] | [A][B][C]
    final Widget inputRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 4-digit group ──────────────────────────────────────────────────
        Expanded(
          flex: 4,
          child: _PinGroup(
            count: 4,
            ctrl: _digitCtrl,
            focus: _digitFocus,
            isLetterGroup: false,
            isDark: isDark,
            boxHeight: boxHeight,
            fontSize: fontSize,
            arabicFontSize: arabicFontSize,
            gap: gap,
            onChanged: () {
              _save();
              // Auto-advance to letter group when all 4 digits are filled.
              // addPostFrameCallback gives iOS time to commit the current IME
              // session before opening the new one — prevents the jump.
              if (_digitCtrl.text.length == 4) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _letterFocus.requestFocus();
                });
              }
            },
          ),
        ),

        // ── Separator ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: _FieldDivider(
            isDark: isDark,
            height: boxHeight - 4,
            margin: dividerMargin,
          ),
        ),

        // ── 3-letter group ─────────────────────────────────────────────────
        Expanded(
          flex: 3,
          child: _PinGroup(
            count: 3,
            ctrl: _letterCtrl,
            focus: _letterFocus,
            isLetterGroup: true,
            isDark: isDark,
            boxHeight: boxHeight,
            fontSize: fontSize,
            arabicFontSize: arabicFontSize,
            gap: gap,
            onChanged: _save,
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: inputRow,
            ),
          ),
        ),
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

// ── Pin group ─────────────────────────────────────────────────────────────────
//
// Renders [count] visual boxes backed by a single hidden TextField.
// iOS sees ONE IME connection for the entire group, so there is no
// keyboard animation when the user moves from box to box within the group.

class _PinGroup extends StatefulWidget {
  final int count;
  final TextEditingController ctrl;
  final FocusNode focus;
  final bool isLetterGroup;
  final bool isDark;
  final double boxHeight;
  final double fontSize;
  final double arabicFontSize;
  final double gap;
  final VoidCallback onChanged;

  const _PinGroup({
    required this.count,
    required this.ctrl,
    required this.focus,
    required this.isLetterGroup,
    required this.isDark,
    required this.boxHeight,
    required this.fontSize,
    required this.arabicFontSize,
    required this.gap,
    required this.onChanged,
  });

  @override
  State<_PinGroup> createState() => _PinGroupState();
}

class _PinGroupState extends State<_PinGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;
  late final List<TextInputFormatter> _formatters;

  @override
  void initState() {
    super.initState();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear));

    _formatters = [
      if (widget.isLetterGroup)
        _SaudiPlateLetterFormatter(onRejected: _triggerShake)
      else
        _SaudiPlateDigitFormatter(onRejected: _triggerShake),
    ];

    widget.focus.addListener(_onFocusChange);
    widget.ctrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.focus.removeListener(_onFocusChange);
    widget.ctrl.removeListener(_onTextChanged);
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.focus.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.ctrl.selection = TextSelection.collapsed(
            offset: widget.ctrl.text.length,
          );
        }
      });
    }
    if (mounted) setState(() {});
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _triggerShake() => _shakeCtrl.forward(from: 0);

  /// Index of the box that should appear active (next position to be typed).
  int get _activeIndex {
    final len = widget.ctrl.text.length;
    return len < widget.count ? len : widget.count - 1;
  }

  String? _arabicFor(String char) {
    if (char.isEmpty) return null;
    return widget.isLetterGroup
        ? PlateConverter.letterToArabic(char)
        : _arabicDigits[char];
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = widget.focus.hasFocus;
    final text = widget.ctrl.text;

    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (ctx, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: Stack(
        children: [
          // ── Visual boxes (non-interactive — the hidden TextField below
          //    absorbs all pointer events via Positioned.fill) ─────────────
          IgnorePointer(
            child: Row(
              children: [
                for (int i = 0; i < widget.count; i++) ...[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBox(i, text, isFocused),
                        SizedBox(
                          height: widget.arabicFontSize + 6,
                          child: () {
                            final arabic = i < text.length
                                ? _arabicFor(text[i])
                                : null;
                            if (arabic == null || arabic.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Center(
                              child: Text(
                                arabic,
                                style: TextStyle(
                                  fontSize: widget.arabicFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: FColors.primaryColor,
                                  height: 1,
                                ),
                              ),
                            );
                          }(),
                        ),
                      ],
                    ),
                  ),
                  if (i < widget.count - 1) SizedBox(width: widget.gap),
                ],
              ],
            ),
          ),

          // ── Hidden functional TextField ────────────────────────────────
          // Fills the same area as the visual boxes so any tap focuses it.
          // Text color and cursor are transparent — only the boxes are seen.
          Positioned.fill(
            child: TextField(
              controller: widget.ctrl,
              focusNode: widget.focus,
              maxLength: widget.count,
              keyboardType: widget.isLetterGroup
                  ? TextInputType.text
                  : TextInputType.phone,
              textCapitalization: widget.isLetterGroup
                  ? TextCapitalization.characters
                  : TextCapitalization.none,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
              smartDashesType: SmartDashesType.disabled,
              smartQuotesType: SmartQuotesType.disabled,
              showCursor: false,
              inputFormatters: _formatters,
              style: const TextStyle(color: Colors.transparent),
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.transparent,
              ),
              onChanged: (_) => widget.onChanged(),
              onTap: () {
                widget.ctrl.selection = TextSelection.collapsed(
                  offset: widget.ctrl.text.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox(int i, String text, bool isFocused) {
    final char = i < text.length ? text[i] : '';
    final isActive = isFocused && i == _activeIndex;
    final hasValue = char.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: widget.boxHeight,
      decoration: BoxDecoration(
        color: widget.isDark
            ? FColors.darkGrey.withValues(alpha: 0.2)
            : FColors.grey.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
        border: Border.all(
          color: isActive
              ? FColors.primaryColor.withValues(alpha: 0.85)
              : hasValue
              ? FColors.primaryColor.withValues(alpha: 0.5)
              : FColors.darkGrey,

          width: isActive || hasValue ? 1.5 : 1.0,
        ),
      ),
      child: Center(
        child: Text(
          char,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w800,
            color: widget.isDark ? FColors.light : FColors.dark,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ── Letter formatter ──────────────────────────────────────────────────────────
//
// Accepts only the 17 valid Saudi plate letters (English or Arabic-converted).
// Handles multi-character groups: keeps existing valid text and appends newly
// typed valid characters, rejecting invalid ones with a shake callback.

class _SaudiPlateLetterFormatter extends TextInputFormatter {
  final VoidCallback? onRejected;

  const _SaudiPlateLetterFormatter({this.onRejected});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Deletion — always allow unchanged.
    if (newValue.text.length <= oldValue.text.length) return newValue;

    // Characters added — validate each new one.
    final added = newValue.text.substring(oldValue.text.length);
    final result = StringBuffer(oldValue.text);
    bool anyRejected = false;

    for (final char in added.characters) {
      // Arabic letter → convert to English equivalent
      final fromArabic = PlateConverter.arabicToEnglishMap[char];
      if (fromArabic != null) {
        result.write(fromArabic);
        continue;
      }
      // English letter → must be one of the 17 valid Saudi plate letters
      final upper = char.toUpperCase();
      if (PlateConverter.validLetters.contains(upper)) {
        result.write(upper);
      } else {
        anyRejected = true;
      }
    }

    if (anyRejected) onRejected?.call();

    final text = result.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ── Digit formatter ───────────────────────────────────────────────────────────
//
// Accepts English digits 0-9 and Arabic-Indic digits ٠-٩ (converted to English).
// Handles multi-character groups the same way as the letter formatter.

/// Maps English digit characters to their Arabic-Indic equivalents for display.
const _arabicDigits = {
  '0': '٠',
  '1': '١',
  '2': '٢',
  '3': '٣',
  '4': '٤',
  '5': '٥',
  '6': '٦',
  '7': '٧',
  '8': '٨',
  '9': '٩',
};

class _SaudiPlateDigitFormatter extends TextInputFormatter {
  final VoidCallback? onRejected;

  /// Arabic-Indic → English digit mapping (Unicode \u0660–\u0669).
  static const _arabicToEnglish = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  const _SaudiPlateDigitFormatter({this.onRejected});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Deletion — always allow unchanged.
    if (newValue.text.length <= oldValue.text.length) return newValue;

    // Characters added — validate each new one.
    final added = newValue.text.substring(oldValue.text.length);
    final result = StringBuffer(oldValue.text);
    bool anyRejected = false;

    for (final char in added.characters) {
      // Arabic-Indic digit → convert to English
      final fromArabic = _arabicToEnglish[char];
      if (fromArabic != null) {
        result.write(fromArabic);
        continue;
      }
      // English digit — accept as-is
      if (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) {
        result.write(char);
      } else {
        anyRejected = true;
      }
    }

    if (anyRejected) onRejected?.call();

    final text = result.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ── Divider between digit group and letter group ──────────────────────────────

class _FieldDivider extends StatelessWidget {
  final bool isDark;
  final double height;
  final double margin;

  const _FieldDivider({
    required this.isDark,
    required this.height,
    this.margin = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin),
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
