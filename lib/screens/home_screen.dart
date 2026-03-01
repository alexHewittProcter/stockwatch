import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';
import '../widgets/price_card.dart';
import '../widgets/sparkline_chart.dart';
import '../widgets/loading_indicator.dart';

// Providers for home screen data
final marketSummaryProvider = FutureProvider<List<Quote>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  
  // Get quotes for major indices
  final symbols = ['SPY', 'QQQ', 'IWM', 'VTI', 'DIA'];
  final futures = symbols.map((symbol) => apiClient.getQuote(symbol));
  
  return await Future.wait(futures);
});

final topMoversProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  return await apiClient.getTopMovers();
});

final portfolioSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final positions = await apiClient.getPositions();
  
  // Calculate portfolio summary
  double totalValue = 0;
  double totalPnL = 0;
  double totalPnLPercent = 0;
  
  for (final position in positions) {
    final value = (position['quantity'] ?? 0) * (position['currentPrice'] ?? 0);
    final pnl = (position['unrealizedPnL'] ?? 0).toDouble();
    totalValue += value;
    totalPnL += pnl;
  }
  
  if (totalValue > 0) {
    totalPnLPercent = (totalPnL / (totalValue - totalPnL)) * 100;
  }
  
  return {
    'totalValue': totalValue,
    'totalPnL': totalPnL,
    'totalPnLPercent': totalPnLPercent,
    'positions': positions.length,
  };
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh all providers
          ref.invalidate(marketSummaryProvider);
          ref.invalidate(topMoversProvider);
          ref.invalidate(portfolioSummaryProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Market Overview',
                    style: AppTextStyles.headingLarge,
                  ),
                  const Spacer(),
                  Text(
                    _getCurrentTime(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Market Summary
              _MarketSummarySection(),
              
              const SizedBox(height: 32),
              
              // Top Movers and Portfolio side by side
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _TopMoversSection(),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _PortfolioSummarySection(),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Quick Actions
              _QuickActionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final timeFormat = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ET';
    return timeFormat;
  }
}

class _MarketSummarySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketSummary = ref.watch(marketSummaryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Major Indices',
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: 16),
        
        marketSummary.when(
          loading: () => const LoadingIndicator(),
          error: (error, stack) => _ErrorCard(error.toString()),
          data: (quotes) => Wrap(
            spacing: 16,
            runSpacing: 16,
            children: quotes.map((quote) => SizedBox(
              width: 200,
              child: PriceCard(
                symbol: quote.symbol,
                price: quote.price,
                change: quote.change,
                changePercent: quote.changePercent,
                showSparkline: true,
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _TopMoversSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topMovers = ref.watch(topMoversProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Top Movers',
                  style: AppTextStyles.headingMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            topMovers.when(
              loading: () => const LoadingIndicator(height: 200),
              error: (error, stack) => _ErrorMessage(error.toString()),
              data: (movers) => _TopMoversList(movers),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopMoversList extends StatelessWidget {
  final List<dynamic> movers;

  const _TopMoversList(this.movers);

  @override
  Widget build(BuildContext context) {
    if (movers.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Text(
            'No market data available',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return Column(
      children: movers.take(8).map((mover) => _TopMoverItem(mover)).toList(),
    );
  }
}

class _TopMoverItem extends StatelessWidget {
  final dynamic mover;

  const _TopMoverItem(this.mover);

  @override
  Widget build(BuildContext context) {
    final symbol = mover['symbol'] ?? '';
    final price = (mover['price'] ?? 0.0).toDouble();
    final change = (mover['change'] ?? 0.0).toDouble();
    final changePercent = (mover['changePercent'] ?? 0.0).toDouble();
    final volume = (mover['volume'] ?? 0).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Symbol
          Container(
            width: 60,
            child: Text(
              symbol,
              style: AppTextStyles.ticker,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Price
          Container(
            width: 80,
            child: Text(
              '\$${price.toStringAsFixed(2)}',
              style: AppTextStyles.numberMedium,
              textAlign: TextAlign.right,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Change
          Container(
            width: 80,
            child: Text(
              '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}',
              style: AppTextStyles.numberSmall.withChangeColor(change),
              textAlign: TextAlign.right,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Change %
          Container(
            width: 60,
            child: Text(
              '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
              style: AppTextStyles.numberSmall.withChangeColor(changePercent),
              textAlign: TextAlign.right,
            ),
          ),
          
          const Spacer(),
          
          // Volume (abbreviated)
          Text(
            _formatVolume(volume),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _formatVolume(int volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(1)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toString();
  }
}

class _PortfolioSummarySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioSummary = ref.watch(portfolioSummaryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Portfolio Summary',
                  style: AppTextStyles.headingMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            portfolioSummary.when(
              loading: () => const LoadingIndicator(height: 200),
              error: (error, stack) => _ErrorMessage(error.toString()),
              data: (summary) => _PortfolioSummaryContent(summary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioSummaryContent extends StatelessWidget {
  final Map<String, dynamic> summary;

  const _PortfolioSummaryContent(this.summary);

  @override
  Widget build(BuildContext context) {
    final totalValue = summary['totalValue']?.toDouble() ?? 0.0;
    final totalPnL = summary['totalPnL']?.toDouble() ?? 0.0;
    final totalPnLPercent = summary['totalPnLPercent']?.toDouble() ?? 0.0;
    final positions = summary['positions'] ?? 0;

    return Column(
      children: [
        // Total Value
        Row(
          children: [
            Text(
              'Total Value',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '\$${_formatCurrency(totalValue)}',
              style: AppTextStyles.numberLarge,
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // P&L
        Row(
          children: [
            Text(
              'Today\'s P&L',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${_formatCurrency(totalPnL)}',
                  style: AppTextStyles.numberMedium.withChangeColor(totalPnL),
                ),
                Text(
                  '${totalPnLPercent >= 0 ? '+' : ''}${totalPnLPercent.toStringAsFixed(2)}%',
                  style: AppTextStyles.numberSmall.withChangeColor(totalPnLPercent),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Positions count
        Row(
          children: [
            Text(
              'Open Positions',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              positions.toString(),
              style: AppTextStyles.numberMedium,
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to portfolio screen
                },
                child: const Text('View Portfolio'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to trade screen
                },
                child: const Text('New Trade'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(2);
  }
}

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _QuickActionCard(
              icon: Icons.dashboard,
              title: 'View Dashboards',
              subtitle: 'Customize your market view',
              onTap: () {
                // Navigate to dashboard screen
              },
            ),
            _QuickActionCard(
              icon: Icons.article,
              title: 'Latest News',
              subtitle: 'Stay updated with market news',
              onTap: () {
                // Navigate to news screen
              },
            ),
            _QuickActionCard(
              icon: Icons.lightbulb,
              title: 'Opportunities',
              subtitle: 'AI-powered trading insights',
              onTap: () {
                // Navigate to opportunities screen
              },
            ),
            _QuickActionCard(
              icon: Icons.notifications,
              title: 'Set Alerts',
              subtitle: 'Get notified of price changes',
              onTap: () {
                // Navigate to alerts screen
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: AppTextStyles.headingSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;

  const _ErrorCard(this.error);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.negative,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load market data',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String error;

  const _ErrorMessage(this.error);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 32,
              color: AppColors.negative,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load data',
              style: AppTextStyles.bodyMedium,
            ),
            Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}