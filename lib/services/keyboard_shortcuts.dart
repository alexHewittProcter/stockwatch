import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

// Intent classes for keyboard shortcuts
class GlobalSearchIntent extends Intent {
  const GlobalSearchIntent();
}

class RefreshIntent extends Intent {
  const RefreshIntent();
}

class NewDashboardIntent extends Intent {
  const NewDashboardIntent();
}

class EscapeIntent extends Intent {
  const EscapeIntent();
}

class QuickSymbolIntent extends Intent {
  const QuickSymbolIntent();
}

class KeyboardShortcuts {
  // Define keyboard shortcuts
  static const Map<ShortcutActivator, Intent> shortcuts = {
    // Cmd+K for global search (macOS)
    SingleActivator(LogicalKeyboardKey.keyK, meta: true): GlobalSearchIntent(),
    
    // Cmd+R for refresh
    SingleActivator(LogicalKeyboardKey.keyR, meta: true): RefreshIntent(),
    
    // Cmd+N for new dashboard
    SingleActivator(LogicalKeyboardKey.keyN, meta: true): NewDashboardIntent(),
    
    // Escape to close overlays/search
    SingleActivator(LogicalKeyboardKey.escape): EscapeIntent(),
    
    // Cmd+T for quick symbol lookup
    SingleActivator(LogicalKeyboardKey.keyT, meta: true): QuickSymbolIntent(),
    
    // Cmd+1-9 for quick dashboard switching
    SingleActivator(LogicalKeyboardKey.digit1, meta: true): SwitchDashboardIntent(0),
    SingleActivator(LogicalKeyboardKey.digit2, meta: true): SwitchDashboardIntent(1),
    SingleActivator(LogicalKeyboardKey.digit3, meta: true): SwitchDashboardIntent(2),
    SingleActivator(LogicalKeyboardKey.digit4, meta: true): SwitchDashboardIntent(3),
    SingleActivator(LogicalKeyboardKey.digit5, meta: true): SwitchDashboardIntent(4),
    SingleActivator(LogicalKeyboardKey.digit6, meta: true): SwitchDashboardIntent(5),
    SingleActivator(LogicalKeyboardKey.digit7, meta: true): SwitchDashboardIntent(6),
    SingleActivator(LogicalKeyboardKey.digit8, meta: true): SwitchDashboardIntent(7),
    SingleActivator(LogicalKeyboardKey.digit9, meta: true): SwitchDashboardIntent(8),
  };
  
  // Create actions for the shortcuts
  static Map<Type, Action<Intent>> getActions(WidgetRef ref) {
    return {
      GlobalSearchIntent: GlobalSearchAction(ref),
      RefreshIntent: RefreshAction(ref),
      NewDashboardIntent: NewDashboardAction(ref),
      EscapeIntent: EscapeAction(ref),
      QuickSymbolIntent: QuickSymbolAction(ref),
      SwitchDashboardIntent: SwitchDashboardAction(ref),
    };
  }
}

// Dashboard switching intent with index
class SwitchDashboardIntent extends Intent {
  final int index;
  const SwitchDashboardIntent(this.index);
}

// Action implementations
class GlobalSearchAction extends Action<GlobalSearchIntent> {
  final WidgetRef ref;
  
  GlobalSearchAction(this.ref);
  
  @override
  void invoke(GlobalSearchIntent intent) {
    // Activate search mode
    ref.read(isSearchActiveProvider.notifier).state = true;
    ref.read(searchQueryProvider.notifier).state = '';
  }
}

class RefreshAction extends Action<RefreshIntent> {
  final WidgetRef ref;
  
  RefreshAction(this.ref);
  
  @override
  void invoke(RefreshIntent intent) {
    // Refresh current screen data
    // This would trigger a refresh of the current page's data
    print('Refresh triggered via keyboard shortcut');
    
    // Clear any cached data and force refresh
    // Implementation would depend on the current screen
    _refreshCurrentScreen();
  }
  
