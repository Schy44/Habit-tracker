import 'package:flutter/material.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';

class AnimatedCheckbox extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onTap;
  const AnimatedCheckbox({super.key, required this.isCompleted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
      child: Container(
        // Ensure minimum touch target size
        width: 44, height: 44,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: AppStyles.fastAnimationDuration,
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.success : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isCompleted ? AppColors.success : AppColors.outline, width: 2),
          ),
          child: AnimatedSwitcher(
            duration: AppStyles.fastAnimationDuration,
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 20, key: ValueKey('check')) : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ),
      ),
    );
  }
}
