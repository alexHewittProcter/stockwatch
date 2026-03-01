import 'package:flutter/material.dart';
import 'package:stockwatch/models/stock.dart';
import 'package:stockwatch/theme/app_theme.dart';

class PriceCard extends StatelessWidget {
  final String symbol;
  final String title;
  final List<dynamic> stocks;

  const PriceCard({
    super.key,
    required this.symbol,
    required this.title,
    required this.stocks,
  });

  @override
  Widget build(BuildContext context) {
    final stock = _findStock();
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: stock != null 
            ? _buildStockContent(context, stock)
            : _buildPlaceholderContent(),
      ),
    );
  }

  Stock? _findStock() {
    try {
      return stocks.firstWhere(
        (s) => s is Stock && s.symbol == symbol,
        orElse: () => null,
      ) as Stock?;
    } catch (e) {
      return null;
    }
  }

  Widget _buildStockContent(BuildContext context, Stock stock) {
    final isPositive = stock.change >= 0;
    final changeColor = isPositive ? AppTheme.bullGreen : AppTheme.bearRed;
    final changeIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    stock.symbol,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (stock.isRealTime)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.bullGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const Spacer(),
        Text(
          stock.formattedPrice,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Row(
          children: [
            Icon(
              changeIcon,
              size: 16,
              color: changeColor,
            ),
            const SizedBox(width: 4),
            Text(
              stock.formattedChange,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: changeColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${stock.formattedChangePercent})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: changeColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _formatLastUpdated(stock.lastUpdated),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          symbol,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiary,
          ),
        ),
        const Spacer(),
        const Text(
          '--',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
        const Row(
          children: [
            Icon(
              Icons.more_horiz,
              size: 16,
              color: AppTheme.textTertiary,
            ),
            SizedBox(width: 4),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatLastUpdated(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 10) {
      return 'Live';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
}