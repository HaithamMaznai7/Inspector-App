import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';

class Skeleton extends StatefulWidget {
  final double? height;
  final double? width;
  final Color color;
  const Skeleton({super.key, this.height, this.width,required this.color});


  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Adjust duration as needed
    );

    // Create color tween animation
    _colorAnimation = ColorTween(
      begin: widget.color.withOpacity(0.02),
      end: widget.color.withOpacity(0.5), // Adjust end color as needed
    ).animate(_controller);

    // Start animation
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          padding: const EdgeInsets.all(FSizes.borderRadiusMd / 2),
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: const BorderRadius.all(Radius.circular(FSizes.borderRadiusMd)),
          ),
        );
      },
    );
  }
}


class CircleSkeleton extends StatelessWidget {
  const CircleSkeleton({super.key, this.size = 24});

  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.04),
        shape: BoxShape.circle,
      ),
    );
  }
}