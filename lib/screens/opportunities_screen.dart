import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';
import '../models/opportunity_models.dart';

class OpportunitiesScreen extends ConsumerStatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  ConsumerState<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends ConsumerState<OpportunitiesScreen>
    with SingleTickerProviderStateMixin {
  List<Opportunity> _opportunities = [];
  bool _isLoading = true;
  String? _error;
  
  // Filters
  String? _directionFilter;
  int? _minConfidence;
  String? _timeframeFilter;
  
  @override
  void initState() {
    super.initState();
    _loadOpportunities();
  }

  Future<void> _loadOpportunities() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiClient = ref.read(apiClientProvider);
      
      final queryParams = <String, String>{
        'limit': '50',
      };
      
      if (_directionFilter != null) {
        queryParams['direction'] = _directionFilter!;
      }
      
      if (_minConfidence != null) {
        queryParams['confidence'] = _minConfidence.toString();
      }
      
      if (_timeframeFilter != null) {
        queryParams['timeframe'] = _timeframeFilter!;
      }
      
      final response = await apiClient.get('/api/opportunities', queryParameters: queryParams);
      
      setState(() {
        _opportunities = (response['opportunities'] as List<dynamic>?)
                ?.map((item) => Opportunity.fromJson(item))
                .toList() ??
            [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOpportunityStatus(Opportunity opportunity, String newStatus) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      
      await apiClient.put('/api/opportunities/${opportunity.id}/status', data: {
        'status': newStatus,
      });
      
      // Refresh the list
      _loadOpportunities();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opportunity marked as $newStatus'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
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
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : RefreshIndicator(
                        onRefresh: _loadOpportunities,
                        child: _buildOpportunitiesList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // Calculate stats
    final activeCount = _opportunities.where((o) => o.isActive).length;
    final triggeredTodayCount = _opportunities.where((o) => 
      o.isTriggered && o.updatedAt != null &&
      o.updatedAt!.isAfter(DateTime.now().subtract(const Duration(days: 1)))
    ).length;
    
    final completedOpportunities = _opportunities.where((o) => o.isWon || o.isLost);
    final winRate = completedOpportunities.isEmpty 
        ? 0.0 
        : (completedOpportunities.where((o) => o.isWon).length / completedOpportunities.length) * 100;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trading Opportunities',
                      style: AppTextStyles.headingLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI-powered multi-signal opportunity detection',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadOpportunities,
                icon: Icon(
                  Icons.refresh,
                  color: AppColors.primary,
                ),
                tooltip: 'Refresh opportunities',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active',
                  activeCount.toString(),
                  Icons.trending_up,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Triggered Today',
                  triggeredTodayCount.toString(),
                  Icons.notifications_active,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Win Rate',
                  '${winRate.toStringAsFixed(0)}%',
                  Icons.emoji_events,
                  AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
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

  Widget _buildFilterBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              'All Directions',
              _directionFilter == null,
              () => _setDirectionFilter(null),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Long',
              _directionFilter == 'long',
              () => _setDirectionFilter('long'),
              color: AppColors.success,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Short',
              _directionFilter == 'short',
              () => _setDirectionFilter('short'),
              color: AppColors.error,
            ),
            const SizedBox(width: 16),
            _buildFilterChip(
              'High Confidence (70%+)',
              _minConfidence == 70,
              () => _setMinConfidence(_minConfidence == 70 ? null : 70),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Day Trades',
              _timeframeFilter == 'day',
              () => _setTimeframeFilter(_timeframeFilter == 'day' ? null : 'day'),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Swing Trades',
              _timeframeFilter == 'swing',
              () => _setTimeframeFilter(_timeframeFilter == 'swing' ? null : 'swing'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, {Color? color}) {
    final chipColor = color ?? AppColors.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? chipColor : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _setDirectionFilter(String? direction) {
    setState(() {
      _directionFilter = direction;
    });
    _loadOpportunities();
  }

  void _setMinConfidence(int? confidence) {
    setState(() {
      _minConfidence = confidence;
    });
    _loadOpportunities();
  }

  void _setTimeframeFilter(String? timeframe) {
    setState(() {
      _timeframeFilter = timeframe;
    });
    _loadOpportunities();
  }

  Widget _buildOpportunitiesList() {
    if (_opportunities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No opportunities found',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or refresh to detect new signals',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _opportunities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final opportunity = _opportunities[index];
        return _buildOpportunityCard(opportunity);
      },
    );
  }

  Widget _buildOpportunityCard(Opportunity opportunity) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    opportunity.symbol,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildDirectionBadge(opportunity),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    opportunity.timeframeDisplay,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${opportunity.confidence}%',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _getConfidenceColor(opportunity.confidence),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              opportunity.title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildConfidenceBar(opportunity.confidence),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: opportunity.signals.take(4).map((signal) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getSignalCategoryColor(signal.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getSignalCategoryColor(signal.category).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    signal.type.replaceAll('_', ' '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _getSignalCategoryColor(signal.category),
                      fontSize: 10,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
        ),
        children: [
          _buildExpandedContent(opportunity),
        ],
      ),
    );
  }

  Widget _buildDirectionBadge(Opportunity opportunity) {
    Color color;
    IconData icon;
    
    if (opportunity.isLong) {
      color = AppColors.success;
      icon = Icons.trending_up;
    } else if (opportunity.isShort) {
      color = AppColors.error;
      icon = Icons.trending_down;
    } else {
      color = AppColors.textMuted;
      icon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            opportunity.direction.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar(int confidence) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: confidence / 100,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getConfidenceColor(confidence),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _getConfidenceLevelText(confidence),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) return AppColors.success;
    if (confidence >= 60) return AppColors.warning;
    if (confidence >= 40) return AppColors.primary;
    return AppColors.error;
  }

  String _getConfidenceLevelText(int confidence) {
    if (confidence >= 80) return 'Very High';
    if (confidence >= 60) return 'High';
    if (confidence >= 40) return 'Medium';
    if (confidence >= 20) return 'Low';
    return 'Very Low';
  }

  Color _getSignalCategoryColor(String category) {
    switch (category) {
      case 'price': return AppColors.primary;
      case 'volume': return AppColors.warning;
      case 'holder': return AppColors.success;
      case 'options': return Colors.purple;
      case 'news': return Colors.orange;
      case 'social': return Colors.blue;
      case 'technical': return Colors.teal;
      default: return AppColors.textMuted;
    }
  }

  Widget _buildExpandedContent(Opportunity opportunity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thesis
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Investment Thesis',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                opportunity.thesis,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Price Targets
        if (opportunity.hasPriceTargets) ...[
          Text(
            'Price Targets',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildPriceTarget('Entry', opportunity.suggestedEntry!, AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPriceTarget('Stop', opportunity.suggestedStop!, AppColors.error),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPriceTarget('Target', opportunity.suggestedTarget!, AppColors.success),
              ),
            ],
          ),
          
          if (opportunity.riskReward != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.balance, size: 16, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    'Risk/Reward: ${opportunity.riskRewardDisplay}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
        ],
        
        // Actions
        Row(
          children: [
            if (opportunity.isActive) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateOpportunityStatus(opportunity, 'triggered'),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Trade'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _generateResearch(opportunity),
                  icon: const Icon(Icons.analytics, size: 16),
                  label: const Text('Research'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _updateOpportunityStatus(opportunity, 'expired'),
                child: const Text('Dismiss'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.textMuted),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(opportunity.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  opportunity.status.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getStatusColor(opportunity.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPriceTarget(String label, double price, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active': return AppColors.primary;
      case 'triggered': return AppColors.warning;
      case 'won': return AppColors.success;
      case 'lost': return AppColors.error;
      case 'expired': return AppColors.textMuted;
      default: return AppColors.textMuted;
    }
  }

  void _generateResearch(Opportunity opportunity) {
    // TODO: Integrate with Norman Agent for research generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating research report for ${opportunity.symbol}...'),
        backgroundColor: AppColors.primary,
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
            'Failed to load opportunities',
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
            onPressed: _loadOpportunities,
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
}