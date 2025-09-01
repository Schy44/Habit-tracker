import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:mytracker/theme/app_typography.dart';

class AnimatedPieChartCard extends StatefulWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  const AnimatedPieChartCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<AnimatedPieChartCard> createState() => _AnimatedPieChartCardState();
}

class _AnimatedPieChartCardState extends State<AnimatedPieChartCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.color.withOpacity(0.7), widget.color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
        boxShadow: [AppStyles.shadows[1]],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(widget.icon, color: Colors.white, size: 28),
            const SizedBox(height: AppStyles.sm),
            Expanded(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Colors.white.withOpacity(0.3),
                              value: 100 - _animation.value,
                              radius: 20,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              color: Colors.white,
                              value: _animation.value,
                              radius: 25,
                              showTitle: false,
                            ),
                          ],
                          startDegreeOffset: -90,
                        ),
                      ),
                      Text(
                        '${_animation.value.toStringAsFixed(0)}%',
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: AppStyles.sm),
            Text(
              widget.title,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
