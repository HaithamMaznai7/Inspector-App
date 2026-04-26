import 'dart:io';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key, required this.file, this.title});

  final File file;
  final String? title;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfControllerPinch _controller;
  int _pages = 0;
  int _currentPage = 1;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(
      document: PdfDocument.openFile(widget.file.path),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(widget.file.path)]),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[PdfViewer] share failed: $e');
    }
  }

  Future<void> _openExternal() async {
    // Fallback path: hand off to a platform viewer if pdfx rendering fails
    // on this device (rare — corrupt PDFs, unsupported compressions).
    await OpenFilex.open(widget.file.path);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FColors.dark : FColors.light,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? FColors.light : FColors.dark,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.title ?? 'OBD Report',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: Icon(
              Icons.share,
              color: isDark ? FColors.light : FColors.dark,
            ),
            onPressed: _share,
          ),
        ],
      ),
      body: _error != null
          ? _PdfErrorState(error: _error!, onOpenExternal: _openExternal)
          : PdfViewPinch(
              controller: _controller,
              onDocumentLoaded: (doc) {
                if (!mounted) return;
                setState(() => _pages = doc.pagesCount);
              },
              onPageChanged: (page) {
                if (!mounted) return;
                setState(() => _currentPage = page);
              },
              onDocumentError: (err) {
                if (!mounted) return;
                setState(() => _error = err);
              },
              builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                options: const DefaultBuilderOptions(),
                documentLoaderBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                pageLoaderBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, error) =>
                    _PdfErrorState(error: error, onOpenExternal: _openExternal),
              ),
            ),
      bottomNavigationBar: _pages > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.xs,
                ),
                child: Text(
                  '$_currentPage / $_pages',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: FColors.darkGrey),
                ),
              ),
            )
          : null,
    );
  }
}

class _PdfErrorState extends StatelessWidget {
  const _PdfErrorState({required this.error, required this.onOpenExternal});

  final Object error;
  final VoidCallback onOpenExternal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Iconsax.warning_2,
              size: FSizes.xl,
              color: FColors.warning,
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              'Unable to preview this PDF.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: FSizes.sm),
            TextButton.icon(
              onPressed: onOpenExternal,
              icon: const Icon(Iconsax.export_1),
              label: const Text('Open with another app'),
            ),
          ],
        ),
      ),
    );
  }
}
