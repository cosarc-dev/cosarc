import 'package:flutter/material.dart';
import '../theme/cosarc_colors.dart';

class CosarcSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const CosarcSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<CosarcSkeleton> createState() => _CosarcSkeletonState();
}

class _CosarcSkeletonState extends State<CosarcSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Color.lerp(
              CosarcColors.card,
              CosarcColors.border,
              _controller.value,
            ),
          ),
        );
      },
    );
  }
}
