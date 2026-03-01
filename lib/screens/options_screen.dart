import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

class OptionsScreen extends ConsumerWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Options Chain & Flow', style: AppTextStyles.headingLarge),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  'Options screen implementation in progress...',
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
