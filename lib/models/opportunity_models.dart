class OpportunitySignal {
  final String id;
  final String type;
  final String category;
  final String symbol;
  final String source;
  final String description;
  final double strength;
  final String direction;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final DateTime detectedAt;

  OpportunitySignal({
    required this.id,
    required this.type,
    required this.category,
    required this.symbol,
    required this.source,
    required this.description,
    required this.strength,
    required this.direction,
    required this.data,
    required this.timestamp,
    required this.detectedAt,
  });

  factory OpportunitySignal.fromJson(Map<String, dynamic> json) {
    return OpportunitySignal(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      symbol: json['symbol'] ?? '',
      source: json['source'] ?? '',
      description: json['description'] ?? '',
      strength: (json['strength'] ?? 0).toDouble(),
      direction: json['direction'] ?? 'neutral',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      detectedAt: DateTime.tryParse(json['detectedAt'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isBullish => direction == 'bullish';
  bool get isBearish => direction == 'bearish';
  bool get isNeutral => direction == 'neutral';
}

class OpportunityEvidence {
  final String type;
  final String description;
  final dynamic value;
  final String? unit;
  final double? change;
  final double? changePercent;
  final String? context;
  final DateTime timestamp;

  OpportunityEvidence({
    required this.type,
    required this.description,
    required this.value,
    this.unit,
    this.change,
    this.changePercent,
    this.context,
    required this.timestamp,
  });

  factory OpportunityEvidence.fromJson(Map<String, dynamic> json) {
    return OpportunityEvidence(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      value: json['value'],
      unit: json['unit'],
      change: json['change']?.toDouble(),
      changePercent: json['changePercent']?.toDouble(),
      context: json['context'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  String get formattedValue {
    if (value is num) {
      if (unit != null) {
        switch (unit) {
          case 'percent':
            return '${value.toStringAsFixed(1)}%';
          case 'currency':
            return '\$${value.toStringAsFixed(2)}';
          case 'millions':
            return '\$${(value / 1000000).toStringAsFixed(1)}M';
          default:
            return '${value.toStringAsFixed(2)} $unit';
        }
      }
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }
}

class OpportunityOutcome {
  final double entryPrice;
  final double exitPrice;
  final double pnl;
  final double pnlPct;
  final DateTime triggeredAt;
  final DateTime closedAt;

  OpportunityOutcome({
    required this.entryPrice,
    required this.exitPrice,
    required this.pnl,
    required this.pnlPct,
    required this.triggeredAt,
    required this.closedAt,
  });

  factory OpportunityOutcome.fromJson(Map<String, dynamic> json) {
    return OpportunityOutcome(
      entryPrice: (json['entryPrice'] ?? 0).toDouble(),
      exitPrice: (json['exitPrice'] ?? 0).toDouble(),
      pnl: (json['pnl'] ?? 0).toDouble(),
      pnlPct: (json['pnlPct'] ?? 0).toDouble(),
      triggeredAt: DateTime.tryParse(json['triggeredAt'] ?? '') ?? DateTime.now(),
      closedAt: DateTime.tryParse(json['closedAt'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isWinner => pnl > 0;
  String get formattedPnl => pnl >= 0 ? '+\$${pnl.toStringAsFixed(2)}' : '-\$${pnl.abs().toStringAsFixed(2)}';
  String get formattedPnlPct => pnlPct >= 0 ? '+${pnlPct.toStringAsFixed(1)}%' : '${pnlPct.toStringAsFixed(1)}%';
}

class Opportunity {
  final String id;
  final DateTime createdAt;
  final String symbol;
  final String title;
  final String thesis;
  final int confidence;
  final String direction;
  final String timeframe;
  final List<OpportunitySignal> signals;
  final List<OpportunityEvidence> evidence;
  final double? suggestedEntry;
  final double? suggestedStop;
  final double? suggestedTarget;
  final double? riskReward;
  final String status;
  final List<String> tags;
  final OpportunityOutcome? outcome;
  final DateTime? updatedAt;

  Opportunity({
    required this.id,
    required this.createdAt,
    required this.symbol,
    required this.title,
    required this.thesis,
    required this.confidence,
    required this.direction,
    required this.timeframe,
    required this.signals,
    required this.evidence,
    this.suggestedEntry,
    this.suggestedStop,
    this.suggestedTarget,
    this.riskReward,
    required this.status,
    required this.tags,
    this.outcome,
    this.updatedAt,
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      symbol: json['symbol'] ?? '',
      title: json['title'] ?? '',
      thesis: json['thesis'] ?? '',
      confidence: json['confidence'] ?? 0,
      direction: json['direction'] ?? 'neutral',
      timeframe: json['timeframe'] ?? 'swing',
      signals: (json['signals'] as List<dynamic>?)
              ?.map((item) => OpportunitySignal.fromJson(item))
              .toList() ??
          [],
      evidence: (json['evidence'] as List<dynamic>?)
              ?.map((item) => OpportunityEvidence.fromJson(item))
              .toList() ??
          [],
      suggestedEntry: json['suggestedEntry']?.toDouble(),
      suggestedStop: json['suggestedStop']?.toDouble(),
      suggestedTarget: json['suggestedTarget']?.toDouble(),
      riskReward: json['riskReward']?.toDouble(),
      status: json['status'] ?? 'active',
      tags: (json['tags'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
      outcome: json['outcome'] != null ? OpportunityOutcome.fromJson(json['outcome']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  bool get isLong => direction == 'long';
  bool get isShort => direction == 'short';
  bool get isNeutral => direction == 'neutral';

  bool get isActive => status == 'active';
  bool get isTriggered => status == 'triggered';
  bool get isExpired => status == 'expired';
  bool get isWon => status == 'won';
  bool get isLost => status == 'lost';

  bool get isDayTrade => timeframe == 'day';
  bool get isSwingTrade => timeframe == 'swing';
  bool get isPositionTrade => timeframe == 'position';

  String get confidenceLevel {
    if (confidence >= 80) return 'Very High';
    if (confidence >= 60) return 'High';
    if (confidence >= 40) return 'Medium';
    if (confidence >= 20) return 'Low';
    return 'Very Low';
  }

  String get timeframeDisplay {
    switch (timeframe) {
      case 'day':
        return 'Day Trade';
      case 'swing':
        return 'Swing Trade';
      case 'position':
        return 'Position Trade';
      default:
        return timeframe;
    }
  }

  List<String> get signalCategories {
    return signals.map((s) => s.category).toSet().toList();
  }

  double get avgSignalStrength {
    if (signals.isEmpty) return 0;
    return signals.map((s) => s.strength).reduce((a, b) => a + b) / signals.length;
  }

  bool get hasPriceTargets {
    return suggestedEntry != null && suggestedStop != null && suggestedTarget != null;
  }

  String? get riskRewardDisplay {
    return riskReward != null ? '${riskReward!.toStringAsFixed(1)}:1' : null;
  }
}

class ConditionRule {
  final String id;
  final String metric;
  final String comparator;
  final double value;
  final String? timeframe;
  final Map<String, dynamic>? parameters;

  ConditionRule({
    required this.id,
    required this.metric,
    required this.comparator,
    required this.value,
    this.timeframe,
    this.parameters,
  });

  factory ConditionRule.fromJson(Map<String, dynamic> json) {
    return ConditionRule(
      id: json['id'] ?? '',
      metric: json['metric'] ?? '',
      comparator: json['comparator'] ?? 'gt',
      value: (json['value'] ?? 0).toDouble(),
      timeframe: json['timeframe'],
      parameters: json['parameters'] != null 
          ? Map<String, dynamic>.from(json['parameters'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metric': metric,
      'comparator': comparator,
      'value': value,
      if (timeframe != null) 'timeframe': timeframe,
      if (parameters != null) 'parameters': parameters,
    };
  }

  String get displayText {
    String metricDisplay = metric.replaceAll('_', ' ').toUpperCase();
    String comparatorDisplay = _getComparatorDisplay();
    String valueDisplay = _getValueDisplay();
    
    if (timeframe != null) {
      return '$metricDisplay $comparatorDisplay $valueDisplay ($timeframe)';
    }
    return '$metricDisplay $comparatorDisplay $valueDisplay';
  }

  String _getComparatorDisplay() {
    switch (comparator) {
      case 'gt': return '>';
      case 'lt': return '<';
      case 'gte': return '>=';
      case 'lte': return '<=';
      case 'eq': return '==';
      case 'crosses_above': return 'crosses above';
      case 'crosses_below': return 'crosses below';
      case 'pct_change_gt': return '% change >';
      case 'pct_change_lt': return '% change <';
      default: return comparator;
    }
  }

  String _getValueDisplay() {
    if (metric.contains('price') || metric.contains('value')) {
      return '\$${value.toStringAsFixed(2)}';
    } else if (comparator.contains('pct_change')) {
      return '${value.toStringAsFixed(1)}%';
    } else {
      return value.toStringAsFixed(2);
    }
  }
}

class OpportunityCondition {
  final String id;
  final String name;
  final String description;
  final List<ConditionRule> rules;
  final String logic;
  final List<String>? symbols;
  final bool enabled;
  final bool notifyOnTrigger;
  final DateTime createdAt;
  final DateTime? lastTriggered;
  final int? triggerCount;
  final DateTime? lastEvaluated;

  OpportunityCondition({
    required this.id,
    required this.name,
    required this.description,
    required this.rules,
    required this.logic,
    this.symbols,
    required this.enabled,
    required this.notifyOnTrigger,
    required this.createdAt,
    this.lastTriggered,
    this.triggerCount,
    this.lastEvaluated,
  });

  factory OpportunityCondition.fromJson(Map<String, dynamic> json) {
    return OpportunityCondition(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      rules: (json['rules'] as List<dynamic>?)
              ?.map((item) => ConditionRule.fromJson(item))
              .toList() ??
          [],
      logic: json['logic'] ?? 'AND',
      symbols: (json['symbols'] as List<dynamic>?)?.map((item) => item.toString()).toList(),
      enabled: json['enabled'] ?? true,
      notifyOnTrigger: json['notifyOnTrigger'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastTriggered: json['lastTriggered'] != null ? DateTime.tryParse(json['lastTriggered']) : null,
      triggerCount: json['triggerCount'],
      lastEvaluated: json['lastEvaluated'] != null ? DateTime.tryParse(json['lastEvaluated']) : null,
    );
  }

  String get symbolsDisplay {
    if (symbols == null || symbols!.isEmpty) return 'All symbols';
    if (symbols!.length <= 3) return symbols!.join(', ');
    return '${symbols!.take(3).join(', ')} +${symbols!.length - 3} more';
  }

  String get rulesDisplay {
    if (rules.isEmpty) return 'No rules';
    if (rules.length == 1) return rules.first.displayText;
    return '${rules.length} rules (${logic})';
  }

  bool get hasTriggered => lastTriggered != null;
}

class BacktestTrigger {
  final String symbol;
  final DateTime triggeredAt;
  final double price;
  final List<String> signals;
  final BacktestOutcome? outcome;

  BacktestTrigger({
    required this.symbol,
    required this.triggeredAt,
    required this.price,
    required this.signals,
    this.outcome,
  });

  factory BacktestTrigger.fromJson(Map<String, dynamic> json) {
    return BacktestTrigger(
      symbol: json['symbol'] ?? '',
      triggeredAt: DateTime.tryParse(json['triggeredAt'] ?? '') ?? DateTime.now(),
      price: (json['price'] ?? 0).toDouble(),
      signals: (json['signals'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
      outcome: json['outcome'] != null ? BacktestOutcome.fromJson(json['outcome']) : null,
    );
  }
}

class BacktestOutcome {
  final double exitPrice;
  final double pnl;
  final double pnlPct;
  final int duration;

  BacktestOutcome({
    required this.exitPrice,
    required this.pnl,
    required this.pnlPct,
    required this.duration,
  });

  factory BacktestOutcome.fromJson(Map<String, dynamic> json) {
    return BacktestOutcome(
      exitPrice: (json['exitPrice'] ?? 0).toDouble(),
      pnl: (json['pnl'] ?? 0).toDouble(),
      pnlPct: (json['pnlPct'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
    );
  }

  bool get isWinner => pnl > 0;
  String get formattedPnl => pnl >= 0 ? '+\$${pnl.toStringAsFixed(2)}' : '-\$${pnl.abs().toStringAsFixed(2)}';
  String get formattedPnlPct => pnlPct >= 0 ? '+${pnlPct.toStringAsFixed(1)}%' : '${pnlPct.toStringAsFixed(1)}%';
  String get durationDisplay => '$duration day${duration != 1 ? 's' : ''}';
}

class BacktestSummary {
  final int totalTriggers;
  final int winners;
  final int losers;
  final double winRate;
  final double avgPnl;
  final double avgPnlPct;
  final double bestTrade;
  final double worstTrade;
  final double avgHoldTime;

  BacktestSummary({
    required this.totalTriggers,
    required this.winners,
    required this.losers,
    required this.winRate,
    required this.avgPnl,
    required this.avgPnlPct,
    required this.bestTrade,
    required this.worstTrade,
    required this.avgHoldTime,
  });

  factory BacktestSummary.fromJson(Map<String, dynamic> json) {
    return BacktestSummary(
      totalTriggers: json['totalTriggers'] ?? 0,
      winners: json['winners'] ?? 0,
      losers: json['losers'] ?? 0,
      winRate: (json['winRate'] ?? 0).toDouble(),
      avgPnl: (json['avgPnl'] ?? 0).toDouble(),
      avgPnlPct: (json['avgPnlPct'] ?? 0).toDouble(),
      bestTrade: (json['bestTrade'] ?? 0).toDouble(),
      worstTrade: (json['worstTrade'] ?? 0).toDouble(),
      avgHoldTime: (json['avgHoldTime'] ?? 0).toDouble(),
    );
  }

  String get winRateDisplay => '${winRate.toStringAsFixed(1)}%';
  String get avgPnlDisplay => avgPnl >= 0 ? '+\$${avgPnl.toStringAsFixed(2)}' : '-\$${avgPnl.abs().toStringAsFixed(2)}';
  String get avgPnlPctDisplay => avgPnlPct >= 0 ? '+${avgPnlPct.toStringAsFixed(1)}%' : '${avgPnlPct.toStringAsFixed(1)}%';
  String get bestTradeDisplay => '\$${bestTrade.toStringAsFixed(2)}';
  String get worstTradeDisplay => '\$${worstTrade.toStringAsFixed(2)}';
  String get avgHoldTimeDisplay => '${avgHoldTime.toStringAsFixed(1)} days';
}

class BacktestResult {
  final OpportunityCondition condition;
  final BacktestPeriod period;
  final List<BacktestTrigger> triggers;
  final BacktestSummary summary;

  BacktestResult({
    required this.condition,
    required this.period,
    required this.triggers,
    required this.summary,
  });

  factory BacktestResult.fromJson(Map<String, dynamic> json) {
    return BacktestResult(
      condition: OpportunityCondition.fromJson(json['condition'] ?? {}),
      period: BacktestPeriod.fromJson(json['period'] ?? {}),
      triggers: (json['triggers'] as List<dynamic>?)
              ?.map((item) => BacktestTrigger.fromJson(item))
              .toList() ??
          [],
      summary: BacktestSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

class BacktestPeriod {
  final DateTime from;
  final DateTime to;

  BacktestPeriod({
    required this.from,
    required this.to,
  });

  factory BacktestPeriod.fromJson(Map<String, dynamic> json) {
    return BacktestPeriod(
      from: DateTime.tryParse(json['from'] ?? '') ?? DateTime.now(),
      to: DateTime.tryParse(json['to'] ?? '') ?? DateTime.now(),
    );
  }

  String get display {
    final fromStr = '${from.day}/${from.month}/${from.year}';
    final toStr = '${to.day}/${to.month}/${to.year}';
    return '$fromStr - $toStr';
  }

  int get daysCount {
    return to.difference(from).inDays + 1;
  }
}