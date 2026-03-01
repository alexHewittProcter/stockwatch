import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockwatch/theme/app_theme.dart';
import 'package:stockwatch/screens/dashboard_screen.dart';
import 'package:stockwatch/screens/portfolio_screen.dart';
import 'package:stockwatch/screens/alerts_screen.dart';
import 'package:stockwatch/screens/settings_screen.dart';
import 'package:stockwatch/providers/market_provider.dart';
import 'package:stockwatch/models/dashboard.dart';

enum NavigationItem {
  dashboards,
  watchlists,
  portfolio,
  alerts,
  settings,
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  NavigationItem _selectedItem = NavigationItem.dashboards;
  String? _selectedDashboard;

  @override
  void initState() {
    super.initState();
    _selectedDashboard = DefaultDashboards.all.first.id;
    
    // Initialize with default watchlist symbols
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMarketData();
    });
  }

  Future<void> _initializeMarketData() async {
    final watchlist = ref.read(watchlistProvider);
    await ref.read(marketDataProvider.notifier).addSymbols(watchlist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: AppTheme.secondaryDark,
      child: Column(
        children: [
          _buildSidebarHeader(),
          Expanded(child: _buildNavigationList()),
          _buildMarketStatus(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.bullGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.trending_up,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'StockWatch',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationList() {
    return ListView(
      children: [
        _buildNavigationSection('DASHBOARDS', [
          _buildNavigationItem(
            NavigationItem.dashboards,
            Icons.dashboard_outlined,
            'Dashboards',
          ),
        ]),
        const SizedBox(height: 8),
        if (_selectedItem == NavigationItem.dashboards) ...[
          _buildDashboardList(),
          const SizedBox(height: 16),
        ],
        _buildNavigationSection('TRADING', [
          _buildNavigationItem(
            NavigationItem.watchlists,
            Icons.list_outlined,
            'Watchlists',
          ),
          _buildNavigationItem(
            NavigationItem.portfolio,
            Icons.pie_chart_outline,
            'Portfolio',
          ),
          _buildNavigationItem(
            NavigationItem.alerts,
            Icons.notifications_outlined,
            'Alerts',
          ),
        ]),
        const SizedBox(height: 16),
        _buildNavigationSection('SYSTEM', [
          _buildNavigationItem(
            NavigationItem.settings,
            Icons.settings_outlined,
            'Settings',
          ),
        ]),
      ],
    );
  }

  Widget _buildNavigationSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildNavigationItem(NavigationItem item, IconData icon, String label) {
    final isSelected = _selectedItem == item;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.bullGreen.withOpacity(0.15) : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected 
            ? Border.all(color: AppTheme.bullGreen.withOpacity(0.3))
            : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? AppTheme.bullGreen : AppTheme.textSecondary,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? AppTheme.bullGreen : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedItem = item;
          });
        },
      ),
    );
  }

  Widget _buildDashboardList() {
    return Column(
      children: DefaultDashboards.all.map((dashboard) {
        final isSelected = _selectedDashboard == dashboard.id;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 1),
          child: ListTile(
            dense: true,
            leading: Text(
              dashboard.name.substring(0, 2), // Extract emoji
              style: const TextStyle(fontSize: 16),
            ),
            title: Text(
              dashboard.name.substring(3), // Remove emoji and space
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? AppTheme.bullGreen : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            selected: isSelected,
            selectedTileColor: AppTheme.bullGreen.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            onTap: () {
              setState(() {
                _selectedDashboard = dashboard.id;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMarketStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final marketStatus = ref.watch(marketStatusProvider);
          
          return marketStatus.when(
            data: (status) => Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: status['isOpen'] == true 
                        ? AppTheme.bullGreen 
                        : AppTheme.bearRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market ${status['marketStatus']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatLastUpdated(status['lastUpdated']),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const Row(
              children: [
                SizedBox(
                  width: 8,
                  height: 8,
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
                SizedBox(width: 8),
                Text(
                  'Loading status...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
            error: (_, __) => const Row(
              children: [
                Icon(Icons.error_outline, size: 8, color: AppTheme.bearRed),
                SizedBox(width: 8),
                Text(
                  'Status unavailable',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedItem) {
      case NavigationItem.dashboards:
        final dashboard = DefaultDashboards.all.firstWhere(
          (d) => d.id == _selectedDashboard,
          orElse: () => DefaultDashboards.all.first,
        );
        return DashboardScreen(dashboard: dashboard);
      
      case NavigationItem.watchlists:
        // For now, show the first dashboard as watchlist
        return DashboardScreen(dashboard: DefaultDashboards.all.first);
      
      case NavigationItem.portfolio:
        return const PortfolioScreen();
      
      case NavigationItem.alerts:
        return const AlertsScreen();
      
      case NavigationItem.settings:
        return const SettingsScreen();
    }
  }

  String _formatLastUpdated(DateTime? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}