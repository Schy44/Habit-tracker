import 'package:flutter/material.dart';
import 'package:mytracker/theme/app_styles.dart';

class HabitCardSkeleton extends StatefulWidget {
  const HabitCardSkeleton({super.key});
  @override
  State<HabitCardSkeleton> createState() => _HabitCardSkeletonState();
}

class _HabitCardSkeletonState extends State<HabitCardSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppStyles.slowAnimationDuration)..repeat();
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
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.grey[300]!, Colors.grey[200]!, Colors.grey[300]!],
            stops: const [0.4, 0.5, 0.6],
            transform: _GradientTransform(_controller.value),
          ).createShader(bounds),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppStyles.md, vertical: AppStyles.sm + 2),
        padding: const EdgeInsets.all(AppStyles.md),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium)),
        child: Row(children: [Container(width: 44, height: 44, color: Colors.white), const SizedBox(width: AppStyles.sm), Expanded(child: Container(height: 20, color: Colors.white)), const SizedBox(width: AppStyles.md), Container(width: 40, height: 20, color: Colors.white)]),
      ),
    );
  }
}

class _GradientTransform extends GradientTransform {
  final double percent;
  const _GradientTransform(this.percent);
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) => Matrix4.translationValues(bounds.width * (percent * 2 - 1), 0.0, 0.0);
}
