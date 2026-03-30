/// Structured result of local image quality analysis.
///
/// ALL detected issues ([isDark], [isBright], [isBlurry]) are blocking —
/// the inspector must retake the photo. No "accept anyway" option.
class ImageQualityResult {
  final bool isDark;
  final bool isBright;
  final bool isBlurry;
  final double brightnessScore;
  final double blurScore;

  const ImageQualityResult({
    required this.isDark,
    required this.isBright,
    required this.isBlurry,
    required this.brightnessScore,
    required this.blurScore,
  });

  /// True when any quality issue is detected — photo must be retaken.
  bool get hasIssues => isDark || isBright || isBlurry;

  /// True when the photo passes all checks.
  bool get isClean => !hasIssues;

  /// Localization key for the warning banner.
  String get warningKey {
    if (isDark) return 'cameraQualityTooDark';
    if (isBright) return 'cameraQualityTooBright';
    if (isBlurry) return 'cameraQualityMayBeBlurry';
    return '';
  }

  static const clean = ImageQualityResult(
    isDark: false,
    isBright: false,
    isBlurry: false,
    brightnessScore: 128,
    blurScore: 500,
  );
}
