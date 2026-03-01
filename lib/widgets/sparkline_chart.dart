import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';

// Provider for sparkline data
final sparklineDataProvider = FutureProvider.family<List<FlSpot>, SparklineParams>((ref, params) async {
  final apiClient = ref.read(apiClientProvider);
  
  try {
    final candles = await apiClient.getCandles(
      params.symbol,
      interval: params.interval,
      from: DateTime.now().subtract(Duration(days: params.days)),
      to: DateTime.now(),
    );
    
    return candles.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.close);
    }).toList();
  } catch (e) {
    // Return empty data on error
    return [];
  }
});

class SparklineParams {
  final String symbol;
  final String interval;
  final int days;
  
  const SparklineParams({
    required this.symbol,
    this.interval = '1h',
    this.days = 1,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SparklineParams &&
        other.symbol == symbol &&
        other.interval == interval &&
        other.days == days;
  }

  @override
  int get hashCode => symbol.hashCode ^ interval.hashCode ^ days.hashCode;
}

class SparklineChart extends ConsumerWidget {
  final String symbol;
  final Color? color;
  final double? width;
  final double? height;
  final bool showArea;
  final String interval;
  final int days;

  const SparklineChart({
    super.key,
    required this.symbol,
    this.color,
    this.width,
    this.height,
    this.showArea = true,
    this.interval = '1h',
    this.days = 1,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = SparklineParams(
      symbol: symbol,
      interval: interval,
      days: days,
    );
    
    final sparklineData = ref.watch(sparklineDataProvider(params));

    return Container(
      width: width,
      height: height,
      child: sparklineData.when(
        loading: () => _LoadingSkeleton(),
        error: (error, stack) => _ErrorDisplay(),
        data: (spots) => spots.isEmpty 
            ? _EmptyDisplay()
            : _SparklineChart(
                spots: spots,
                color: color ?? AppColors.info,
                showArea: showArea,
              ),
      ),
    );
  }
}

class _SparklineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color color;
  final bool showArea;

  const _SparklineChart({
    required this.spots,
    required this.color,
    required this.showArea,
  });

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) return const SizedBox.shrink();

    // Determine if trend is positive or negative
    final firstPrice = spots.first.y;
    final lastPrice = spots.last.y;
    final isPositive = lastPrice >= firstPrice;
    final trendColor = isPositive ? AppColors.positiveText : AppColors.negativeText;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: showArea ? BarAreaData(
              show: true,
              color: trendColor.withOpacity(0.1),
            ) : BarAreaData(show: false),
          ),
        ],
        minX: spots.first.x,
        maxX: spots.last.x,
        minY: spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b),
        maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b),
        lineTouchData: LineTouchData(
          enabled: false, // Disable touch for sparklines
        ),
      ),
    );
  }
}

class _LoadingSkeleton extends StatefulWidget {
  @override
  State<_LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<_LoadingSkeleton>
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
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                AppColors.surfaceVariant,
                AppColors.surfaceVariant.withOpacity(0.5),
                AppColors.surfaceVariant,
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.negative.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          Icons.error_outline,
          size: 16,
          color: AppColors.negative,
        ),
      ),
    );
  }
}

class _EmptyDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          Icons.show_chart,
          size: 16,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

// Mini sparkline for dashboard cards
class MiniSparkline extends ConsumerWidget {
  final String symbol;
  final Color color;
  final double height;

  const MiniSparkline({
    super.key,
    required this.symbol,
    required this.color,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SparklineChart(
      symbol: symbol,
      color: color,
      height: height,
      showArea: false,
      interval: '5m',
      days: 1,
    );
  }
}

// Sparkline with trend indicator
class TrendSparkline extends StatelessWidget {
  final String symbol;
  final double currentPrice;
  final double previousPrice;

  const TrendSparkline({
    super.key,
    required this.symbol,
    required this.currentPrice,
    required this.previousPrice,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = currentPrice >= previousPrice;
    final trendColor = isPositive ? AppColors.positiveText : AppColors.negativeText;

    return Row(
      children: [
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          size: 16,
          color: trendColor,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: SparklineChart(
            symbol: symbol,
            color: trendColor,
            height: 24,
            showArea: true,
          ),
        ),
      ],
    );
  }
}

// Interactive sparkline with hover tooltip
class InteractiveSparkline extends ConsumerStatefulWidget {
  final String symbol;
  final double height;
  final Function(double price, DateTime time)? onHover;

  const InteractiveSparkline({
    super.key,
    required this.symbol,
    this.height = 100,
    this.onHover,
  });

  @override
  ConsumerState<InteractiveSparkline> createState() => _InteractiveSparklineState();
}

class _InteractiveSparklineState extends ConsumerState<InteractiveSparkline> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final params = SparklineParams(
      symbol: widget.symbol,
      interval: '5m',
      days: 1,
    );
    
    final sparklineData = ref.watch(sparklineDataProvider(params));

    return Container(
      height: widget.height,
      child: sparklineData.when(
        loading: () => _LoadingSkeleton(),
        error: (error, stack) => _ErrorDisplay(),
        data: (spots) => spots.isEmpty 
            ? _EmptyDisplay()
            : _InteractiveChart(
                spots: spots,
                onHover: (index, spot) {
                  setState(() {
                    _hoveredIndex = index;
                  });
                  
                  if (widget.onHover != null && spot != null) {
                    final time = DateTime.now().subtract(
                      Duration(minutes: ((spots.length - 1 - spot.x) * 5).toInt()),
                    );
                    widget.onHover!(spot.y, time);
                  }
                },
                hoveredIndex: _hoveredIndex,
              ),
      ),
    );
  }
}

class _InteractiveChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Function(int?, FlSpot?) onHover;
  final int? hoveredIndex;

  const _InteractiveChart({
    required this.spots,
    required this.onHover,
    this.hoveredIndex,
  });

  @override
  Widget build(BuildContext context) {
    final firstPrice = spots.first.y;
    final lastPrice = spots.last.y;
    final isPositive = lastPrice >= firstPrice;
    final trendColor = isPositive ? AppColors.positiveText : AppColors.negativeText;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: trendColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: hoveredIndex != null,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: trendColor,
                  strokeWidth: 2,
                  strokeColor: AppColors.surface,
                );
              },
              checkToShowDot: (spot, barData) {
                return spot.x.toInt() == hoveredIndex;
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: trendColor.withOpacity(0.1),
            ),
          ),
        ],
        minX: spots.first.x,
        maxX: spots.last.x,
        minY: spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b),
        maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchCallback: (event, response) {
            if (response?.lineBarSpots?.isNotEmpty == true) {
              final spot = response!.lineBarSpots!.first;
              onHover(spot.x.toInt(), spot);
            } else {
              onHover(null, null);
            }
          },
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: trendColor.withOpacity(0.5),
                  strokeWidth: 1,
                  dashArray: [3, 3],
                ),
                FlDotData(show: false),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppColors.surface,
            tooltipBorder: BorderSide(color: AppColors.border),
            tooltipRoundedRadius: 6,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '\$${spot.y.toStringAsFixed(2)}',
                  AppTextStyles.bodySmall,
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}