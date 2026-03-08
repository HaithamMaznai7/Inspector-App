import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Camera extends StatefulWidget {
  const Camera({super.key, this.cameras});

  final List<CameraDescription>? cameras;

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController _controller;
  File? _pictureFile;
  bool _isSelfCam = false;
  bool _isTapped = false;
  FlashMode _flashMode = FlashMode.auto;

  bool get _isIOS => Theme.of(context).platform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    FDeviceUtils.hideStatusBar();
    _controller = CameraController(
      widget.cameras![0],
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller.initialize().then((_) {
      if (!mounted) return;
      _controller.setFlashMode(_flashMode);
      setState(() {});
    });
  }

  Future<void> _pickGalleryImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pictureFile = File(result.files.single.path!));
    }
  }

  Future<void> _pick() async {
    final XFile cameraFile = await _controller.takePicture();
    setState(() => _pictureFile = File(cameraFile.path));
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

  void _processPickedImage() => Get.back(result: _pictureFile);

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

  // ── build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
                child: Row(
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
                    // Gallery
                    _circleBtn(
                      onTap: _pickGalleryImage,
                      child: Icon(
                        _isIOS
                            ? CupertinoIcons.photo
                            : Icons.photo_library_outlined,
                        color: Colors.white,
                        size: _isTablet ? 26 : 22,
                      ),
                    ),

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

  // ── Preview: full-screen photo + gradient action bar ────────────────────────

  Widget _buildPreview() {
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
                child: _isIOS ? _buildIOSActions() : _buildAndroidActions(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── iOS preview actions ─────────────────────────────────────────────────────

  Widget _buildIOSActions() {
    return Row(
      children: [
        // Retake — outlined, white
        Expanded(
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => setState(() => _pictureFile = null),
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
          ),
        ),

        const SizedBox(width: FSizes.md),

        // Use photo — filled, orange
        Expanded(
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _processPickedImage,
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
                    FTexts.cameraUsePhoto.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _isTablet ? 17 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Android preview actions ─────────────────────────────────────────────────

  Widget _buildAndroidActions() {
    return Row(
      children: [
        // Retake — outlined, white
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54, width: 1.5),
              padding: EdgeInsets.symmetric(vertical: _isTablet ? 18 : 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
            ),
            onPressed: () => setState(() => _pictureFile = null),
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

        // Confirm — filled, orange with glow
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: FColors.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: _isTablet ? 18 : 14),
              shadowColor: FColors.primaryColor.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
            ),
            onPressed: _processPickedImage,
            icon: Icon(Icons.check_rounded, size: _isTablet ? 22 : 20),
            label: Text(
              FTexts.cameraOk.tr,
              style: TextStyle(
                fontSize: _isTablet ? 16 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
