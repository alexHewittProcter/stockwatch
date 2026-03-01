import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(userPreferencesProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings & Preferences', style: AppTextStyles.headingLarge),
            const SizedBox(height: 24),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('API Configuration', style: AppTextStyles.headingMedium),
                    const SizedBox(height: 16),
                    
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'API Base URL',
                        hintText: 'http://localhost:3002',
                      ),
                      controller: TextEditingController(text: preferences.apiBaseUrl),
                      onChanged: (value) {
                        // Update API URL
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Text('Notifications Enabled', style: AppTextStyles.bodyMedium),
                        const Spacer(),
                        Switch(
                          value: preferences.notificationsEnabled,
                          onChanged: (value) {
                            // Update notifications setting
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: Center(
                child: Text(
                  'Additional settings implementation in progress...',
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
