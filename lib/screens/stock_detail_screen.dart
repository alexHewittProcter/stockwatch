import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class StockDetailScreen extends ConsumerWidget {
  const StockDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSymbol = ref.watch(selectedSymbolProvider);
    
    if (selectedSymbol == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.trending_up, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'No stock selected',
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for a stock to view details',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stock Detail: $selectedSymbol', style: AppTextStyles.headingLarge),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  'Stock detail implementation in progress...',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}