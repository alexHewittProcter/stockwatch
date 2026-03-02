import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';
import '../models/opportunity_models.dart';

class ConditionBuilderScreen extends ConsumerStatefulWidget {
  const ConditionBuilderScreen({super.key});

  @override
  ConsumerState<ConditionBuilderScreen> createState() => _ConditionBuilderScreenState();
}

class _ConditionBuilderScreenState extends ConsumerState<ConditionBuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Builder state
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<ConditionRule> _rules = [];
  String _logic = 'AND';
  List<String> _symbols = [];
  bool _notifyOnTrigger = true;
  
  // Active conditions
  List<OpportunityCondition> _conditions = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadConditions();
    _addInitialRule();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addInitialRule() {
    _rules.add(ConditionRule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      metric: 'price',
      comparator: 'gt',
      value: 100.0,
    ));
  }

  Future<void> _loadConditions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/api/opportunities/conditions');
      
      setState(() {
        _conditions = (response['conditions'] as List<dynamic>?)
                ?.map((item) => OpportunityCondition.fromJson(item))
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Condition Builder'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Create Condition'),
            Tab(text: 'Active Conditions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBuilderTab(),
          _buildConditionsTab(),
        ],
      ),
    );
  }

  Widget _buildBuilderTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfo(),
          const SizedBox(height: 24),
          _buildLogicSelector(),
          const SizedBox(height: 24),
          _buildRulesList(),
          const SizedBox(height: 16),
          _buildAddRuleButton(),
          const SizedBox(height: 24),
          _buildSymbolsSelector(),
          const SizedBox(height: 24),
          _buildOptionsSection(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Condition Name',
            hintText: 'e.g., "Tech Stock Breakout Alert"',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description (optional)',
            hintText: 'Describe what this condition is looking for...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogicSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rule Logic',
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'How should the rules be combined?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLogicOption('AND', 'All rules must be true', _logic == 'AND'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildLogicOption('OR', 'Any rule can be true', _logic == 'OR'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogicOption(String logic, String description, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _logic = logic),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              logic,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Rules',
              style: AppTextStyles.headingMedium,
            ),
            const Spacer(),
            Text(
              '${_rules.length} rule${_rules.length != 1 ? 's' : ''}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(_rules.length, (index) {
          return Column(
            children: [
              _buildRuleCard(index),
              if (index < _rules.length - 1) const SizedBox(height: 12),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildRuleCard(int index) {
    final rule = _rules[index];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Rule ${index + 1}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_rules.length > 1)
                IconButton(
                  onPressed: () => _removeRule(index),
                  icon: Icon(Icons.close, color: AppColors.error),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricDropdown(index),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildComparatorDropdown(index),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildValueField(index),
              ),
            ],
          ),
          if (_needsTimeframe(rule.comparator)) ...[
            const SizedBox(height: 12),
            _buildTimeframeDropdown(index),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricDropdown(int index) {
    const metrics = {
      'price': 'Price',
      'volume': 'Volume',
      'iv': 'Implied Volatility',
      'pcr': 'Put/Call Ratio',
      'insider_buying': 'Insider Buying',
      'social_mentions': 'Social Mentions',
      'rsi': 'RSI',
    };
    
    return DropdownButtonFormField<String>(
      value: _rules[index].metric,
      decoration: const InputDecoration(
        labelText: 'Metric',
        border: OutlineInputBorder(),
      ),
      items: metrics.entries.map((entry) =>
        DropdownMenuItem(
          value: entry.key,
          child: Text(entry.value),
        ),
      ).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _rules[index] = ConditionRule(
              id: _rules[index].id,
              metric: value,
              comparator: _rules[index].comparator,
              value: _rules[index].value,
              timeframe: _rules[index].timeframe,
            );
          });
        }
      },
    );
  }

  Widget _buildComparatorDropdown(int index) {
    const comparators = {
      'gt': 'Greater than',
      'lt': 'Less than',
      'gte': 'Greater than or equal',
      'lte': 'Less than or equal',
      'eq': 'Equals',
      'crosses_above': 'Crosses above',
      'crosses_below': 'Crosses below',
      'pct_change_gt': '% change greater than',
      'pct_change_lt': '% change less than',
    };
    
    return DropdownButtonFormField<String>(
      value: _rules[index].comparator,
      decoration: const InputDecoration(
        labelText: 'Comparator',
        border: OutlineInputBorder(),
      ),
      items: comparators.entries.map((entry) =>
        DropdownMenuItem(
          value: entry.key,
          child: Text(entry.value),
        ),
      ).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _rules[index] = ConditionRule(
              id: _rules[index].id,
              metric: _rules[index].metric,
              comparator: value,
              value: _rules[index].value,
              timeframe: _needsTimeframe(value) ? (_rules[index].timeframe ?? '1d') : null,
            );
          });
        }
      },
    );
  }

  Widget _buildValueField(int index) {
    return TextFormField(
      initialValue: _rules[index].value.toString(),
      decoration: const InputDecoration(
        labelText: 'Value',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        final doubleValue = double.tryParse(value);
        if (doubleValue != null) {
          setState(() {
            _rules[index] = ConditionRule(
              id: _rules[index].id,
              metric: _rules[index].metric,
              comparator: _rules[index].comparator,
              value: doubleValue,
              timeframe: _rules[index].timeframe,
            );
          });
        }
      },
    );
  }

  Widget _buildTimeframeDropdown(int index) {
    const timeframes = {
      '1h': '1 Hour',
      '1d': '1 Day',
      '1w': '1 Week',
      '1m': '1 Month',
    };
    
    return DropdownButtonFormField<String>(
      value: _rules[index].timeframe ?? '1d',
      decoration: const InputDecoration(
        labelText: 'Timeframe',
        border: OutlineInputBorder(),
      ),
      items: timeframes.entries.map((entry) =>
        DropdownMenuItem(
          value: entry.key,
          child: Text(entry.value),
        ),
      ).toList(),
      onChanged: (value) {
        setState(() {
          _rules[index] = ConditionRule(
            id: _rules[index].id,
            metric: _rules[index].metric,
            comparator: _rules[index].comparator,
            value: _rules[index].value,
            timeframe: value,
          );
        });
      },
    );
  }

  bool _needsTimeframe(String comparator) {
    return ['pct_change_gt', 'pct_change_lt'].contains(comparator);
  }

  Widget _buildAddRuleButton() {
    return Center(
      child: OutlinedButton.icon(
        onPressed: _addRule,
        icon: const Icon(Icons.add),
        label: const Text('Add Rule'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  void _addRule() {
    setState(() {
      _rules.add(ConditionRule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        metric: 'price',
        comparator: 'gt',
        value: 100.0,
      ));
    });
  }

  void _removeRule(int index) {
    if (_rules.length > 1) {
      setState(() {
        _rules.removeAt(index);
      });
    }
  }

  Widget _buildSymbolsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Symbols',
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Leave empty to apply to all symbols',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_symbols.isEmpty) ...[
                Text(
                  'All symbols',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _symbols.map((symbol) =>
                    Chip(
                      label: Text(symbol),
                      onDeleted: () {
                        setState(() {
                          _symbols.remove(symbol);
                        });
                      },
                    ),
                  ).toList(),
                ),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _addSymbol,
                icon: const Icon(Icons.add),
                label: const Text('Add Symbol'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addSymbol() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Symbol'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Symbol',
              hintText: 'e.g., AAPL',
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final symbol = controller.text.trim().toUpperCase();
                if (symbol.isNotEmpty && !_symbols.contains(symbol)) {
                  setState(() {
                    _symbols.add(symbol);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options',
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Notify on trigger'),
          subtitle: const Text('Send notification when condition is met'),
          value: _notifyOnTrigger,
          onChanged: (value) {
            setState(() {
              _notifyOnTrigger = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _testCondition,
            icon: const Icon(Icons.science),
            label: const Text('Backtest'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.warning),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _createCondition,
            icon: const Icon(Icons.save),
            label: const Text('Create Condition'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _testCondition() {
    if (!_validateCondition()) return;
    
    showDialog(
      context: context,
      builder: (context) => _BacktestDialog(
        condition: OpportunityCondition(
          id: 'test',
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          rules: _rules,
          logic: _logic,
          symbols: _symbols.isNotEmpty ? _symbols : null,
          enabled: true,
          notifyOnTrigger: _notifyOnTrigger,
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> _createCondition() async {
    if (!_validateCondition()) return;
    
    try {
      final apiClient = ref.read(apiClientProvider);
      
      await apiClient.post('/api/opportunities/conditions', data: {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'rules': _rules.map((r) => r.toJson()).toList(),
        'logic': _logic,
        'symbols': _symbols.isNotEmpty ? _symbols : null,
        'notifyOnTrigger': _notifyOnTrigger,
      });
      
      // Reset form
      _nameController.clear();
      _descriptionController.clear();
      _rules.clear();
      _symbols.clear();
      _addInitialRule();
      
      // Reload conditions
      await _loadConditions();
      
      // Switch to conditions tab
      _tabController.animateTo(1);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Condition created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create condition: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  bool _validateCondition() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a condition name'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }
    
    if (_rules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one rule'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }
    
    return true;
  }

  Widget _buildConditionsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Failed to load conditions', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text(_error!, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadConditions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_conditions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rule, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'No conditions created yet',
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first condition to get started',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              child: const Text('Create Condition'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadConditions,
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _conditions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final condition = _conditions[index];
          return _buildConditionCard(condition);
        },
      ),
    );
  }

  Widget _buildConditionCard(OpportunityCondition condition) {
    return Card(
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    condition.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: condition.enabled,
                  onChanged: (value) => _toggleCondition(condition, value),
                ),
              ],
            ),
            if (condition.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                condition.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              condition.rulesDisplay,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Symbols: ${condition.symbolsDisplay}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            if (condition.hasTriggered) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Last triggered: ${_formatDate(condition.lastTriggered!)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _backtestCondition(condition),
                  icon: const Icon(Icons.analytics, size: 16),
                  label: const Text('Backtest'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.warning),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _deleteCondition(condition),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleCondition(OpportunityCondition condition, bool enabled) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      
      await apiClient.put('/api/opportunities/conditions/${condition.id}', data: {
        'enabled': enabled,
      });
      
      await _loadConditions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update condition: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _backtestCondition(OpportunityCondition condition) {
    showDialog(
      context: context,
      builder: (context) => _BacktestDialog(condition: condition),
    );
  }

  Future<void> _deleteCondition(OpportunityCondition condition) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Condition'),
        content: Text('Are you sure you want to delete "${condition.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.delete('/api/opportunities/conditions/${condition.id}');
        await _loadConditions();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Condition deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete condition: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inMinutes}m ago';
    }
  }
}

class _BacktestDialog extends ConsumerStatefulWidget {
  final OpportunityCondition condition;

  const _BacktestDialog({required this.condition});

  @override
  ConsumerState<_BacktestDialog> createState() => _BacktestDialogState();
}

class _BacktestDialogState extends ConsumerState<_BacktestDialog> {
  BacktestResult? _result;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runBacktest();
  }

  Future<void> _runBacktest() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
      
      final response = await apiClient.post(
        '/api/opportunities/conditions/${widget.condition.id}/backtest',
        data: {
          'fromDate': sixMonthsAgo.toIso8601String(),
          'toDate': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _result = BacktestResult.fromJson(response);
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
    return AlertDialog(
      title: Text('Backtest: ${widget.condition.name}'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : _error != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Backtest failed: $_error'),
                    ],
                  )
                : _buildBacktestResults(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildBacktestResults() {
    if (_result == null) return const SizedBox.shrink();

    final summary = _result!.summary;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Period: ${_result!.period.display} (${_result!.period.daysCount} days)',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          
          // Summary stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Total Triggers', summary.totalTriggers.toString()),
                _buildSummaryRow('Win Rate', summary.winRateDisplay),
                _buildSummaryRow('Winners', '${summary.winners}'),
                _buildSummaryRow('Losers', '${summary.losers}'),
                _buildSummaryRow('Avg P&L', summary.avgPnlDisplay),
                _buildSummaryRow('Avg P&L %', summary.avgPnlPctDisplay),
                _buildSummaryRow('Best Trade', summary.bestTradeDisplay),
                _buildSummaryRow('Worst Trade', summary.worstTradeDisplay),
                _buildSummaryRow('Avg Hold Time', summary.avgHoldTimeDisplay),
              ],
            ),
          ),
          
          if (_result!.triggers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Recent Triggers',
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: _result!.triggers.length,
                itemBuilder: (context, index) {
                  final trigger = _result!.triggers[index];
                  return ListTile(
                    title: Text(trigger.symbol),
                    subtitle: Text(_formatDate(trigger.triggeredAt)),
                    trailing: trigger.outcome != null
                        ? Text(
                            trigger.outcome!.formattedPnlPct,
                            style: TextStyle(
                              color: trigger.outcome!.isWinner 
                                  ? AppColors.success 
                                  : AppColors.error,
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}