import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

class TradeJournalScreen extends ConsumerWidget {
  const TradeJournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trade Journal', style: AppTextStyles.headingLarge),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  'Trade journal screen implementation in progress...',
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
