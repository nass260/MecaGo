// lib/core/widgets/animated_score_circle.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedScoreCircle extends StatefulWidget {
  final int score;
  final double progress;
  final double size;

  const AnimatedScoreCircle({
    super.key,
    required this.score,
    required this.progress,
    this.size = 48,
  });

  @override
  State<AnimatedScoreCircle> createState() => _AnimatedScoreCircleState();
}

class _AnimatedScoreCircleState extends State<AnimatedScoreCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: _animation.value,
                  strokeWidth: 5,
                  backgroundColor: AppColors.border.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.orange,
                  ),
                ),
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.score}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
              ),
              const Text(
                '/100',
                style: TextStyle(
                  fontSize: 7,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}