import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/features/inspection_steps/components/step_selector.dart';
import 'package:fahis_inspector/features/inspection_steps/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InspectionStepsScreen extends StatelessWidget {
  const InspectionStepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionStepsController>(
      init: InspectionStepsBinding().instance,
      autoRemove: true,
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: FColors.primaryGradient,
              ),
            ),
            title: Text(
              DetailsPage.pageTitle.trParams({
                'inspection': controller.inspection.value.slug,
              }),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.apply(color: FColors.white),
            ),
            leading: BackPageButton(color: FColors.white),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(FSizes.lg * 2),
              child: controller.isLoading.value
                  ? const SizedBox()
                  : _CompactStepBar(controller: controller),
            ),
          ),
          body: controller.isLoading.value
              ? Center(
                  child: CircularProgressIndicator(color: FColors.primaryColor),
                )
              : IndexedStack(
                  index: controller.index,
                  children: controller.tabs
                      .map((tab) => tab['screen'] as Widget)
                      .toList(),
                ),
          bottomNavigationBar: StepSelector(),
        );
      },
    );
  }
}

class _CompactStepBar extends StatefulWidget {
  final InspectionStepsController controller;

  const _CompactStepBar({required this.controller});

  @override
  State<_CompactStepBar> createState() => _CompactStepBarState();
}

class _CompactStepBarState extends State<_CompactStepBar> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _pillKeys = [];

  InspectionStepsController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _rebuildKeys();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _rebuildKeys() {
    _pillKeys.clear();
    for (var i = 0; i < controller.tabs.length; i++) {
      _pillKeys.add(GlobalKey());
    }
  }

  void _scrollToActive() {
    if (!_scrollController.hasClients) return;
    final activeIndex = controller.index;
    if (activeIndex < 0 || activeIndex >= _pillKeys.length) return;

    final keyContext = _pillKeys[activeIndex].currentContext;
    if (keyContext == null) return;

    final renderBox = keyContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final scrollableState = Scrollable.maybeOf(keyContext);
    if (scrollableState == null) return;

    final pillOffset = renderBox.localToGlobal(
      Offset.zero,
      ancestor: scrollableState.context.findRenderObject(),
    );
    final pillWidth = renderBox.size.width;
    final viewportWidth = _scrollController.position.viewportDimension;
    final targetScroll = _scrollController.offset +
        pillOffset.dx -
        (viewportWidth / 2) +
        (pillWidth / 2);

    _scrollController.animateTo(
      targetScroll.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = controller.tabs;

    if (_pillKeys.length != tabs.length) {
      _rebuildKeys();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FSizes.sm),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _buildPills(tabs),
        ),
      ),
    );
  }

  List<Widget> _buildPills(List<Map<String, dynamic>> tabs) {
    final widgets = <Widget>[];

    for (var i = 0; i < tabs.length; i++) {
      if (i > 0) {
        // Connector line
        final isCompleted = (i - 1) < controller.highestReachedIndex;
        widgets.add(
          Container(
            width: FSizes.iconXs,
            height: FSizes.xxs,
            margin: const EdgeInsets.symmetric(horizontal: FSizes.xxs),
            color: isCompleted
                ? FColors.white
                : FColors.white.withValues(alpha: 0.3),
          ),
        );
      }

      final tab = tabs[i];
      final isActive = i == controller.index;
      final isCompleted =
          i < controller.index && i <= controller.highestReachedIndex;
      final isReachable = i <= controller.highestReachedIndex;

      widgets.add(
        GestureDetector(
          key: _pillKeys[i],
          onTap: isReachable ? () => controller.goToTab(i) : null,
          child: isActive
              ? _ActivePill(tab: tab)
              : _InactivePill(
                  tab: tab,
                  isCompleted: isCompleted,
                  isReachable: isReachable,
                ),
        ),
      );
    }

    return widgets;
  }
}

class _ActivePill extends StatelessWidget {
  final Map<String, dynamic> tab;
  const _ActivePill({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: FSizes.loadingIndicatorSize,
      padding: const EdgeInsets.symmetric(horizontal: FSizes.iconXs),
      decoration: BoxDecoration(
        color: FColors.white,
        borderRadius: BorderRadius.circular(FSizes.loadingIndicatorSize / 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tab['icon'] as IconData,
            size: FSizes.iconSm,
            color: FColors.primaryColor,
          ),
          const SizedBox(width: FSizes.xs),
          Text(
            tab['label'] as String,
            style: const TextStyle(
              color: FColors.primaryColor,
              fontSize: FSizes.fontSizeXs,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InactivePill extends StatelessWidget {
  final Map<String, dynamic> tab;
  final bool isCompleted;
  final bool isReachable;

  const _InactivePill({
    required this.tab,
    required this.isCompleted,
    required this.isReachable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: FSizes.loadingIndicatorSize,
      height: FSizes.loadingIndicatorSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? FColors.white.withValues(alpha: 0.85)
            : Colors.transparent,
        border: Border.all(
          color: isReachable
              ? FColors.white
              : FColors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: FSizes.iconSm, color: FColors.primaryColor)
            : Icon(
                tab['icon'] as IconData,
                size: FSizes.iconSm,
                color: isReachable
                    ? FColors.white
                    : FColors.white.withValues(alpha: 0.3),
              ),
      ),
    );
  }
}
