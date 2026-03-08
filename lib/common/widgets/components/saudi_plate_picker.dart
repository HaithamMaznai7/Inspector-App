import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kLetters = [
  'A', 'B', 'J', 'D', 'R', 'S', 'X', 'T', 'E', 'G',
  'K', 'L', 'M', 'N', 'H', 'W', 'Y', 'V', 'Z', 'F',
  'Q', 'C', 'I', 'O', 'P', 'U',
];

class SaudiPlatePicker extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onChanged;

  const SaudiPlatePicker({super.key, required this.controller, this.errorText, this.onChanged});

  @override
  State<SaudiPlatePicker> createState() => _SaudiPlatePickerState();
}

class _SaudiPlatePickerState extends State<SaudiPlatePicker> {
  late List<String?> _letters;
  final _digitCtrl = List.generate(4, (_) => TextEditingController());
  final _digitFocus = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _digitCtrl) { c.dispose(); }
    for (final f in _digitFocus) { f.dispose(); }
    super.dispose();
  }

  void _load() {
    final raw = widget.controller.text.replaceAll(' ', '').toUpperCase();
    final letters = raw.replaceAll(RegExp(r'[^A-Z]'), '');
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    _letters = List.generate(3, (i) {
      final v = i < letters.length ? letters[i] : null;
      return (v != null && _kLetters.contains(v)) ? v : null;
    });
    for (int i = 0; i < 4; i++) {
      _digitCtrl[i].text = i < digits.length ? digits[i] : '';
    }
  }

  void _save() {
    final digitsStr = _digitCtrl.map((c) => c.text).join();
    widget.controller.text =
        '${_letters.map((l) => l ?? '').join()} $digitsStr'.trim();
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = ResponsiveHelper.isTablet(context) || ResponsiveHelper.isDesktop(context);
    final boxHeight = isTablet ? 60.0 : 52.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                Expanded(
                  child: _LetterBox(
                    value: _letters[i],
                    isDark: isDark,
                    boxHeight: boxHeight,
                    onChanged: (v) => setState(() {
                      _letters[i] = v;
                      _save();
                    }),
                  ),
                ),
                if (i < 2) const SizedBox(width: 6),
              ],
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 2,
                height: boxHeight - 8,
                decoration: BoxDecoration(
                  color: isDark
                      ? FColors.grey.withValues(alpha: 0.3)
                      : FColors.grey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              for (int i = 0; i < 4; i++) ...[
                Expanded(
                  child: _DigitBox(
                    ctrl: _digitCtrl[i],
                    focus: _digitFocus,
                    idx: i,
                    isDark: isDark,
                    boxHeight: boxHeight,
                    onChanged: () => setState(_save),
                  ),
                ),
                if (i < 3) const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: FSizes.xs),
            child: Text(
              widget.errorText!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: FColors.error),
            ),
          ),
        ],
      ],
    );
  }
}

class _LetterBox extends StatelessWidget {
  final String? value;
  final bool isDark;
  final double boxHeight;
  final ValueChanged<String> onChanged;

  const _LetterBox({
    required this.value,
    required this.isDark,
    required this.boxHeight,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _BoxShell(
      isDark: isDark,
      hasValue: value != null,
      height: boxHeight,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const SizedBox.shrink(),
          dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          hint: const _Placeholder(),
          selectedItemBuilder: (_) => _kLetters
              .map((l) => _CenteredLabel(l, isDark))
              .toList(),
          items: _kLetters
              .map((l) => DropdownMenuItem<String>(
                    value: l,
                    child: Center(
                      child: Text(
                        l,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isDark ? FColors.light : FColors.dark,
                        ),
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  final TextEditingController ctrl;
  final List<FocusNode> focus;
  final int idx;
  final bool isDark;
  final double boxHeight;
  final VoidCallback onChanged;

  const _DigitBox({
    required this.ctrl,
    required this.focus,
    required this.idx,
    required this.isDark,
    required this.boxHeight,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _BoxShell(
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
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (v) {
          onChanged();
          if (v.isNotEmpty && idx < 3) focus[idx + 1].requestFocus();
          if (v.isEmpty && idx > 0) focus[idx - 1].requestFocus();
        },
        onTap: () => ctrl.selection =
            TextSelection(baseOffset: 0, extentOffset: ctrl.text.length),
      ),
    );
  }
}

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

class _CenteredLabel extends StatelessWidget {
  final String text;
  final bool isDark;

  const _CenteredLabel(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: isDark ? FColors.light : FColors.dark,
          height: 1,
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 16,
        height: 2,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
