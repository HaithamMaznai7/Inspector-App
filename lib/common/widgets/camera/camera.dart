import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fahis_inspector/common/widgets/camera/image_quality_checker.dart';
import 'package:fahis_inspector/common/widgets/camera/image_quality_result.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String _tag = 'Camera';

class Camera extends StatefulWidget {
  const Camera({super.key, this.cameras});

  final List<CameraDescription>? cameras;

  /// Enumerates cameras and opens the camera dialog.
  /// The camera package handles permission prompts natively on iOS/Android.
  static Future<File?> open() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      FLoader.errorSnackBar(
          message: FTexts.cameraPermissionDenied.tr,
        );
      return null;
    }
    return Get.dialog<File>(Camera(cameras: cameras));
  }

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  late CameraController _controller;
  bool _controllerReady = false;

  // Capture state
  File? _pictureFile;
  bool _isSelfCam = false;
  bool _isTapped = false;
  bool _isCapturing = false;
  FlashMode _flashMode = FlashMode.auto;

  // Processing state (quality + compression run in parallel)
  bool _isProcessing = false;
  ImageQualityResult? _qualityResult;
  File? _compressedFile;

  bool get _isIOS => Theme.of(context).platform == TargetPlatform.iOS;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FDeviceUtils.hideStatusBar();

    if (widget.cameras == null || widget.cameras!.isEmpty) {
      AppLogger.warn(_tag, 'No cameras available, closing');
      WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
      return;
    }

    _initCamera(widget.cameras![0]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controllerReady) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      AppLogger.trace(_tag, 'App backgrounded — disposing camera');
      _controller.dispose();
      _controllerReady = false;
    } else if (state == AppLifecycleState.resumed && _pictureFile == null) {
      AppLogger.trace(_tag, 'App resumed — reinitializing camera');
      _initCamera(widget.cameras![_isSelfCam ? 1 : 0]);
    }
  }

  void _initCamera(CameraDescription description) {
    _controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller.initialize().then((_) {
      if (!mounted) return;
      _controller.setFlashMode(_flashMode);
      _controllerReady = true;
      AppLogger.info(_tag, 'Camera initialized', description.name);
      setState(() {});
    }).catchError((Object e) {
      AppLogger.error(_tag, 'Camera init failed', e);
      final isPermissionDenied = e is CameraException &&
          (e.code == 'CameraAccessDenied' ||
              e.code == 'CameraAccessDeniedWithoutPrompt');
      if (mounted) Get.back<File>();
      if (isPermissionDenied) {
        Future.delayed(
          const Duration(milliseconds: 300),
          () => FLoader.errorSnackBar(
          title: FTexts.cameraPermissionDeniedTitle.tr,
          message: FTexts.cameraPermissionDenied.tr,
        ),
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_controllerReady) _controller.dispose();
    FDeviceUtils.showStatusBar();
    AppLogger.trace(_tag, 'Disposed');
    super.dispose();
  }

  // ── Capture ────────────────────────────────────────────────────────────────

  Future<void> _pick() async {
    if (_isCapturing) return;
    _isCapturing = true;

    try {
      final XFile xfile = await _controller.takePicture();
      final file = File(xfile.path);
      AppLogger.info(_tag, 'Photo captured', file.path);
      setState(() => _pictureFile = file);
      _processImage(file);
    } catch (e) {
      AppLogger.error(_tag, 'takePicture failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FTexts.cameraCaptureFailed.tr),
            backgroundColor: FColors.error,
          ),
        );
      }
    } finally {
      _isCapturing = false;
    }
  }

  // ── Processing (quality check + compression in parallel) ──────────────────

  Future<void> _processImage(File file) async {
    setState(() {
      _isProcessing = true;
      _qualityResult = null;
      _compressedFile = null;
    });

    try {
      // Run quality analysis and compression concurrently
      final results = await Future.wait([
        ImageQualityChecker.analyze(file),
        ImageQualityChecker.compress(file),
      ]);

      final quality = results[0] as ImageQualityResult;
      final compressed = results[1] as File;

      AppLogger.info(_tag, 'Processing complete', {
        'brightness': quality.brightnessScore.toStringAsFixed(1),
        'blur': quality.blurScore.toStringAsFixed(1),
        'isDark': quality.isDark,
        'isBright': quality.isBright,
        'isBlurry': quality.isBlurry,
        'originalKB': (file.lengthSync() / 1024).toStringAsFixed(0),
        'compressedKB': (compressed.lengthSync() / 1024).toStringAsFixed(0),
      });

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _qualityResult = quality;
        _compressedFile = compressed;
      });
    } catch (e) {
      AppLogger.error(_tag, 'Processing failed — allowing confirm', e);
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _qualityResult = ImageQualityResult.clean;
          _compressedFile = file;
        });
      }
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _retake() {
    setState(() {
      _pictureFile = null;
      _qualityResult = null;
      _compressedFile = null;
      _isProcessing = false;
    });
    AppLogger.trace(_tag, 'Retake');
  }

  void _confirmPhoto() {
    AppLogger.info(_tag, 'Photo confirmed', {
      'compressed': _compressedFile != null,
    });
    Get.back(result: _compressedFile ?? _pictureFile);
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

  // ── Confirm button state ──────────────────────────────────────────────────

  bool get _canConfirm {
    if (_isProcessing) return false;
    if (_qualityResult == null) return false;
    if (_qualityResult!.hasIssues) return false;
    return true;
  }

  bool get _hasIssues => _qualityResult?.hasIssues == true;

  // ── Flash icon ─────────────────────────────────────────────────────────────

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

  // ── Responsive helpers ─────────────────────────────────────────────────────

  bool get _isTablet =>
      ResponsiveHelper.isTablet(context) || ResponsiveHelper.isDesktop(context);

  double get _ctrlBtnSize => _isTablet ? 56 : 44;
  double get _shutterSize => _isTablet ? 96 : 78;
  double get _shutterInnerPaddingTapped => _isTablet ? 20 : 16;
  double get _shutterInnerPaddingNormal => _isTablet ? 9 : 7;

  // ── Reusable circle button ─────────────────────────────────────────────────

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

  // ── Shutter button ─────────────────────────────────────────────────────────

  Widget _shutterButton() => GestureDetector(
    onTapDown: (_) => setState(() => _isTapped = true),
    onTapUp: (_) async {
      setState(() => _isTapped = false);
      await _pick();
    },
    onTapCancel: () => setState(() => _isTapped = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: _shutterSize,
      height: _shutterSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: _isTablet ? 4.5 : 3.5),
      ),
      padding: EdgeInsets.all(
        _isTapped ? _shutterInnerPaddingTapped : _shutterInnerPaddingNormal,
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isTapped ? FColors.primaryColor : Colors.white,
        ),
      ),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !_controllerReady && _pictureFile == null
          ? _buildInitializing()
          : _pictureFile == null
              ? _buildViewfinder()
              : _buildPreview(),
    );
  }

  // ── Initializing ──────────────────────────────────────────────────────────

  Widget _buildInitializing() {
    return const Center(
      child: CircularProgressIndicator(color: FColors.primaryColor),
    );
  }

  // ── Viewfinder ─────────────────────────────────────────────────────────────

  Widget _buildViewfinder() {
    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(_controller)),

        // Top gradient with close + flash
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleBtn(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: _isTablet ? 24 : 20,
                      ),
                    ),
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
              ),
            ),
          ),
        ),

        // Bottom gradient with shutter + flip
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
                    SizedBox(width: _ctrlBtnSize),
                    _shutterButton(),
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

  // ── Preview ────────────────────────────────────────────────────────────────

  Widget _buildPreview() {
    return Stack(
      children: [
        // Full-screen photo
        Positioned.fill(
          child: Image.file(
            _pictureFile!,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),

        // Quality warning banner
        if (_hasIssues && !_isProcessing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildWarningBanner(),
          ),

        // Bottom action bar
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
                child: _isProcessing
                    ? _buildProcessingIndicator()
                    : _hasIssues
                        ? _buildRetakeOnlyActions()
                        : _buildPreviewActions(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Warning banner ─────────────────────────────────────────────────────────

  Widget _buildWarningBanner() {
    final bgColor = FColors.error.withValues(alpha: 0.92);
    final message = _qualityResult?.warningKey.tr ?? '';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgColor, bgColor.withValues(alpha: 0.0)],
          stops: const [0.7, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            FSizes.lg,
            _isTablet ? FSizes.md : FSizes.sm,
            FSizes.lg,
            _isTablet ? FSizes.xl : FSizes.lg,
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_rounded,
                color: Colors.white,
                size: _isTablet ? 28 : 24,
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      FTexts.cameraQualityRetakeAdvice.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: _isTablet ? 13 : 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Processing indicator (while quality check + compression run) ─────────

  Widget _buildProcessingIndicator() {
    return Container(
      height: _isTablet ? 60 : 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: _isTablet ? 20 : 18,
            height: _isTablet ? 20 : 18,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: FSizes.sm),
          Text(
            FTexts.cameraCheckingQuality.tr,
            style: TextStyle(
              color: Colors.white70,
              fontSize: _isTablet ? 16 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Retake-only actions (when quality fails) ──────────────────────────────

  Widget _buildRetakeOnlyActions() {
    if (_isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _retake,
        child: Container(
          height: _isTablet ? 60 : 52,
          decoration: BoxDecoration(
            color: FColors.primaryColor,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: FColors.primaryColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: FColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: _isTablet ? 18 : 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          ),
        ),
        onPressed: _retake,
        icon: Icon(Icons.refresh_rounded, size: _isTablet ? 22 : 20),
        label: Text(
          FTexts.cameraRetake.tr,
          style: TextStyle(
            fontSize: _isTablet ? 16 : 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Normal preview actions (retake + confirm) ─────────────────────────────

  Widget _buildPreviewActions() {
    return Row(
      children: [
        Expanded(
          child: _isIOS
              ? _buildIOSRetakeButton()
              : _buildAndroidRetakeButton(),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: _isIOS
              ? _buildIOSConfirmButton()
              : _buildAndroidConfirmButton(),
        ),
      ],
    );
  }

  // ── iOS buttons ────────────────────────────────────────────────────────────

  Widget _buildIOSRetakeButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _retake,
      child: Container(
        height: _isTablet ? 60 : 52,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54, width: 1.5),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSConfirmButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _canConfirm ? _confirmPhoto : null,
      child: Container(
        height: _isTablet ? 60 : 52,
        decoration: BoxDecoration(
          color: FColors.primaryColor,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: FColors.primaryColor.withValues(alpha: 0.4),
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
              _isIOS ? FTexts.cameraUsePhoto.tr : FTexts.cameraOk.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: _isTablet ? 17 : 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Android buttons ────────────────────────────────────────────────────────

  Widget _buildAndroidRetakeButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white54, width: 1.5),
        padding: EdgeInsets.symmetric(vertical: _isTablet ? 18 : 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
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
    );
  }

  Widget _buildAndroidConfirmButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: FColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: _isTablet ? 18 : 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
      ),
      onPressed: _canConfirm ? _confirmPhoto : null,
      icon: Icon(Icons.check_rounded, size: _isTablet ? 22 : 20),
      label: Text(
        FTexts.cameraOk.tr,
        style: TextStyle(
          fontSize: _isTablet ? 16 : 15,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
