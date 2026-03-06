import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
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

  bool get _isIOS =>
      Theme.of(context).platform == TargetPlatform.iOS;

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

  // ── adaptive icon helper ────────────────────────────────────────────────────

  Widget _icon(IconData material, IconData cupertino, {double size = 22}) =>
      Icon(
        _isIOS ? cupertino : material,
        color: FColors.white,
        size: size,
      );

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

  // ── pill button for overlays ────────────────────────────────────────────────

  Widget _pillButton({
    required VoidCallback onTap,
    required Widget icon,
    double size = FSizes.iconCircleMd,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Center(child: icon),
        ),
      );

  // ── shutter button ──────────────────────────────────────────────────────────

  Widget _shutterButton() => GestureDetector(
        onTapDown: (_) => setState(() => _isTapped = true),
        onTapUp: (_) async {
          setState(() => _isTapped = false);
          await _pick();
        },
        onTapCancel: () => setState(() => _isTapped = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 76,
          width: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          padding: EdgeInsets.all(_isTapped ? 14 : 6),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
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

  // ── viewfinder ──────────────────────────────────────────────────────────────

  Widget _buildViewfinder() {
    return Column(
      children: [
        // ── top bar ──
        Container(
          color: Colors.black,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: FSizes.sm),
                child: Row(
                  children: [
                    // Cancel / close
                    _isIOS
                        ? CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: FSizes.sm,
                            ),
                            onPressed: () => Get.back(),
                            child: Text(
                              FTexts.cancelBtn.tr,
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        : IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ),
                    const Spacer(),
                    // Flash
                    _isIOS
                        ? CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: FSizes.sm,
                            ),
                            onPressed: _cycleFlash,
                            child: Icon(
                              _flashIcon,
                              color: Colors.white,
                              size: 22,
                            ),
                          )
                        : IconButton(
                            onPressed: _cycleFlash,
                            icon: Icon(
                              _flashIcon,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── live preview ──
        Expanded(child: CameraPreview(_controller)),

        // ── bottom bar ──
        Container(
          color: Colors.black,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 110,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: FSizes.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Gallery
                    _pillButton(
                      onTap: _pickGalleryImage,
                      icon: _icon(
                        Icons.photo_library_outlined,
                        CupertinoIcons.photo,
                      ),
                    ),
                    // Shutter
                    _shutterButton(),
                    // Flip
                    _pillButton(
                      onTap: _changeCamera,
                      icon: _icon(
                        Icons.cameraswitch_outlined,
                        CupertinoIcons.switch_camera,
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

  // ── preview after capture ───────────────────────────────────────────────────

  Widget _buildPreview() {
    return Column(
      children: [
        // ── photo fills all space between bars ──
        Expanded(
          child: Image.file(_pictureFile!, fit: BoxFit.cover, width: double.infinity),
        ),

        // ── bottom action bar ──
        Container(
          color: Colors.black,
          child: SafeArea(
            top: false,
            child: _isIOS ? _buildIOSPreviewBar() : _buildAndroidPreviewBar(),
          ),
        ),
      ],
    );
  }

  // iOS: "Retake" (left) — "Use Photo" (right) — plain text, native feel
  Widget _buildIOSPreviewBar() {
    return SizedBox(
      height: 88,
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton(
              onPressed: () => setState(() => _pictureFile = null),
              child: Text(
                FTexts.cameraRetake.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Container(width: 0.5, height: 44, color: Colors.white24),
          Expanded(
            child: CupertinoButton(
              onPressed: _processPickedImage,
              child: Text(
                FTexts.cameraUsePhoto.tr,
                style: TextStyle(
                  color: FColors.primaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Android: "Retry" (outlined) — "OK" (filled) — Material feel
  Widget _buildAndroidPreviewBar() {
    return SizedBox(
      height: 88,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.lg,
          vertical: FSizes.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                  ),
                ),
                onPressed: () => setState(() => _pictureFile = null),
                child: Text(FTexts.cameraRetry.tr),
              ),
            ),
            const SizedBox(width: FSizes.spaceBtwItems),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                  ),
                ),
                onPressed: _processPickedImage,
                child: Text(FTexts.cameraOk.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
