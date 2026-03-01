import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockwatch/models/dashboard.dart';
import 'package:stockwatch/widgets/price_card.dart';
import 'package:stockwatch/theme/app_theme.dart';
import 'package:stockwatch/providers/market_provider.dart';

class DashboardScreen extends ConsumerWidget {
  final Dashboard dashboard;

  const DashboardScreen({
    super.key,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketData = ref.watch(marketDataProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: marketData.when(
              data: (data) => _buildDashboardGrid(data.stocks),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.bullGreen,
                ),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppTheme.bearRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load market data',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.refresh(marketDataProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Row(
        children: [
          Text(
            dashboard.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
            },
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () {
              // Toggle fullscreen
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Open dashboard settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(List<dynamic> stocks) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
        ),
        itemCount: dashboard.widgets.length,
        itemBuilder: (context, index) {
          final widget = dashboard.widgets[index];
          return _buildWidget(widget, stocks);
        },
      ),
    );
  }

  Widget _buildWidget(DashboardWidget widget, List<dynamic> stocks) {
    switch (widget.type) {
      case DashboardWidgetType.priceCard:
        return PriceCard(
          symbol: widget.symbols.first,
          title: widget.title,
          stocks: stocks,
        );
      
      case DashboardWidgetType.sparkline:
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Sparkline\n${widget.title}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        );
      
      default:
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              widget.title,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        );
    }
  }
}