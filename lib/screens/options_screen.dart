import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';
import '../models/options_models.dart';

class OptionsScreen extends ConsumerStatefulWidget {
  final String symbol;

  const OptionsScreen({super.key, required this.symbol});

  @override
  ConsumerState<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends ConsumerState<OptionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  OptionsChain? _optionsChain;
  IVData? _ivData;
  PutCallRatio? _pcrData;
  List<String> _expirations = [];
  String? _selectedExpiry;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOptionsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOptionsData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiClient = ref.read(apiClientProvider);
      
      // Load all data concurrently
      final results = await Future.wait([
        apiClient.getOptionsExpirations(widget.symbol),
        apiClient.getOptionsChain(widget.symbol),
        apiClient.getIVData(widget.symbol),
        apiClient.getPutCallRatio(widget.symbol),
      ]);

      setState(() {
        final expirationsResult = results[0] as Map<String, dynamic>;
        _expirations = (expirationsResult['expirations'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [];
        
        if (_expirations.isNotEmpty && _selectedExpiry == null) {
          _selectedExpiry = _expirations.first;
        }

        _optionsChain = OptionsChain.fromJson(results[1] as Map<String, dynamic>);
        _ivData = IVData.fromJson(results[2] as Map<String, dynamic>);
        _pcrData = PutCallRatio.fromJson(results[3] as Map<String, dynamic>);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadChainForExpiry(String expiry) async {
    try {
      setState(() => _selectedExpiry = expiry);
      
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.getOptionsChain(widget.symbol, expiry: expiry);
      
      setState(() {
        _optionsChain = OptionsChain.fromJson(response as Map<String, dynamic>);
      });
    } catch (e) {
      print('Error loading chain for expiry: $e');
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.symbol} Options',
            style: AppTextStyles.headingLarge,
          ),
          const SizedBox(height: 8),
          if (_ivData != null) ...[
            Row(
              children: [
                _buildStatChip('IV: ${_ivData!.currentIV.toStringAsFixed(1)}%', _getIVColor(_ivData!.ivRank)),
                const SizedBox(width: 12),
                _buildStatChip('IV Rank: ${_ivData!.ivRank.toStringAsFixed(0)}', _getIVRankColor(_ivData!.ivRank)),
                const SizedBox(width: 12),
                if (_pcrData != null)
                  _buildStatChip('P/C: ${_pcrData!.ratio.toStringAsFixed(2)}', _getPCRColor(_pcrData!.sentiment)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
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
          Tab(text: 'Chain'),
          Tab(text: 'IV Analysis'),
          Tab(text: 'P/C Ratio'),
          Tab(text: 'Flow'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOptionsChainTab(),
        _buildIVAnalysisTab(),
        _buildPCRTab(),
        _buildFlowTab(),
      ],
    );
  }

  Widget _buildOptionsChainTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          if (_expirations.isNotEmpty) _buildExpirationSelector(),
          const SizedBox(height: 16),
          Expanded(child: _buildChainTable()),
        ],
      ),
    );
  }

  Widget _buildExpirationSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            'Expiration:',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _expirations.map((expiry) => 
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => _loadChainForExpiry(expiry),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedExpiry == expiry 
                              ? AppColors.primary 
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          expiry,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _selectedExpiry == expiry 
                                ? Colors.white 
                                : AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChainTable() {
    if (_optionsChain == null || _optionsChain!.chains.isEmpty) {
      return Center(
        child: Text(
          'No options data available',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    final chain = _optionsChain!.chains.isNotEmpty ? _optionsChain!.chains.first : null;
    if (chain == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildChainHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: _buildChainRows(chain),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChainHeader() {
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
          Expanded(flex: 2, child: Text('Calls', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text('Strike', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('Puts', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildChainRows(ChainExpiry chain) {
    final maxRows = chain.calls.length > chain.puts.length ? chain.calls.length : chain.puts.length;
    
    return Column(
      children: List.generate(maxRows, (index) {
        final call = index < chain.calls.length ? chain.calls[index] : null;
        final put = index < chain.puts.length ? chain.puts[index] : null;
        final strike = call?.strike ?? put?.strike ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: index % 2 == 0 ? AppColors.background.withOpacity(0.5) : Colors.transparent,
          ),
          child: Row(
            children: [
              Expanded(flex: 2, child: _buildOptionCell(call, true)),
              Expanded(
                flex: 1, 
                child: Text(
                  strike.toStringAsFixed(0),
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(flex: 2, child: _buildOptionCell(put, false)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOptionCell(OptionContract? option, bool isCall) {
    if (option == null) return const SizedBox();

    final color = isCall ? AppColors.success : AppColors.error;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: option.inTheMoney ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: isCall ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            '\$${option.lastPrice.toStringAsFixed(2)}',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: option.inTheMoney ? color : AppColors.text,
            ),
          ),
          Text(
            'Vol: ${option.volume}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          Text(
            'IV: ${(option.impliedVolatility * 100).toStringAsFixed(1)}%',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildIVAnalysisTab() {
    if (_ivData == null) {
      return Center(child: Text('No IV data available', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted)));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildIVMetrics(),
          const SizedBox(height: 16),
          Expanded(child: _buildIVChart()),
        ],
      ),
    );
  }

  Widget _buildIVMetrics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildMetricCard('Current IV', '${_ivData!.currentIV.toStringAsFixed(1)}%', AppColors.primary)),
              Expanded(child: _buildMetricCard('IV Rank', '${_ivData!.ivRank.toStringAsFixed(0)}', _getIVRankColor(_ivData!.ivRank))),
              Expanded(child: _buildMetricCard('IV Percentile', '${_ivData!.ivPercentile.toStringAsFixed(0)}', AppColors.warning)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricCard('1D Change', '${_ivData!.ivChange1d >= 0 ? '+' : ''}${_ivData!.ivChange1d.toStringAsFixed(1)}%', _ivData!.ivChange1d >= 0 ? AppColors.success : AppColors.error)),
              Expanded(child: _buildMetricCard('1W Change', '${_ivData!.ivChange1w >= 0 ? '+' : ''}${_ivData!.ivChange1w.toStringAsFixed(1)}%', _ivData!.ivChange1w >= 0 ? AppColors.success : AppColors.error)),
              Expanded(child: _buildMetricCard('52W High', '${_ivData!.iv52wHigh.toStringAsFixed(1)}%', AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.bodyLarge.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildIVChart() {
    if (_ivData!.history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text('No historical IV data available', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _ivData!.history.asMap().entries.map((entry) => 
                FlSpot(entry.key.toDouble(), entry.value.iv)
              ).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPCRTab() {
    if (_pcrData == null) {
      return Center(child: Text('No P/C ratio data available', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted)));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildPCRMetrics(),
          const SizedBox(height: 16),
          Expanded(child: _buildPCRChart()),
        ],
      ),
    );
  }

  Widget _buildPCRMetrics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildMetricCard('P/C Ratio', _pcrData!.ratio.toStringAsFixed(2), _getPCRColor(_pcrData!.sentiment))),
          Expanded(child: _buildMetricCard('Put Volume', _formatNumber(_pcrData!.putVolume), AppColors.error)),
          Expanded(child: _buildMetricCard('Call Volume', _formatNumber(_pcrData!.callVolume), AppColors.success)),
          Expanded(child: _buildMetricCard('Sentiment', _pcrData!.sentiment.replaceAll('_', ' ').toUpperCase(), _getPCRColor(_pcrData!.sentiment))),
        ],
      ),
    );
  }

  Widget _buildPCRChart() {
    if (_pcrData!.history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text('No P/C ratio history available', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _pcrData!.history.asMap().entries.map((entry) => 
                FlSpot(entry.key.toDouble(), entry.value.ratio)
              ).toList(),
              isCurved: true,
              color: _getPCRColor(_pcrData!.sentiment),
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowTab() {
    return Center(
      child: Text(
        'Options flow implementation in progress...',
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Failed to load options data', style: AppTextStyles.headingMedium),
          const SizedBox(height: 8),
          Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadOptionsData,
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

  Color _getIVColor(double ivRank) {
    if (ivRank > 80) return AppColors.error;
    if (ivRank > 50) return AppColors.warning;
    return AppColors.success;
  }

  Color _getIVRankColor(double ivRank) {
    if (ivRank > 80) return AppColors.error;
    if (ivRank > 50) return AppColors.warning;
    return AppColors.success;
  }

  Color _getPCRColor(String sentiment) {
    switch (sentiment) {
      case 'extreme_bearish': return AppColors.error;
      case 'bearish': return AppColors.warning;
      case 'extreme_bullish': return AppColors.success;
      case 'bullish': return AppColors.success;
      default: return AppColors.textMuted;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
