import 'package:flutter/material.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final double height;

  const AnimatedProgressBar({super.key, required this.value, this.height = 6});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TweenAnimationBuilder<double>(
          duration: AppStyles.slowAnimationDuration,
          curve: Curves.easeInOut,
          tween: Tween<double>(begin: 0, end: value),
          builder: (context, animatedValue, child) {
            return Container(
              height: height,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(height / 2),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: height,
                  width: constraints.maxWidth * animatedValue,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
