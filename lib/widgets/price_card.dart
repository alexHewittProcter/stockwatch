import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';
import 'sparkline_chart.dart';

class PriceCard extends ConsumerStatefulWidget {
  final String symbol;
  final double price;
  final double change;
  final double changePercent;
  final bool showSparkline;
  final VoidCallback? onTap;

  const PriceCard({
    super.key,
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    this.showSparkline = false,
    this.onTap,
  });

  @override
  ConsumerState<PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends ConsumerState<PriceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  double _displayedPrice;
  double _displayedChange;
  double _displayedChangePercent;
  
  @override
  void initState() {
    super.initState();
    
    _displayedPrice = widget.price;
    _displayedChange = widget.change;
    _displayedChangePercent = widget.changePercent;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Listen to price stream for real-time updates
    _listenToPriceUpdates();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _listenToPriceUpdates() {
    final apiClient = ref.read(apiClientProvider);
    
    apiClient.priceStream.listen((quote) {
      if (quote.symbol == widget.symbol) {
        _updatePrice(quote.price, quote.change, quote.changePercent);
      }
    });
  }

  void _updatePrice(double newPrice, double newChange, double newChangePercent) {
    if (mounted) {
      setState(() {
        _displayedPrice = newPrice;
        _displayedChange = newChange;
        _displayedChangePercent = newChangePercent;
      });
      
      // Trigger pulse animation for price change
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Card(
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Symbol and menu button
                    Row(
                      children: [
                        Text(
                          widget.symbol,
                          style: AppTextStyles.ticker,
                        ),
                        const Spacer(),
                        if (widget.onTap != null)
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Price
                    Text(
                      '\$${_displayedPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.numberLarge,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Change and change percent
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _displayedChange.changeBackgroundColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _displayedChange >= 0 
                                    ? Icons.arrow_upward 
                                    : Icons.arrow_downward,
                                size: 12,
                                color: _displayedChange.changeColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_displayedChange >= 0 ? '+' : ''}${_displayedChange.toStringAsFixed(2)}',
                                style: AppTextStyles.numberSmall.withChangeColor(_displayedChange),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_displayedChangePercent >= 0 ? '+' : ''}${_displayedChangePercent.toStringAsFixed(2)}%',
                          style: AppTextStyles.numberSmall.withChangeColor(_displayedChangePercent),
                        ),
                      ],
                    ),
                    
                    // Sparkline chart
                    if (widget.showSparkline) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 60,
                        child: SparklineChart(
                          symbol: widget.symbol,
                          color: _displayedChange.changeColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Simplified price card for dashboard widgets
class CompactPriceCard extends ConsumerWidget {
  final String symbol;
  final double price;
  final double changePercent;
  final VoidCallback? onTap;

  const CompactPriceCard({
    super.key,
    required this.symbol,
    required this.price,
    required this.changePercent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                symbol,
                style: AppTextStyles.ticker.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: AppTextStyles.numberMedium.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    changePercent >= 0 
                        ? Icons.arrow_upward 
                        : Icons.arrow_downward,
                    size: 10,
                    color: changePercent.changeColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
                    style: AppTextStyles.numberSmall.copyWith(
                      fontSize: 10,
                      color: changePercent.changeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Animated price ticker for real-time updates
class AnimatedPriceDisplay extends ConsumerStatefulWidget {
  final String symbol;
  final double initialPrice;
  final TextStyle? style;

  const AnimatedPriceDisplay({
    super.key,
    required this.symbol,
    required this.initialPrice,
    this.style,
  });

  @override
  ConsumerState<AnimatedPriceDisplay> createState() => _AnimatedPriceDisplayState();
}

class _AnimatedPriceDisplayState extends ConsumerState<AnimatedPriceDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  
  double _currentPrice;
  Color? _flashColor;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.initialPrice;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(_animationController);
    
    // Listen to price updates
    _listenToPriceUpdates();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _listenToPriceUpdates() {
    final apiClient = ref.read(apiClientProvider);
    
    apiClient.priceStream.listen((quote) {
      if (quote.symbol == widget.symbol) {
        _updatePrice(quote.price);
      }
    });
  }

  void _updatePrice(double newPrice) {
    if (mounted && newPrice != _currentPrice) {
      final isIncrease = newPrice > _currentPrice;
      
      setState(() {
        _currentPrice = newPrice;
        _flashColor = isIncrease ? AppColors.positive : AppColors.negative;
      });
      
      // Animate color flash
      _colorAnimation = ColorTween(
        begin: _flashColor?.withOpacity(0.3),
        end: Colors.transparent,
      ).animate(_animationController);
      
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            '\$${_currentPrice.toStringAsFixed(2)}',
            style: widget.style ?? AppTextStyles.numberMedium,
          ),
        );
      },
    );
  }
}