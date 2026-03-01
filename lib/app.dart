import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockwatch/theme/app_theme.dart';
import 'package:stockwatch/screens/home_screen.dart';
import 'package:stockwatch/providers/market_provider.dart';

class StockWatchApp extends ConsumerWidget {
  const StockWatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'StockWatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppShell(),
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyR): const RefreshIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            // TODO: Open search dialog
            return null;
          },
        ),
        RefreshIntent: CallbackAction<RefreshIntent>(
          onInvoke: (intent) {
            ref.refresh(marketDataProvider);
            return null;
          },
        ),
      },
    );
  }
}

class ActivateIntent extends Intent {}
class RefreshIntent extends Intent {}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}