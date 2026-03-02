import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';
import '../models/holder_models.dart';
import 'holder_portfolio_screen.dart';

class HolderTrackingScreen extends ConsumerStatefulWidget {
  const HolderTrackingScreen({super.key});

  @override
  ConsumerState<HolderTrackingScreen> createState() => _HolderTrackingScreenState();
}

class _HolderTrackingScreenState extends ConsumerState<HolderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TrackedHolder> _trackedHolders = [];
  List<HolderChange> _recentChanges = [];
  List<SmartMoneySignal> _smartMoneySignals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiClient = ref.read(apiClientProvider);

      // Load all data concurrently
      final results = await Future.wait([
        apiClient.getTrackedHolders(),
        apiClient.getHolderChanges(limit: 100),
        apiClient.getSmartMoneySignals(),
      ]);

      setState(() {
        _trackedHolders = (results[0] as List<dynamic>)
            .map((item) => TrackedHolder.fromJson(item))
            .toList();

        _recentChanges = ((results[1] as Map<String, dynamic>)['changes'] as List<dynamic>)
            .map((item) => HolderChange.fromJson(item))
            .toList();

        _smartMoneySignals = ((results[2] as Map<String, dynamic>)['signals'] as List<dynamic>)
            .map((item) => SmartMoneySignal.fromJson(item))
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _trackNewHolder() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _AddHolderDialog(),
    );

    if (result != null) {
      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.trackHolder(
          result['name']!,
          cik: result['cik'],
        );
        _loadData(); // Refresh the list
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to track holder: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _untrackHolder(TrackedHolder holder) async {
    if (holder.cik == null) return;

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.untrackHolder(holder.cik!);
      _loadData(); // Refresh the list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to untrack holder: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Holder Tracking',
                  style: AppTextStyles.headingLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Track institutional holders and get alerts on their moves',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _trackNewHolder,
            icon: const Icon(Icons.add),
            label: const Text('Track Holder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicator: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people, size: 18),
                const SizedBox(width: 8),
                Text('Tracked (${_trackedHolders.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timeline, size: 18),
                const SizedBox(width: 8),
                Text('Activity (${_recentChanges.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up, size: 18),
                const SizedBox(width: 8),
                Text('Signals (${_smartMoneySignals.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTrackedHoldersTab(),
        _buildActivityTab(),
        _buildSignalsTab(),
      ],
    );
  }

  Widget _buildTrackedHoldersTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _trackedHolders.isEmpty
          ? _buildEmptyState(
              'No tracked holders',
              'Start tracking institutional holders to see their portfolio moves',
              Icons.people_outline,
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _trackedHolders.length,
              itemBuilder: (context, index) {
                final holder = _trackedHolders[index];
                return _buildHolderCard(holder);
              },
            ),
    );
  }

  Widget _buildHolderCard(TrackedHolder holder) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: holder.cik != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HolderPortfolioScreen(
                      cik: holder.cik!,
                      holderName: holder.name,
                    ),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      holder.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'untrack') {
                        _showUntrackDialog(holder);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'untrack',
                        child: Row(
                          children: [
                            Icon(Icons.remove_circle_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Untrack'),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (holder.cik != null)
                Text(
                  'CIK: ${holder.cik}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${holder.recentChanges ?? 0} changes',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(holder.trackedSince),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _recentChanges.isEmpty
          ? _buildEmptyState(
              'No recent activity',
              'Activity from tracked holders will appear here',
              Icons.timeline,
            )
          : ListView.separated(
              itemCount: _recentChanges.length,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.border,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final change = _recentChanges[index];
                return _buildActivityItem(change);
              },
            ),
    );
  }

  Widget _buildActivityItem(HolderChange change) {
    Color actionColor;
    IconData actionIcon;

    switch (change.action) {
      case 'new':
        actionColor = AppColors.success;
        actionIcon = Icons.add_circle;
        break;
      case 'increased':
        actionColor = AppColors.success;
        actionIcon = Icons.trending_up;
        break;
      case 'decreased':
        actionColor = AppColors.warning;
        actionIcon = Icons.trending_down;
        break;
      case 'exited':
        actionColor = AppColors.error;
        actionIcon = Icons.remove_circle;
        break;
      default:
        actionColor = AppColors.textMuted;
        actionIcon = Icons.timeline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              actionIcon,
              color: actionColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.text,
                    ),
                    children: [
                      TextSpan(
                        text: change.holderName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: ' ${change.action} their ',
                      ),
                      TextSpan(
                        text: change.symbol,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const TextSpan(text: ' position'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatNumber(change.sharesChange.abs())} shares • ${_formatCurrency(change.valueChange.abs())} • ${change.quarter}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(change.createdAt),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _smartMoneySignals.isEmpty
          ? _buildEmptyState(
              'No smart money signals',
              'When multiple tracked holders converge on the same stock, signals will appear here',
              Icons.trending_up,
            )
          : ListView.separated(
              itemCount: _smartMoneySignals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final signal = _smartMoneySignals[index];
                return _buildSignalCard(signal);
              },
            ),
    );
  }

  Widget _buildSignalCard(SmartMoneySignal signal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getConfidenceColor(signal.confidence).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  signal.symbol,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(signal.confidence).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${signal.confidence}% confidence',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getConfidenceColor(signal.confidence),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${signal.holderCount} tracked holders converging',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Total value: ${_formatCurrency(signal.totalValue)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          ...signal.holders.take(3).map((holder) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getActionColor(holder.action),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${holder.name} ${holder.action}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                Text(
                  _formatCurrency(holder.valueChange),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _getActionColor(holder.action),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )),
          if (signal.holders.length > 3) ...[
            const SizedBox(height: 8),
            Text(
              '+${signal.holders.length - 3} more holders',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Detected ${_formatDate(signal.detectedAt)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) return AppColors.success;
    if (confidence >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'increased':
      case 'new':
        return AppColors.success;
      case 'decreased':
        return AppColors.warning;
      case 'exited':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load tracking data',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showUntrackDialog(TrackedHolder holder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Untrack Holder'),
        content: Text('Are you sure you want to stop tracking ${holder.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _untrackHolder(holder);
            },
            child: const Text('Untrack'),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '\$${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '${difference} days ago';
      } else {
        return '${date.month}/${date.day}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}

class _AddHolderDialog extends StatefulWidget {
  @override
  State<_AddHolderDialog> createState() => _AddHolderDialogState();
}

class _AddHolderDialogState extends State<_AddHolderDialog> {
  final _nameController = TextEditingController();
  final _cikController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Track New Holder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Institution Name',
              hintText: 'e.g., Berkshire Hathaway Inc',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cikController,
            decoration: const InputDecoration(
              labelText: 'CIK (Optional)',
              hintText: 'e.g., 0001067983',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              Navigator.pop(context, {
                'name': _nameController.text.trim(),
                if (_cikController.text.trim().isNotEmpty)
                  'cik': _cikController.text.trim(),
              });
            }
          },
          child: const Text('Track'),
        ),
      ],
    );
  }
}