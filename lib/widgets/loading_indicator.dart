import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingIndicator extends StatefulWidget {
  final double? width;
  final double? height;
  final String? message;
  final Color? color;
  final bool showMessage;

  const LoadingIndicator({
    super.key,
    this.width,
    this.height,
    this.message,
    this.color,
    this.showMessage = true,
  });

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late Animation<double> _spinAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _spinAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.linear,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _spinAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _spinAnimation.value * 2.0 * 3.14159,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.color ?? AppColors.info,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.color ?? AppColors.info,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            
            if (widget.showMessage) ...[
              const SizedBox(height: 16),
              Text(
                widget.message ?? 'Loading...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Skeleton loading for cards and lists
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                AppColors.surfaceVariant,
                AppColors.surface,
                AppColors.surfaceVariant,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              begin: Alignment(-1.0 + _animation.value, 0.0),
              end: Alignment(-0.5 + _animation.value, 0.0),
            ),
          ),
        );
      },
    );
  }
}

// Loading placeholder for text
class TextSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final int lines;
  final double spacing;

  const TextSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.lines = 1,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        // Vary the width for more natural look
        final lineWidth = width != null
            ? width! * (index == lines - 1 ? 0.7 : 1.0)
            : null;
            
        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
          child: SkeletonLoader(
            width: lineWidth ?? 150,
            height: height,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        );
      }),
    );
  }
}

// Card skeleton for loading states
class CardSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final bool showHeader;
  final bool showSubtitle;
  final int contentLines;

  const CardSkeleton({
    super.key,
    this.width,
    this.height,
    this.showHeader = true,
    this.showSubtitle = false,
    this.contentLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              SkeletonLoader(
                width: 120,
                height: 20,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
            ],
            
            if (showSubtitle) ...[
              SkeletonLoader(
                width: 80,
                height: 14,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
            ],
            
            Expanded(
              child: Column(
                children: List.generate(contentLines, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < contentLines - 1 ? 8 : 0),
                    child: SkeletonLoader(
                      width: double.infinity,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Loading state for data tables
class TableSkeleton extends StatelessWidget {
  final int rows;
  final int columns;
  final List<double>? columnWidths;

  const TableSkeleton({
    super.key,
    this.rows = 5,
    this.columns = 4,
    this.columnWidths,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariant,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: List.generate(columns, (index) {
              final width = columnWidths?.elementAtOrNull(index) ?? 100.0;
              return Expanded(
                flex: (width / 20).round(),
                child: SkeletonLoader(
                  width: width,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).expand((widget) => [widget, const SizedBox(width: 16)]).take(columns * 2 - 1).toList(),
          ),
        ),
        
        // Data rows
        ...List.generate(rows, (rowIndex) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: List.generate(columns, (colIndex) {
                final width = columnWidths?.elementAtOrNull(colIndex) ?? 100.0;
                return Expanded(
                  flex: (width / 20).round(),
                  child: SkeletonLoader(
                    width: width * 0.8, // Slightly smaller for data cells
                    height: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }).expand((widget) => [widget, const SizedBox(width: 16)]).take(columns * 2 - 1).toList(),
            ),
          );
        }),
      ],
    );
  }
}

// Loading dots indicator
class LoadingDots extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;

  const LoadingDots({
    super.key,
    this.color,
    this.size = 8,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      final controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );
      
      // Stagger the animations
      Future.delayed(Duration(milliseconds: index * 200), () {
        if (mounted) {
          controller.repeat(reverse: true);
        }
      });
      
      return controller;
    });
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size / 4),
              child: Opacity(
                opacity: _animations[index].value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color ?? AppColors.info,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// Progress indicator with percentage
class ProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String? label;
  final Color? color;
  final double height;

  const ProgressIndicator({
    super.key,
    required this.progress,
    this.label,
    this.color,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color ?? AppColors.info,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}