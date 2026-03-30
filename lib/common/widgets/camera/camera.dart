import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:fahis_inspector/util/helpers/camera_permission.dart';
import 'package:fahis_inspector/util/helpers/image_quality.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';

class Camera extends StatefulWidget {
  const Camera({super.key, this.cameras, this.hint});

  final List<CameraDescription>? cameras;
  final String? hint;

  /// Centralized camera helper: permission → cameras → dialog → compressed file.
  static Future<File?> open({String? hint}) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final granted = await CameraPermissionHelper.requestCamera();
      if (!granted) return null;
    }
    final cameras = await availableCameras();
    if (cameras.isEmpty) return null;
    return Get.dialog<File>(Camera(cameras: cameras, hint: hint));
  }

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> with SingleTickerProviderStateMixin {
  late CameraController _controller;
  File? _pictureFile;
  bool _isSelfCam = false;
  bool _isTapped = false;
  bool _isCapturing = false;
  bool _shutterCooldown = false;
  bool _initFailed = false;
  FlashMode _flashMode = FlashMode.auto;

  // Guidance hint
  double _hintOpacity = 1.0;

  // Preview: quality check + delayed confirm
  ImageQualityResult? _qualityResult;
  bool _qualityChecking = false;
  bool _confirmVisible = false;

  bool get _isIOS => Theme.of(context).platform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    FDeviceUtils.hideStatusBar();
    if (widget.cameras == null || widget.cameras!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
      return;
    }
    _controller = CameraController(
      widget.cameras![0],
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      _controller.setFlashMode(_flashMode);
      setState(() {});
      _startHintFade();
    } catch (e) {
      dd(e);
      if (!mounted) return;
      setState(() => _initFailed = true);
      FLoader.errorSnackBar(
        title: FTexts.cameraInitError.tr,
        message: e.toString(),
      );
    }
  }

  void _startHintFade() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _pictureFile == null) {
        setState(() => _hintOpacity = 0.0);
      }
    });
  }

  Future<void> _pick() async {
    if (_isCapturing || _shutterCooldown) return;
    setState(() => _isCapturing = true);
    try {
      final XFile cameraFile = await _controller.takePicture();
      final file = File(cameraFile.path);
      setState(() {
        _pictureFile = file;
        _isCapturing = false;
        _confirmVisible = false;
        _qualityResult = null;
        _qualityChecking = true;
      });
      _runQualityCheck(file);
      _scheduleConfirmReveal();
    } catch (e) {
      dd(e);
      setState(() => _isCapturing = false);
      FLoader.errorSnackBar(
        title: FTexts.cameraCaptureError.tr,
        message: e.toString(),
      );
    }
  }

  Future<void> _runQualityCheck(File file) async {
    final result = await ImageQualityChecker.check(file);
    if (mounted && _pictureFile != null) {
      setState(() {
        _qualityResult = result;
        _qualityChecking = false;
      });
    }
  }

  void _scheduleConfirmReveal() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _pictureFile != null) {
        setState(() => _confirmVisible = true);
      }
    });
  }

  void _retake() {
    setState(() {
      _pictureFile = null;
      _qualityResult = null;
      _qualityChecking = false;
      _confirmVisible = false;
      _hintOpacity = 1.0;
    });
    _startHintFade();
  }

  Future<void> _processPickedImage() async {
    if (_pictureFile == null) return;
    setState(() => _shutterCooldown = true);
    final compressed = await _compress(_pictureFile!);
    Get.back(result: compressed);
  }

  Future<File> _compress(File file) async {
    try {
      final outPath =
          '${file.parent.path}/compressed_${file.uri.pathSegments.last}';
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        minWidth: 2560,
        minHeight: 2560,
        quality: 85,
      );
      return result != null ? File(result.path) : file;
    } catch (e) {
      dd(e);
      return file;
    }
  }

  void _changeCamera() {
    if ((widget.cameras?.length ?? 0) < 2) return;
    setState(() => _isSelfCam = !_isSelfCam);
    _controller.setDescription(widget.cameras![_isSelfCam ? 1 : 0]);
  }

  void _cycleFlash() {
    final next = switch (_flashMode) {
      FlashMode.auto => FlashMode.always,
      FlashMode.always => FlashMode.off,
      _ => FlashMode.auto,
    };
    setState(() => _flashMode = next);
    _controller.setFlashMode(next);
  }

  @override
  void dispose() {
    _controller.dispose();
    FDeviceUtils.showStatusBar();
    super.dispose();
  }

  // ── Flash icon ──────────────────────────────────────────────────────────────

  IconData get _flashIcon {
    if (_isIOS) {
      return switch (_flashMode) {
        FlashMode.always => CupertinoIcons.bolt_fill,
        FlashMode.off => CupertinoIcons.bolt_slash_fill,
        _ => CupertinoIcons.bolt,
      };
    }
    return switch (_flashMode) {
      FlashMode.always => Icons.flash_on_rounded,
      FlashMode.off => Icons.flash_off_rounded,
      _ => Icons.flash_auto_rounded,
    };
  }

  Color get _flashColor => switch (_flashMode) {
    FlashMode.always => FColors.warning,
    FlashMode.off => Colors.white54,
    _ => Colors.white,
  };

  // ── Responsive helpers ──────────────────────────────────────────────────────

  bool get _isTablet =>
      ResponsiveHelper.isTablet(context) || ResponsiveHelper.isDesktop(context);

  double get _ctrlBtnSize => _isTablet ? 56 : 44;
  double get _shutterSize => _isTablet ? 96 : 78;
  double get _shutterInnerPaddingTapped => _isTablet ? 20 : 16;
  double get _shutterInnerPaddingNormal => _isTablet ? 9 : 7;

  // ── Control circle button ───────────────────────────────────────────────────

  Widget _circleBtn({
    required VoidCallback onTap,
    required Widget child,
    double? size,
    Color bg = const Color(0x7A000000),
  }) {
    final btnSize = size ?? _ctrlBtnSize;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: btnSize,
        height: btnSize,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  // ── Shutter button ──────────────────────────────────────────────────────────

  Widget _shutterButton() {
    final disabled = _isCapturing || _shutterCooldown;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _isTapped = true),
      onTapUp: disabled
          ? null
          : (_) async {
              setState(() => _isTapped = false);
              await _pick();
            },
      onTapCancel: disabled ? null : () => setState(() => _isTapped = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: _shutterSize,
        height: _shutterSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: disabled ? Colors.white38 : Colors.white,
            width: _isTablet ? 4.5 : 3.5,
          ),
        ),
        padding: EdgeInsets.all(
          _isTapped ? _shutterInnerPaddingTapped : _shutterInnerPaddingNormal,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: disabled
                ? Colors.white38
                : _isTapped
                    ? FColors.primaryColor
                    : Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Quality warning banner ──────────────────────────────────────────────────

  String? get _qualityWarningText {
    if (_qualityResult == null || !_qualityResult!.hasWarning) return null;
    if (_qualityResult!.isDark) return FTexts.cameraQualityDark.tr;
    if (_qualityResult!.isBright) return FTexts.cameraQualityBright.tr;
    if (_qualityResult!.mayBeBlurry) return FTexts.cameraQualityBlurry.tr;
    return null;
  }

  // ── build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_initFailed) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: FSizes.md),
              Text(
                FTexts.cameraInitError.tr,
                style: const TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: FSizes.lg),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  FTexts.cameraOk.tr,
                  style: const TextStyle(color: FColors.primaryColor),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: FColors.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: _pictureFile == null ? _buildViewfinder() : _buildPreview(),
    );
  }

  // ── Viewfinder: full-screen preview + gradient overlays ─────────────────────

  Widget _buildViewfinder() {
    final hintText = widget.hint ?? FTexts.cameraGuidance.tr;

    return Stack(
      children: [
        // ── Full screen camera ──
        Positioned.fill(child: CameraPreview(_controller)),

        // ── Top gradient overlay ──
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _isTablet ? FSizes.md : FSizes.sm,
                  vertical: _isTablet ? FSizes.sm : FSizes.xs,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Close
                        _circleBtn(
                          onTap: () => Get.back(),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: _isTablet ? 24 : 20,
                          ),
                        ),

                        // Flash toggle
                        _circleBtn(
                          onTap: _cycleFlash,
                          child: Icon(
                            _flashIcon,
                            color: _flashColor,
                            size: _isTablet ? 24 : 20,
                          ),
                        ),
                      ],
                    ),

                    // ── Guidance hint ──
                    const SizedBox(height: FSizes.sm),
                    AnimatedOpacity(
                      opacity: _hintOpacity,
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.md,
                          vertical: FSizes.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius:
                              BorderRadius.circular(FSizes.borderRadiusMd),
                        ),
                        child: Text(
                          hintText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: _isTablet ? 15 : 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Bottom gradient overlay ──
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.72),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  _isTablet ? 48 : FSizes.xl,
                  _isTablet ? FSizes.xl : FSizes.lg,
                  _isTablet ? 48 : FSizes.xl,
                  _isTablet ? FSizes.xl : FSizes.lg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Placeholder to keep shutter centered
                    SizedBox(width: _ctrlBtnSize),

                    // Shutter
                    _shutterButton(),

                    // Flip camera
                    _circleBtn(
                      onTap: _changeCamera,
                      child: Icon(
                        _isIOS
                            ? CupertinoIcons.switch_camera
                            : Icons.cameraswitch_outlined,
                        color: Colors.white,
                        size: _isTablet ? 26 : 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Preview: full-screen photo + quality warning + action bar ──────────────

  Widget _buildPreview() {
    final warning = _qualityWarningText;
    final hasWarning = warning != null;

    return Stack(
      children: [
        // ── Full screen photo ──
        Positioned.fill(
          child: Image.file(
            _pictureFile!,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),

        // ── Bottom gradient action bar ──
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  _isTablet ? 48 : FSizes.lg,
                  _isTablet ? FSizes.xl : FSizes.xl,
                  _isTablet ? 48 : FSizes.lg,
                  _isTablet ? FSizes.lg : FSizes.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Quality warning banner ──
                    if (hasWarning)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: FSizes.md),
                        padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.md,
                          vertical: FSizes.sm,
                        ),
                        decoration: BoxDecoration(
                          color: FColors.warning.withValues(alpha: 0.9),
                          borderRadius:
                              BorderRadius.circular(FSizes.borderRadiusMd),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.white,
                              size: _isTablet ? 22 : 18,
                            ),
                            const SizedBox(width: FSizes.sm),
                            Expanded(
                              child: Text(
                                warning,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _isTablet ? 14 : 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Quality check loading ──
                    if (_qualityChecking)
                      Padding(
                        padding: const EdgeInsets.only(bottom: FSizes.md),
                        child: SizedBox(
                          height: 2,
                          child: LinearProgressIndicator(
                            color: FColors.primaryColor,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ),

                    // ── Action buttons ──
                    _isIOS
                        ? _buildIOSActions(hasWarning)
                        : _buildAndroidActions(hasWarning),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── iOS preview actions ─────────────────────────────────────────────────────

  Widget _buildIOSActions(bool hasWarning) {
    return Row(
      children: [
        // Retake — emphasized when warning, outlined when normal
        Expanded(
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _retake,
            child: Container(
              height: _isTablet ? 60 : 52,
              decoration: BoxDecoration(
                color: hasWarning ? FColors.primaryColor : Colors.transparent,
                border: hasWarning
                    ? null
                    : Border.all(color: Colors.white54, width: 1.5),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                boxShadow: hasWarning
                    ? [
                        BoxShadow(
                          color: FColors.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.arrow_counterclockwise,
                    color: Colors.white,
                    size: _isTablet ? 20 : 18,
                  ),
                  const SizedBox(width: FSizes.xs),
                  Text(
                    FTexts.cameraRetake.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _isTablet ? 17 : 16,
                      fontWeight: hasWarning ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: FSizes.md),

        // Use photo — dimmed when warning, emphasized when normal
        // Hidden until _confirmVisible
        Expanded(
          child: AnimatedOpacity(
            opacity: _confirmVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: IgnorePointer(
              ignoring: !_confirmVisible,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _processPickedImage,
                child: Container(
                  height: _isTablet ? 60 : 52,
                  decoration: BoxDecoration(
                    color: hasWarning ? Colors.transparent : FColors.primaryColor,
                    border: hasWarning
                        ? Border.all(color: Colors.white54, width: 1.5)
                        : null,
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    boxShadow: hasWarning
                        ? null
                        : [
                            BoxShadow(
                              color:
                                  FColors.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_alt,
                        color: Colors.white,
                        size: _isTablet ? 20 : 18,
                      ),
                      const SizedBox(width: FSizes.xs),
                      Text(
                        FTexts.cameraUsePhoto.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _isTablet ? 17 : 16,
                          fontWeight:
                              hasWarning ? FontWeight.w500 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Android preview actions ─────────────────────────────────────────────────

  Widget _buildAndroidActions(bool hasWarning) {
    return Row(
      children: [
        // Retake — emphasized when warning
        Expanded(
          child: hasWarning
              ? ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        EdgeInsets.symmetric(vertical: _isTablet ? 18 : 14),
                    shadowColor: FColors.primaryColor.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(FSizes.borderRadiusLg),
                    ),
                  ),
                  onPressed: _retake,
                  icon: Icon(Icons.refresh_rounded, size: _isTablet ? 22 : 20),
                  label: Text(
                    FTexts.cameraRetry.tr,
                    style: TextStyle(
                      fontSize: _isTablet ? 16 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54, width: 1.5),
                    padding:
                        EdgeInsets.symmetric(vertical: _isTablet ? 18 : 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(FSizes.borderRadiusLg),
                    ),
                  ),
                  onPressed: _retake,
                  icon: Icon(Icons.refresh_rounded, size: _isTablet ? 22 : 20),
                  label: Text(
                    FTexts.cameraRetry.tr,
                    style: TextStyle(
                      fontSize: _isTablet ? 16 : 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),

        const SizedBox(width: FSizes.md),

        // Confirm — dimmed when warning, hidden until _confirmVisible
        Expanded(
          child: AnimatedOpacity(
            opacity: _confirmVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: IgnorePointer(
              ignoring: !_confirmVisible,
              child: hasWarning
                  ? OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                            color: Colors.white54, width: 1.5),
                        padding: EdgeInsets.symmetric(
                            vertical: _isTablet ? 18 : 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(FSizes.borderRadiusLg),
                        ),
                      ),
                      onPressed: _processPickedImage,
                      icon: Icon(Icons.check_rounded,
                          size: _isTablet ? 22 : 20),
                      label: Text(
                        FTexts.cameraOk.tr,
                        style: TextStyle(
                          fontSize: _isTablet ? 16 : 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                            vertical: _isTablet ? 18 : 14),
                        shadowColor:
                            FColors.primaryColor.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(FSizes.borderRadiusLg),
                        ),
                      ),
                      onPressed: _processPickedImage,
                      icon: Icon(Icons.check_rounded,
                          size: _isTablet ? 22 : 20),
                      label: Text(
                        FTexts.cameraOk.tr,
                        style: TextStyle(
                          fontSize: _isTablet ? 16 : 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
