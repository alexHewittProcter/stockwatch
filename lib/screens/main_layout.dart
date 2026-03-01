import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../widgets/global_search.dart';

// Import all screens
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'stock_detail_screen.dart';
import 'holders_screen.dart';
import 'holder_tracking_screen.dart';
import 'options_screen.dart';
import 'news_screen.dart';
import 'opportunities_screen.dart';
import 'reports_screen.dart';
import 'portfolio_screen.dart';
import 'trade_journal_screen.dart';
import 'alerts_screen.dart';
import 'settings_screen.dart';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final isSearchActive = ref.watch(isSearchActiveProvider);
    final sidebarCollapsed = ref.watch(sidebarCollapsedProvider);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: sidebarCollapsed ? 60 : 240,
            child: _Sidebar(collapsed: sidebarCollapsed),
          ),
          
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Top bar with search
                _TopBar(),
                
                // Main content
                Expanded(
                  child: Stack(
                    children: [
                      // Current screen
                      _getCurrentScreen(currentPage),
                      
                      // Global search overlay
                      if (isSearchActive)
                        const GlobalSearchOverlay(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCurrentScreen(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const DashboardScreen();
      case 2:
        return const StockDetailScreen();
      case 3:
        return const HoldersScreen();
      case 4:
        return const HolderTrackingScreen();
      case 5:
        return const OptionsScreen();
      case 6:
        return const NewsScreen();
      case 7:
        return const OpportunitiesScreen();
      case 8:
        return const ReportsScreen();
      case 9:
        return const PortfolioScreen();
      case 10:
        return const TradeJournalScreen();
      case 11:
        return const AlertsScreen();
      case 12:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }
}

class _TopBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarCollapsed = ref.watch(sidebarCollapsedProvider);
    final selectedSymbol = ref.watch(selectedSymbolProvider);
    final marketHours = ref.watch(marketHoursProvider);

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Sidebar toggle
          IconButton(
            onPressed: () {
              ref.read(sidebarCollapsedProvider.notifier).state = !sidebarCollapsed;
            },
            icon: Icon(sidebarCollapsed ? Icons.menu : Icons.menu_open),
            tooltip: sidebarCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
          ),
          
          const SizedBox(width: 8),
          
          // Market status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: marketHours ? AppColors.positive : AppColors.negative,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              marketHours ? 'MARKET OPEN' : 'MARKET CLOSED',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Current symbol indicator
          if (selectedSymbol != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    selectedSymbol,
                    style: AppTextStyles.ticker,
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {
                      ref.read(selectedSymbolProvider.notifier).state = null;
                    },
                    icon: const Icon(Icons.close, size: 16),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    padding: EdgeInsets.zero,
                    tooltip: 'Clear symbol',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
          
          // Search button
          IconButton(
            onPressed: () {
              ref.read(isSearchActiveProvider.notifier).state = true;
            },
            icon: const Icon(Icons.search),
            tooltip: 'Global search (⌘K)',
          ),
          
          // Refresh button
          IconButton(
            onPressed: () {
              // Trigger refresh of current screen
              print('Refresh triggered');
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh (⌘R)',
          ),
          
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  final bool collapsed;

  const _Sidebar({required this.collapsed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Logo/Title
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  const Text(
                    'StockWatch',
                    style: AppTextStyles.headingMedium,
                  ),
                ],
              ],
            ),
          ),
          
          // Navigation items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  
                  // Main screens
                  _NavItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    label: 'Home',
                    index: 0,
                    collapsed: collapsed,
                    isSelected: currentPage == 0,
                  ),
                  _NavItem(
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard,
                    label: 'Dashboard',
                    index: 1,
                    collapsed: collapsed,
                    isSelected: currentPage == 1,
                  ),
                  _NavItem(
                    icon: Icons.show_chart_outlined,
                    selectedIcon: Icons.show_chart,
                    label: 'Stock Detail',
                    index: 2,
                    collapsed: collapsed,
                    isSelected: currentPage == 2,
                  ),
                  
                  if (!collapsed) const _SectionDivider(title: 'Analysis'),
                  
                  _NavItem(
                    icon: Icons.groups_outlined,
                    selectedIcon: Icons.groups,
                    label: 'Holders',
                    index: 3,
                    collapsed: collapsed,
                    isSelected: currentPage == 3,
                  ),
                  _NavItem(
                    icon: Icons.track_changes_outlined,
                    selectedIcon: Icons.track_changes,
                    label: 'Holder Tracking',
                    index: 4,
                    collapsed: collapsed,
                    isSelected: currentPage == 4,
                  ),
                  _NavItem(
                    icon: Icons.swap_horiz_outlined,
                    selectedIcon: Icons.swap_horiz,
                    label: 'Options',
                    index: 5,
                    collapsed: collapsed,
                    isSelected: currentPage == 5,
                  ),
                  
                  if (!collapsed) const _SectionDivider(title: 'Information'),
                  
                  _NavItem(
                    icon: Icons.article_outlined,
                    selectedIcon: Icons.article,
                    label: 'News',
                    index: 6,
                    collapsed: collapsed,
                    isSelected: currentPage == 6,
                  ),
                  _NavItem(
                    icon: Icons.lightbulb_outlined,
                    selectedIcon: Icons.lightbulb,
                    label: 'Opportunities',
                    index: 7,
                    collapsed: collapsed,
                    isSelected: currentPage == 7,
                  ),
                  _NavItem(
                    icon: Icons.description_outlined,
                    selectedIcon: Icons.description,
                    label: 'Reports',
                    index: 8,
                    collapsed: collapsed,
                    isSelected: currentPage == 8,
                  ),
                  
                  if (!collapsed) const _SectionDivider(title: 'Trading'),
                  
                  _NavItem(
                    icon: Icons.pie_chart_outlined,
                    selectedIcon: Icons.pie_chart,
                    label: 'Portfolio',
                    index: 9,
                    collapsed: collapsed,
                    isSelected: currentPage == 9,
                  ),
                  _NavItem(
                    icon: Icons.book_outlined,
                    selectedIcon: Icons.book,
                    label: 'Trade Journal',
                    index: 10,
                    collapsed: collapsed,
                    isSelected: currentPage == 10,
                  ),
                  _NavItem(
                    icon: Icons.notifications_outlined,
                    selectedIcon: Icons.notifications,
                    label: 'Alerts',
                    index: 11,
                    collapsed: collapsed,
                    isSelected: currentPage == 11,
                  ),
                ],
              ),
            ),
          ),
          
          // Settings at bottom
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: _NavItem(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              label: 'Settings',
              index: 12,
              collapsed: collapsed,
              isSelected: currentPage == 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends ConsumerWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int index;
  final bool collapsed;
  final bool isSelected;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.index,
    required this.collapsed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected ? AppColors.selectionBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () {
            ref.read(currentPageProvider.notifier).state = index;
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 40,
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 8 : 12,
              vertical: 8,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 20,
                  color: isSelected ? AppColors.info : AppColors.textSecondary,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected ? AppColors.info : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String title;

  const _SectionDivider({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.border,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.border,
            ),
          ),
        ],
      ),
    );
  }
}