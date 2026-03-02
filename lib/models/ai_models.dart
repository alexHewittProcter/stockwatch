class TradePattern {
  final String id;
  final String name;
  final String description;
  final String tradeId;
  final List<PatternCondition> conditions;
  final PatternStatistics statistics;
  final List<String> riskFactors;
  final List<String> bestTimeframes;
  final List<String> marketConditions;
  final DateTime createdAt;
  final int usedCount;
  final double? liveWinRate;
  final int? liveTradeCount;

  TradePattern({
    required this.id,
    required this.name,
    required this.description,
    required this.tradeId,
    required this.conditions,
    required this.statistics,
    required this.riskFactors,
    required this.bestTimeframes,
    required this.marketConditions,
    required this.createdAt,
    required this.usedCount,
    this.liveWinRate,
    this.liveTradeCount,
  });

  factory TradePattern.fromJson(Map<String, dynamic> json) {
    return TradePattern(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      tradeId: json['tradeId'] ?? '',
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((item) => PatternCondition.fromJson(item))
              .toList() ??
          [],
      statistics: PatternStatistics.fromJson(json['statistics'] ?? {}),
      riskFactors: (json['riskFactors'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
      bestTimeframes: (json['bestTimeframes'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
      marketConditions: (json['marketConditions'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      usedCount: json['usedCount'] ?? 0,
      liveWinRate: json['liveWinRate']?.toDouble(),
      liveTradeCount: json['liveTradeCount'],
    );
  }

  String get formattedWinRate {
    if (liveWinRate != null) {
      return '${(liveWinRate! * 100).toStringAsFixed(1)}%';
    }
    return '${(statistics.historicalWinRate * 100).toStringAsFixed(1)}%';
  }

  String get expectedValueDisplay {
    return '${statistics.expectedValue.toStringAsFixed(2)}%';
  }

  bool get hasLiveData => liveTradeCount != null && liveTradeCount! > 0;
}

class PatternCondition {
  final String metric;
  final String description;
  final double value;
  final double tolerance;
  final double weight;

  PatternCondition({
    required this.metric,
    required this.description,
    required this.value,
    required this.tolerance,
    required this.weight,
  });

  factory PatternCondition.fromJson(Map<String, dynamic> json) {
    return PatternCondition(
      metric: json['metric'] ?? '',
      description: json['description'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      tolerance: (json['tolerance'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
    );
  }
}

class PatternStatistics {
  final double historicalFrequency;
  final double historicalWinRate;
  final double averageReturn;
  final double averageLoss;
  final double expectedValue;
  final int sampleSize;
  final double averageHoldTime;
  final String bestPerformingTimeframe;

  PatternStatistics({
    required this.historicalFrequency,
    required this.historicalWinRate,
    required this.averageReturn,
    required this.averageLoss,
    required this.expectedValue,
    required this.sampleSize,
    required this.averageHoldTime,
    required this.bestPerformingTimeframe,
  });

  factory PatternStatistics.fromJson(Map<String, dynamic> json) {
    return PatternStatistics(
      historicalFrequency: (json['historicalFrequency'] ?? 0).toDouble(),
      historicalWinRate: (json['historicalWinRate'] ?? 0).toDouble(),
      averageReturn: (json['averageReturn'] ?? 0).toDouble(),
      averageLoss: (json['averageLoss'] ?? 0).toDouble(),
      expectedValue: (json['expectedValue'] ?? 0).toDouble(),
      sampleSize: json['sampleSize'] ?? 0,
      averageHoldTime: (json['averageHoldTime'] ?? 0).toDouble(),
      bestPerformingTimeframe: json['bestPerformingTimeframe'] ?? 'swing',
    );
  }
}

class ResearchReport {
  final String id;
  final String symbol;
  final String title;
  final DateTime createdAt;
  final String? opportunityId;
  final String executiveSummary;
  final ReportThesis thesis;
  final PriceAnalysis priceAnalysis;
  final HolderAnalysis? holderAnalysis;
  final OptionsAnalysis? optionsAnalysis;
  final NewsAnalysis newsAnalysis;
  final RiskAnalysis riskAnalysis;
  final ReportRecommendation recommendation;
  final HistoricalComparison? historicalComparison;
  final List<String> tags;
  final String status;
  final String? outcome;
  final String? outcomeNotes;
  final DateTime? updatedAt;

  ResearchReport({
    required this.id,
    required this.symbol,
    required this.title,
    required this.createdAt,
    this.opportunityId,
    required this.executiveSummary,
    required this.thesis,
    required this.priceAnalysis,
    this.holderAnalysis,
    this.optionsAnalysis,
    required this.newsAnalysis,
    required this.riskAnalysis,
    required this.recommendation,
    this.historicalComparison,
    required this.tags,
    required this.status,
    this.outcome,
    this.outcomeNotes,
    this.updatedAt,
  });

  factory ResearchReport.fromJson(Map<String, dynamic> json) {
    return ResearchReport(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      title: json['title'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      opportunityId: json['opportunityId'],
      executiveSummary: json['executiveSummary'] ?? '',
      thesis: ReportThesis.fromJson(json['thesis'] ?? {}),
      priceAnalysis: PriceAnalysis.fromJson(json['priceAnalysis'] ?? {}),
      holderAnalysis: json['holderAnalysis'] != null ? HolderAnalysis.fromJson(json['holderAnalysis']) : null,
      optionsAnalysis: json['optionsAnalysis'] != null ? OptionsAnalysis.fromJson(json['optionsAnalysis']) : null,
      newsAnalysis: NewsAnalysis.fromJson(json['newsAnalysis'] ?? {}),
      riskAnalysis: RiskAnalysis.fromJson(json['riskAnalysis'] ?? {}),
      recommendation: ReportRecommendation.fromJson(json['recommendation'] ?? {}),
      historicalComparison: json['historicalComparison'] != null ? HistoricalComparison.fromJson(json['historicalComparison']) : null,
      tags: (json['tags'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
      status: json['status'] ?? 'draft',
      outcome: json['outcome'],
      outcomeNotes: json['outcomeNotes'],
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  bool get isComplete => outcome == 'won' || outcome == 'lost';
  bool get isPending => outcome == 'pending' || outcome == null;
}

class ReportThesis {
  final String direction;
  final String timeframe;
  final String rationale;

  ReportThesis({
    required this.direction,
    required this.timeframe,
    required this.rationale,
  });

  factory ReportThesis.fromJson(Map<String, dynamic> json) {
    return ReportThesis(
      direction: json['direction'] ?? 'neutral',
      timeframe: json['timeframe'] ?? 'medium-term',
      rationale: json['rationale'] ?? '',
    );
  }

  bool get isLong => direction == 'long';
  bool get isShort => direction == 'short';
}

class PriceAnalysis {
  final double currentPrice;
  final List<double> support;
  final List<double> resistance;
  final String trend;
  final Map<String, dynamic> technicals;

  PriceAnalysis({
    required this.currentPrice,
    required this.support,
    required this.resistance,
    required this.trend,
    required this.technicals,
  });

  factory PriceAnalysis.fromJson(Map<String, dynamic> json) {
    return PriceAnalysis(
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      support: (json['support'] as List<dynamic>?)?.map((item) => (item as num).toDouble()).toList() ?? [],
      resistance: (json['resistance'] as List<dynamic>?)?.map((item) => (item as num).toDouble()).toList() ?? [],
      trend: json['trend'] ?? 'sideways',
      technicals: Map<String, dynamic>.from(json['technicals'] ?? {}),
    );
  }

  bool get isBullish => trend == 'uptrend';
  bool get isBearish => trend == 'downtrend';
}

class HolderAnalysis {
  final String recentInsiderActivity;
  final String institutionalChanges;
  final String smartMoneySignals;

  HolderAnalysis({
    required this.recentInsiderActivity,
    required this.institutionalChanges,
    required this.smartMoneySignals,
  });

  factory HolderAnalysis.fromJson(Map<String, dynamic> json) {
    return HolderAnalysis(
      recentInsiderActivity: json['recentInsiderActivity'] ?? '',
      institutionalChanges: json['institutionalChanges'] ?? '',
      smartMoneySignals: json['smartMoneySignals'] ?? '',
    );
  }
}

class OptionsAnalysis {
  final double ivRank;
  final String unusualActivity;
  final String putCallRatio;
  final String suggestedStrategy;

  OptionsAnalysis({
    required this.ivRank,
    required this.unusualActivity,
    required this.putCallRatio,
    required this.suggestedStrategy,
  });

  factory OptionsAnalysis.fromJson(Map<String, dynamic> json) {
    return OptionsAnalysis(
      ivRank: (json['ivRank'] ?? 0).toDouble(),
      unusualActivity: json['unusualActivity'] ?? '',
      putCallRatio: json['putCallRatio'] ?? '',
      suggestedStrategy: json['suggestedStrategy'] ?? '',
    );
  }
}

class NewsAnalysis {
  final double sentiment;
  final String sentimentTrend;
  final List<Map<String, String>> keyArticles;
  final String socialBuzz;

  NewsAnalysis({
    required this.sentiment,
    required this.sentimentTrend,
    required this.keyArticles,
    required this.socialBuzz,
  });

  factory NewsAnalysis.fromJson(Map<String, dynamic> json) {
    return NewsAnalysis(
      sentiment: (json['sentiment'] ?? 0).toDouble(),
      sentimentTrend: json['sentimentTrend'] ?? '',
      keyArticles: (json['keyArticles'] as List<dynamic>?)
              ?.map((item) => Map<String, String>.from(item))
              .toList() ??
          [],
      socialBuzz: json['socialBuzz'] ?? '',
    );
  }

  bool get isPositive => sentiment > 0.2;
  bool get isNegative => sentiment < -0.2;
}

class RiskAnalysis {
  final List<String> risks;
  final List<String> catalysts;
  final String maxLoss;

  RiskAnalysis({
    required this.risks,
    required this.catalysts,
    required this.maxLoss,
  });

  factory RiskAnalysis.fromJson(Map<String, dynamic> json) {
    return RiskAnalysis(
      risks: (json['risks'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
      catalysts: (json['catalysts'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
      maxLoss: json['maxLoss'] ?? '',
    );
  }
}

class ReportRecommendation {
  final String action;
  final double entry;
  final double stopLoss;
  final double target;
  final double riskReward;
  final String positionSize;
  final int confidence;

  ReportRecommendation({
    required this.action,
    required this.entry,
    required this.stopLoss,
    required this.target,
    required this.riskReward,
    required this.positionSize,
    required this.confidence,
  });

  factory ReportRecommendation.fromJson(Map<String, dynamic> json) {
    return ReportRecommendation(
      action: json['action'] ?? '',
      entry: (json['entry'] ?? 0).toDouble(),
      stopLoss: (json['stopLoss'] ?? 0).toDouble(),
      target: (json['target'] ?? 0).toDouble(),
      riskReward: (json['riskReward'] ?? 0).toDouble(),
      positionSize: json['positionSize'] ?? '',
      confidence: json['confidence'] ?? 0,
    );
  }

  String get riskRewardDisplay => '${riskReward.toStringAsFixed(1)}:1';
  String get confidenceLevel {
    if (confidence >= 80) return 'Very High';
    if (confidence >= 60) return 'High';
    if (confidence >= 40) return 'Medium';
    return 'Low';
  }
}

class HistoricalComparison {
  final int similarSetups;
  final double winRate;
  final double averageReturn;
  final String? patternId;

  HistoricalComparison({
    required this.similarSetups,
    required this.winRate,
    required this.averageReturn,
    this.patternId,
  });

  factory HistoricalComparison.fromJson(Map<String, dynamic> json) {
    return HistoricalComparison(
      similarSetups: json['similarSetups'] ?? 0,
      winRate: (json['winRate'] ?? 0).toDouble(),
      averageReturn: (json['averageReturn'] ?? 0).toDouble(),
      patternId: json['patternId'],
    );
  }

  String get winRateDisplay => '${(winRate * 100).toStringAsFixed(1)}%';
}

class TradeJournalEntry {
  final String id;
  final String symbol;
  final String direction;
  final DateTime entryDate;
  final double entryPrice;
  final DateTime? exitDate;
  final double? exitPrice;
  final double quantity;
  final double? pnl;
  final double? pnlPct;
  final String status;
  final Map<String, dynamic> entryContext;
  final String notes;
  final List<String> tags;
  final String? patternId;
  final DateTime? learnedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TradeJournalEntry({
    required this.id,
    required this.symbol,
    required this.direction,
    required this.entryDate,
    required this.entryPrice,
    this.exitDate,
    this.exitPrice,
    required this.quantity,
    this.pnl,
    this.pnlPct,
    required this.status,
    required this.entryContext,
    required this.notes,
    required this.tags,
    this.patternId,
    this.learnedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory TradeJournalEntry.fromJson(Map<String, dynamic> json) {
    return TradeJournalEntry(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      direction: json['direction'] ?? 'long',
      entryDate: DateTime.tryParse(json['entryDate'] ?? '') ?? DateTime.now(),
      entryPrice: (json['entryPrice'] ?? 0).toDouble(),
      exitDate: json['exitDate'] != null ? DateTime.tryParse(json['exitDate']) : null,
      exitPrice: json['exitPrice']?.toDouble(),
      quantity: (json['quantity'] ?? 0).toDouble(),
      pnl: json['pnl']?.toDouble(),
      pnlPct: json['pnlPct']?.toDouble(),
      status: json['status'] ?? 'open',
      entryContext: Map<String, dynamic>.from(json['entryContext'] ?? {}),
      notes: json['notes'] ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
      patternId: json['patternId'],
      learnedAt: json['learnedAt'] != null ? DateTime.tryParse(json['learnedAt']) : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  bool get isOpen => status == 'open';
  bool get isWin => status == 'closed_win';
  bool get isLoss => status == 'closed_loss';
  bool get isLong => direction == 'long';
  bool get isShort => direction == 'short';
  bool get canLearn => isWin && patternId == null;
  bool get hasPattern => patternId != null;

  String get statusDisplay {
    switch (status) {
      case 'open': return 'Open';
      case 'closed_win': return 'Win';
      case 'closed_loss': return 'Loss';
      default: return status;
    }
  }

  String get pnlDisplay {
    if (pnlPct == null) return '--';
    final sign = pnlPct! >= 0 ? '+' : '';
    return '$sign${pnlPct!.toStringAsFixed(2)}%';
  }

  String get directionDisplay => isLong ? 'Long' : 'Short';

  int? get holdDays {
    if (exitDate == null) return null;
    return exitDate!.difference(entryDate).inDays;
  }
}