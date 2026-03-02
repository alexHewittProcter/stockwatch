import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';
import '../models/holder_models.dart';
import 'holder_portfolio_screen.dart';

class HoldersScreen extends ConsumerStatefulWidget {
  final String symbol;

  const HoldersScreen({super.key, required this.symbol});

  @override
  ConsumerState<HoldersScreen> createState() => _HoldersScreenState();
}

class _HoldersScreenState extends ConsumerState<HoldersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HolderData? _holderData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHolders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHolders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.getHolders(widget.symbol);
      
      setState(() {
        _holderData = HolderData.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
                  '${widget.symbol} Holders',
                  style: AppTextStyles.headingLarge,
                ),
                const SizedBox(height: 8),
                if (_holderData != null) ...[
                  Text(
                    'Institutional: ${_holderData!.institutionalOwnership.toStringAsFixed(1)}% • '
                    'Insider: ${_holderData!.insiderOwnership.toStringAsFixed(1)}%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_holderData?.insiderBuyingSignal == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Insider Buying',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Institutional'),
          Tab(text: 'Insider'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_holderData == null) return const SizedBox();

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildInstitutionalTab(),
        _buildInsiderTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildOwnershipChart(),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(child: _buildTopHolders()),
                const SizedBox(height: 16),
                if (_holderData!.recentInsiderTransactions?.isNotEmpty == true)
                  Expanded(child: _buildRecentTransactions()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnershipChart() {
    final institutional = _holderData!.institutionalOwnership;
    final insider = _holderData!.insiderOwnership;
    final public = 100 - institutional - insider;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Ownership Breakdown',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: institutional,
                    title: '${institutional.toStringAsFixed(1)}%',
                    color: AppColors.primary,
                    titleStyle: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: insider,
                    title: '${insider.toStringAsFixed(1)}%',
                    color: AppColors.warning,
                    titleStyle: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: public,
                    title: '${public.toStringAsFixed(1)}%',
                    color: AppColors.textMuted,
                    titleStyle: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                centerSpaceRadius: 50,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _buildLegendItem('Institutional', AppColors.primary),
        _buildLegendItem('Insider', AppColors.warning),
        _buildLegendItem('Public', AppColors.textMuted),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTopHolders() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Institutional Holders',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _holderData!.topInstitutional.take(5).length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final holder = _holderData!.topInstitutional[index];
                return _buildHolderRow(holder);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolderRow(InstitutionalHolder holder) {
    return InkWell(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holder.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_formatNumber(holder.shares)} shares • ${_formatCurrency(holder.value)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            _buildChangeIndicator(holder.changeFromPrev, holder.changeType),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeIndicator(int change, String changeType) {
    Color color;
    IconData icon;
    
    switch (changeType) {
      case 'increased':
      case 'new':
        color = AppColors.success;
        icon = Icons.trending_up;
        break;
      case 'decreased':
      case 'exited':
        color = AppColors.error;
        icon = Icons.trending_down;
        break;
      default:
        color = AppColors.textMuted;
        icon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            _formatNumber(change.abs()),
            style: AppTextStyles.bodySmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Insider Activity',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _holderData!.recentInsiderTransactions!.take(5).length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final txn = _holderData!.recentInsiderTransactions![index];
                return _buildTransactionRow(txn);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(InsiderTransaction txn) {
    final isPurchase = txn.isPurchase;
    final color = isPurchase ? AppColors.success : AppColors.error;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              isPurchase ? Icons.add : Icons.remove,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.insiderName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${txn.insiderTitle} • ${_formatCurrency(txn.transactionValue)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(txn.transactionDate),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstitutionalTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Institutional Holders',
                style: AppTextStyles.headingMedium,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _holderData!.topInstitutional.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final holder = _holderData!.topInstitutional[index];
                  return _buildDetailedHolderRow(holder);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedHolderRow(InstitutionalHolder holder) {
    return InkWell(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holder.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatNumber(holder.shares)} shares',
                    style: AppTextStyles.bodyMedium,
                  ),
                  Text(
                    _formatCurrency(holder.value),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChangeIndicator(holder.changeFromPrev, holder.changeType),
                const SizedBox(height: 4),
                Text(
                  _formatDate(holder.filingDate),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsiderTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          if (_holderData!.topInsider.isNotEmpty)
            Expanded(
              flex: 1,
              child: _buildInsiderHolders(),
            ),
          if (_holderData!.recentInsiderTransactions?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: _buildInsiderTransactions(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsiderHolders() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insider Holdings',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _holderData!.topInsider.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final holder = _holderData!.topInsider[index];
                return _buildInsiderHolderRow(holder);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsiderHolderRow(InsiderHolder holder) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holder.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  holder.title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatNumber(holder.shares)} shares',
                style: AppTextStyles.bodyMedium,
              ),
              Text(
                _formatCurrency(holder.value),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsiderTransactions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Transactions',
                style: AppTextStyles.headingMedium,
              ),
              const Spacer(),
              if (_holderData!.insiderBuyingSignal == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Buying Signal',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _holderData!.recentInsiderTransactions!.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final txn = _holderData!.recentInsiderTransactions![index];
                return _buildDetailedTransactionRow(txn);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedTransactionRow(InsiderTransaction txn) {
    final isPurchase = txn.isPurchase;
    final color = isPurchase ? AppColors.success : AppColors.error;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPurchase ? Icons.add_circle : Icons.remove_circle,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.insiderName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  txn.insiderTitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatNumber(txn.transactionShares)} shares @ ${_formatCurrency(txn.transactionPrice)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(txn.transactionValue),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatDate(txn.transactionDate),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
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
            'Failed to load holder data',
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
            onPressed: _loadHolders,
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}