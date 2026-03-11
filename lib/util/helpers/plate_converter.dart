/// Domain utility for Saudi license plate conversion and validation.
///
/// Saudi plate structure: 3 Arabic letters (RTL) + 4 digits.
/// Each Arabic letter has a fixed English equivalent.
///
/// Ordering rule:
///   Arabic plates are read right-to-left. When displayed as a LTR string
///   in Arabic (e.g., from the API), the letters are stored LTR but rendered
///   RTL.  Converting to English requires reversing the sequence so the
///   result reads correctly left-to-right.
///
///   Example: API returns Arabic plate stored as "س ر ب" (LTR bytes).
///     Step 1 – map each letter:  س→S, ر→R, ب→B  →  [S, R, B]
///     Step 2 – reverse for LTR: [B, R, S]
///     Result:  "BRS 1234"
class PlateConverter {
  PlateConverter._();

  // ── Arabic → English mapping (17 valid Saudi plate letters) ───────────────

  static const Map<String, String> arabicToEnglishMap = {
    'ا': 'A',
    'ب': 'B',
    'ح': 'J',
    'د': 'D',
    'ر': 'R',
    'س': 'S',
    'ص': 'X',
    'ط': 'T',
    'ع': 'E',
    'ق': 'G',
    'ك': 'K',
    'ل': 'L',
    'م': 'Z',
    'ن': 'N',
    'ه': 'H',
    'و': 'U',
    'ي': 'V',
  };

  /// English → Arabic (reverse of the map above, computed once).
  static final Map<String, String> englishToArabicMap = {
    for (final e in arabicToEnglishMap.entries) e.value: e.key,
  };

  /// The 17 valid English letter codes for Saudi plates, in display order.
  static const List<String> validLetters = [
    'A', 'B', 'J', 'D', 'R', 'S', 'X', 'T', 'E', 'G',
    'K', 'L', 'Z', 'N', 'H', 'U', 'V',
  ];

  // ── Single-letter helpers ─────────────────────────────────────────────────

  /// Converts one Arabic plate character to its English equivalent.
  static String? arabicToEnglish(String arabic) =>
      arabicToEnglishMap[arabic];

  /// Converts one English plate letter to its Arabic equivalent.
  static String? englishToArabic(String english) =>
      englishToArabicMap[english.toUpperCase()];

  /// Returns Arabic equivalent for one English letter, falling back to the
  /// letter itself if no mapping exists.
  static String letterToArabic(String english) =>
      englishToArabicMap[english.toUpperCase()] ?? english;

  /// Returns true when [text] contains any Arabic Unicode character.
  static bool containsArabic(String text) =>
      text.contains(RegExp(r'[\u0600-\u06FF]'));

  // ── Normalization ─────────────────────────────────────────────────────────

  /// Normalizes any plate string (Arabic or English, with or without spaces)
  /// into the canonical internal format: "BRS 1234".
  ///
  /// - Arabic input: characters are mapped to English then reversed.
  /// - English input: non-valid letters are removed, order is preserved.
  /// - At most 3 letters and 4 digits are kept.
  /// - Returns an empty string when [raw] is empty.
  static String normalize(String raw) {
    if (raw.trim().isEmpty) return '';

    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final dig = digits.length > 4 ? digits.substring(0, 4) : digits;

    String englishLetters;

    if (containsArabic(raw)) {
      // Extract only the Arabic characters present in our map.
      final arabicChars = raw
          .split('')
          .where((c) => arabicToEnglishMap.containsKey(c))
          .toList();

      // Map each to English, then reverse to correct RTL → LTR ordering.
      final mapped =
          arabicChars.map((c) => arabicToEnglishMap[c]!).toList();
      englishLetters = mapped.reversed.join();
    } else {
      // Already English — keep only the 17 valid Saudi plate letters.
      englishLetters = raw
          .toUpperCase()
          .split('')
          .where(validLetters.contains)
          .join();
    }

    if (englishLetters.length > 3) {
      englishLetters = englishLetters.substring(0, 3);
    }

    if (englishLetters.isEmpty && dig.isEmpty) return '';
    return '$englishLetters $dig'.trim();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  /// Returns true when [plate] matches "BRS 1234" format exactly:
  /// exactly 3 valid Saudi letters + one space + exactly 4 digits.
  static bool isValid(String plate) {
    final t = plate.trim();
    if (!RegExp(r'^[A-Z]{3} \d{4}$').hasMatch(t)) return false;
    return t.substring(0, 3).split('').every(validLetters.contains);
  }

  // ── Display helpers ───────────────────────────────────────────────────────

  /// Returns the Arabic display string for English plate letters.
  ///
  /// English "BRS" → map each to Arabic (B→ب, R→ر, S→س) → reverse
  /// → "س ر ب" (correct Arabic reading order, space-separated).
  ///
  /// We reverse again here because [normalize] already produced LTR English,
  /// and Arabic plates read RTL, so the Arabic letters need to be shown in
  /// the opposite sequence for a faithful plate representation.
  static String toArabicDisplay(String englishLetters) {
    final letters = englishLetters.toUpperCase().split('');
    return letters
        .map((l) => englishToArabicMap[l] ?? l)
        .toList()
        .reversed
        .join(' ');
  }

  // ── Parsing ───────────────────────────────────────────────────────────────

  /// Splits a normalized plate string into its letter and digit components.
  /// Works on partial values too (e.g., "BR 12").
  static ({String letters, String digits}) parse(String plate) {
    final t = plate.trim();
    final letters = t.replaceAll(RegExp(r'[^A-Z]'), '');
    final digits  = t.replaceAll(RegExp(r'[^0-9]'), '');
    return (letters: letters, digits: digits);
  }
}