  void _refreshCurrentScreen() {
    final currentPage = ref.read(currentPageProvider);
    
    switch (currentPage) {
      case 0: // Home/Overview
        // Refresh market summary, top movers
        break;
      case 1: // Dashboard
        // Refresh dashboard widgets
        break;
      case 2: // Stock Detail
        // Refresh stock data
        break;
      default:
        break;
    }
  }
}

class NewDashboardAction extends Action<NewDashboardIntent> {
  final WidgetRef ref;
  
  NewDashboardAction(this.ref);
  
  @override
  void invoke(NewDashboardIntent intent) {
    // Navigate to dashboard creator or show new dashboard dialog
    print('New dashboard triggered via keyboard shortcut');
    ref.read(dashboardEditModeProvider.notifier).state = true;
  }
}

class EscapeAction extends Action<EscapeIntent> {
  final WidgetRef ref;
  
  EscapeAction(this.ref);
  
  @override
  void invoke(EscapeIntent intent) {
    // Close any open overlays, search, or edit modes
    final isSearchActive = ref.read(isSearchActiveProvider);
    final isDashboardEditMode = ref.read(dashboardEditModeProvider);
    
    if (isSearchActive) {
      ref.read(isSearchActiveProvider.notifier).state = false;
      ref.read(searchQueryProvider.notifier).state = '';
    } else if (isDashboardEditMode) {
      ref.read(dashboardEditModeProvider.notifier).state = false;
    }
  }
}

class QuickSymbolAction extends Action<QuickSymbolIntent> {
  final WidgetRef ref;
  
  QuickSymbolAction(this.ref);
  
  @override
  void invoke(QuickSymbolIntent intent) {
    // Show quick symbol lookup dialog
    print('Quick symbol lookup triggered via keyboard shortcut');
    _showQuickSymbolDialog();
  }
  
  void _showQuickSymbolDialog() {
    // Implementation would show a dialog for quick symbol entry
    // This would be similar to search but focused on stock symbols
  }
}

class SwitchDashboardAction extends Action<SwitchDashboardIntent> {
  final WidgetRef ref;
  
  SwitchDashboardAction(this.ref);
  
  @override
  void invoke(SwitchDashboardIntent intent) {
    // Switch to dashboard at specified index
    print('Switch to dashboard ${intent.index} via keyboard shortcut');
    
    // This would require a list of available dashboards
    // For now, just navigate to dashboard screen
    ref.read(currentPageProvider.notifier).state = 1; // Dashboard page
  }
}

// Utility widget to display keyboard shortcuts in help/settings
class KeyboardShortcutsHelp extends StatelessWidget {
  const KeyboardShortcutsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      KeyboardShortcutInfo(
        keys: 'Cmd + K',
        description: 'Global search',
        icon: Icons.search,
      ),
      KeyboardShortcutInfo(
        keys: 'Cmd + R',
        description: 'Refresh current screen',
        icon: Icons.refresh,
      ),
      KeyboardShortcutInfo(
        keys: 'Cmd + N',
        description: 'Create new dashboard',
        icon: Icons.add_circle_outline,
      ),
      KeyboardShortcutInfo(
        keys: 'Cmd + T',
        description: 'Quick symbol lookup',
        icon: Icons.trending_up,
      ),
      KeyboardShortcutInfo(
        keys: 'Escape',
        description: 'Close overlays/exit edit mode',
        icon: Icons.close,
      ),
      KeyboardShortcutInfo(
        keys: 'Cmd + 1-9',
        description: 'Switch to dashboard',
        icon: Icons.dashboard,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Keyboard Shortcuts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...shortcuts.map((shortcut) => KeyboardShortcutRow(shortcut: shortcut)),
          ],
        ),
      ),
    );
  }
}

class KeyboardShortcutInfo {
  final String keys;
  final String description;
  final IconData icon;

  KeyboardShortcutInfo({
    required this.keys,
    required this.description,
    required this.icon,
  });
}

class KeyboardShortcutRow extends StatelessWidget {
  final KeyboardShortcutInfo shortcut;

  const KeyboardShortcutRow({super.key, required this.shortcut});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(shortcut.icon, size: 20),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortcut.keys,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(shortcut.description),
          ),
        ],
      ),
    );
  }
}