import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';
import '../models/holder_models.dart';

class HolderPortfolioScreen extends ConsumerStatefulWidget {
  final String cik;
  final String holderName;

  const HolderPortfolioScreen({
    super.key,
    required this.cik,
    required this.holderName,
  });

  @override
  ConsumerState<HolderPortfolioScreen> createState() =>
      _HolderPortfolioScreenState();
}

class _HolderPortfolioScreenState extends ConsumerState<HolderPortfolioScreen> {
  InstitutionPortfolio? _portfolio;
  bool _isLoading = true;
  String? _error;
  String _sortBy = 'value'; // value, symbol, change
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.getInstitutionPortfolio(widget.cik);

      setState(() {
        _portfolio = InstitutionPortfolio.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Holding> get _sortedHoldings {
    if (_portfolio == null) return [];

    final holdings = List<Holding>.from(_portfolio!.holdings);

    holdings.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'value':
          comparison = a.value.compareTo(b.value);
          break;
        case 'symbol':
          comparison = a.symbol.compareTo(b.symbol);
          break;
        case 'change':
          comparison = a.changeFromPrev.compareTo(b.changeFromPrev);
          break;
        case 'portfolio':
          comparison = a.pctOfPortfolio.compareTo(b.pctOfPortfolio);
          break;
      }

      return _sortDescending ? -comparison : comparison;
    });

    return holdings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: Text(
          widget.holderName,
          style: AppTextStyles.headingMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_portfolio == null) return const SizedBox();

    return Column(
      children: [
        _buildHeader(),
        _buildQuarterOverQuarterSummary(),
        _buildSortingControls(),
        Expanded(
          child: _buildHoldingsTable(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Value',
                  _formatCurrency(_portfolio!.totalValue),
                  Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Position Count',
                  _portfolio!.positionCount.toString(),
                  Icons.format_list_numbered,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Filing Date',
                  _formatDate(_portfolio!.filingDate),
                  Icons.date_range,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuarterOverQuarterSummary() {
    final qoq = _portfolio!.quarterOverQuarter;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quarter-over-Quarter Changes',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQoQItem(
                  'New Positions',
                  qoq.newPositions,
                  AppColors.success,
                  Icons.add_circle_outline,
                ),
              ),
              Expanded(
                child: _buildQoQItem(
                  'Increased',
                  qoq.increasedPositions,
                  AppColors.success,
                  Icons.trending_up,
                ),
              ),
              Expanded(
                child: _buildQoQItem(
                  'Decreased',
                  qoq.decreasedPositions,
                  AppColors.warning,
                  Icons.trending_down,
                ),
              ),
              Expanded(
                child: _buildQoQItem(
                  'Exited',
                  qoq.exitedPositions,
                  AppColors.error,
                  Icons.remove_circle_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQoQItem(String title, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: AppTextStyles.headingMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSortingControls() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          _buildSortButton('Value', 'value'),
          _buildSortButton('Symbol', 'symbol'),
          _buildSortButton('Change', 'change'),
          _buildSortButton('% Portfolio', 'portfolio'),
          const Spacer(),
          IconButton(
            onPressed: () {
              setState(() {
                _sortDescending = !_sortDescending;
              });
            },
            icon: Icon(
              _sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(String label, String value) {
    final isSelected = _sortBy == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            if (_sortBy == value) {
              _sortDescending = !_sortDescending;
            } else {
              _sortBy = value;
              _sortDescending = true;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHoldingsTable() {
    final holdings = _sortedHoldings;

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView.separated(
              itemCount: holdings.length,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.border,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final holding = holdings[index];
                return _buildHoldingRow(holding);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Symbol',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Company',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Shares',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Value',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '% Portfolio',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Change',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingRow(Holding holding) {
    return InkWell(
      onTap: () {
        // Navigate to stock detail screen
        // Navigator.pushNamed(context, '/stock/${holding.symbol}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                holding.symbol,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                holding.name,
                style: AppTextStyles.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _formatNumber(holding.shares),
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _formatCurrency(holding.value),
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${holding.pctOfPortfolio.toStringAsFixed(1)}%',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildChangeIndicator(holding.changeFromPrev, holding.changeType),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeIndicator(int change, String changeType) {
    Color color;
    IconData icon;
    String text;

    switch (changeType) {
      case 'increased':
        color = AppColors.success;
        icon = Icons.trending_up;
        text = '+${_formatNumber(change.abs())}';
        break;
      case 'decreased':
        color = AppColors.warning;
        icon = Icons.trending_down;
        text = '-${_formatNumber(change.abs())}';
        break;
      case 'new':
        color = AppColors.success;
        icon = Icons.add_circle_outline;
        text = 'NEW';
        break;
      case 'exited':
        color = AppColors.error;
        icon = Icons.remove_circle_outline;
        text = 'EXIT';
        break;
      default:
        color = AppColors.textMuted;
        icon = Icons.trending_flat;
        text = 'UNCHANGED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
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
            'Failed to load portfolio',
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
            onPressed: _loadPortfolio,
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
    if (amount >= 1000000000) {
      return '\$${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}