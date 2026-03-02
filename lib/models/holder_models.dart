class HolderData {
  final String symbol;
  final double institutionalOwnership;
  final double insiderOwnership;
  final List<InstitutionalHolder> topInstitutional;
  final List<InsiderHolder> topInsider;
  final List<FundHolder> topFunds;
  final List<InsiderTransaction>? recentInsiderTransactions;
  final bool? insiderBuyingSignal;

  HolderData({
    required this.symbol,
    required this.institutionalOwnership,
    required this.insiderOwnership,
    required this.topInstitutional,
    required this.topInsider,
    required this.topFunds,
    this.recentInsiderTransactions,
    this.insiderBuyingSignal,
  });

  factory HolderData.fromJson(Map<String, dynamic> json) {
    return HolderData(
      symbol: json['symbol'] ?? '',
      institutionalOwnership: (json['institutionalOwnership'] ?? 0).toDouble(),
      insiderOwnership: (json['insiderOwnership'] ?? 0).toDouble(),
      topInstitutional: (json['topInstitutional'] as List<dynamic>?)
              ?.map((item) => InstitutionalHolder.fromJson(item))
              .toList() ??
          [],
      topInsider: (json['topInsider'] as List<dynamic>?)
              ?.map((item) => InsiderHolder.fromJson(item))
              .toList() ??
          [],
      topFunds: (json['topFunds'] as List<dynamic>?)
              ?.map((item) => FundHolder.fromJson(item))
              .toList() ??
          [],
      recentInsiderTransactions:
          (json['recentInsiderTransactions'] as List<dynamic>?)
              ?.map((item) => InsiderTransaction.fromJson(item))
              .toList(),
      insiderBuyingSignal: json['insiderBuyingSignal'],
    );
  }
}

class InstitutionalHolder {
  final String name;
  final String? cik;
  final int shares;
  final double value;
  final double pctOfPortfolio;
  final int changeFromPrev;
  final String changeType;
  final String filingDate;

  InstitutionalHolder({
    required this.name,
    this.cik,
    required this.shares,
    required this.value,
    required this.pctOfPortfolio,
    required this.changeFromPrev,
    required this.changeType,
    required this.filingDate,
  });

  factory InstitutionalHolder.fromJson(Map<String, dynamic> json) {
    return InstitutionalHolder(
      name: json['name'] ?? '',
      cik: json['cik'],
      shares: json['shares'] ?? 0,
      value: (json['value'] ?? 0).toDouble(),
      pctOfPortfolio: (json['pctOfPortfolio'] ?? 0).toDouble(),
      changeFromPrev: json['changeFromPrev'] ?? 0,
      changeType: json['changeType'] ?? 'unchanged',
      filingDate: json['filingDate'] ?? '',
    );
  }
}

class InsiderHolder {
  final String name;
  final String title;
  final String lastTransaction;
  final int shares;
  final double value;
  final String date;

  InsiderHolder({
    required this.name,
    required this.title,
    required this.lastTransaction,
    required this.shares,
    required this.value,
    required this.date,
  });

  factory InsiderHolder.fromJson(Map<String, dynamic> json) {
    return InsiderHolder(
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      lastTransaction: json['lastTransaction'] ?? '',
      shares: json['shares'] ?? 0,
      value: (json['value'] ?? 0).toDouble(),
      date: json['date'] ?? '',
    );
  }
}

class FundHolder {
  final String name;
  final int shares;
  final double value;

  FundHolder({
    required this.name,
    required this.shares,
    required this.value,
  });

  factory FundHolder.fromJson(Map<String, dynamic> json) {
    return FundHolder(
      name: json['name'] ?? '',
      shares: json['shares'] ?? 0,
      value: (json['value'] ?? 0).toDouble(),
    );
  }
}

class InstitutionPortfolio {
  final String cik;
  final String name;
  final double totalValue;
  final int positionCount;
  final String? filingDate;
  final List<Holding> holdings;
  final QuarterOverQuarter quarterOverQuarter;

  InstitutionPortfolio({
    required this.cik,
    required this.name,
    required this.totalValue,
    required this.positionCount,
    this.filingDate,
    required this.holdings,
    required this.quarterOverQuarter,
  });

  factory InstitutionPortfolio.fromJson(Map<String, dynamic> json) {
    return InstitutionPortfolio(
      cik: json['cik'] ?? '',
      name: json['name'] ?? '',
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      positionCount: json['positionCount'] ?? 0,
      filingDate: json['filingDate'],
      holdings: (json['holdings'] as List<dynamic>?)
              ?.map((item) => Holding.fromJson(item))
              .toList() ??
          [],
      quarterOverQuarter: QuarterOverQuarter.fromJson(
          json['quarterOverQuarter'] ?? {}),
    );
  }
}

class Holding {
  final String symbol;
  final String name;
  final int shares;
  final double value;
  final double pctOfPortfolio;
  final int changeFromPrev;
  final String changeType;

  Holding({
    required this.symbol,
    required this.name,
    required this.shares,
    required this.value,
    required this.pctOfPortfolio,
    required this.changeFromPrev,
    required this.changeType,
  });

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      shares: json['shares'] ?? 0,
      value: (json['value'] ?? 0).toDouble(),
      pctOfPortfolio: (json['pctOfPortfolio'] ?? 0).toDouble(),
      changeFromPrev: json['changeFromPrev'] ?? 0,
      changeType: json['changeType'] ?? 'unchanged',
    );
  }
}

class QuarterOverQuarter {
  final int newPositions;
  final int exitedPositions;
  final int increasedPositions;
  final int decreasedPositions;

  QuarterOverQuarter({
    required this.newPositions,
    required this.exitedPositions,
    required this.increasedPositions,
    required this.decreasedPositions,
  });

  factory QuarterOverQuarter.fromJson(Map<String, dynamic> json) {
    return QuarterOverQuarter(
      newPositions: json['newPositions'] ?? 0,
      exitedPositions: json['exitedPositions'] ?? 0,
      increasedPositions: json['increasedPositions'] ?? 0,
      decreasedPositions: json['decreasedPositions'] ?? 0,
    );
  }
}

class TrackedHolder {
  final String id;
  final String name;
  final String type;
  final String? cik;
  final String trackedSince;
  final String? lastCheck;
  final int? recentChanges;
  final String? lastActivity;

  TrackedHolder({
    required this.id,
    required this.name,
    required this.type,
    this.cik,
    required this.trackedSince,
    this.lastCheck,
    this.recentChanges,
    this.lastActivity,
  });

  factory TrackedHolder.fromJson(Map<String, dynamic> json) {
    return TrackedHolder(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      cik: json['cik'],
      trackedSince: json['tracked_since'] ?? json['trackedSince'] ?? '',
      lastCheck: json['last_check'] ?? json['lastCheck'],
      recentChanges: json['recent_changes'],
      lastActivity: json['last_activity'] ?? json['lastActivity'],
    );
  }
}

class InsiderTransaction {
  final String symbol;
  final String insiderName;
  final String insiderTitle;
  final String transactionCode;
  final int transactionShares;
  final double transactionPrice;
  final int sharesOwned;
  final String transactionDate;

  InsiderTransaction({
    required this.symbol,
    required this.insiderName,
    required this.insiderTitle,
    required this.transactionCode,
    required this.transactionShares,
    required this.transactionPrice,
    required this.sharesOwned,
    required this.transactionDate,
  });

  factory InsiderTransaction.fromJson(Map<String, dynamic> json) {
    return InsiderTransaction(
      symbol: json['symbol'] ?? '',
      insiderName: json['insiderName'] ?? '',
      insiderTitle: json['insiderTitle'] ?? '',
      transactionCode: json['transactionCode'] ?? '',
      transactionShares: json['transactionShares'] ?? 0,
      transactionPrice: (json['transactionPrice'] ?? 0).toDouble(),
      sharesOwned: json['sharesOwned'] ?? 0,
      transactionDate: json['transactionDate'] ?? '',
    );
  }

  bool get isPurchase => transactionCode == 'P';
  bool get isSale => transactionCode == 'S';
  double get transactionValue => transactionShares * transactionPrice;
}

class HolderChange {
  final String id;
  final String cik;
  final String holderName;
  final String symbol;
  final String action;
  final int sharesChange;
  final double valueChange;
  final double pctChange;
  final String quarter;
  final String createdAt;

  HolderChange({
    required this.id,
    required this.cik,
    required this.holderName,
    required this.symbol,
    required this.action,
    required this.sharesChange,
    required this.valueChange,
    required this.pctChange,
    required this.quarter,
    required this.createdAt,
  });

  factory HolderChange.fromJson(Map<String, dynamic> json) {
    return HolderChange(
      id: json['id'] ?? '',
      cik: json['cik'] ?? '',
      holderName: json['holderName'] ?? '',
      symbol: json['symbol'] ?? '',
      action: json['action'] ?? '',
      sharesChange: json['sharesChange'] ?? 0,
      valueChange: (json['valueChange'] ?? 0).toDouble(),
      pctChange: (json['pctChange'] ?? 0).toDouble(),
      quarter: json['quarter'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class SmartMoneySignal {
  final String symbol;
  final int holderCount;
  final double totalValue;
  final List<HolderAction> holders;
  final int confidence;
  final String detectedAt;

  SmartMoneySignal({
    required this.symbol,
    required this.holderCount,
    required this.totalValue,
    required this.holders,
    required this.confidence,
    required this.detectedAt,
  });

  factory SmartMoneySignal.fromJson(Map<String, dynamic> json) {
    return SmartMoneySignal(
      symbol: json['symbol'] ?? '',
      holderCount: json['holderCount'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      holders: (json['holders'] as List<dynamic>?)
              ?.map((item) => HolderAction.fromJson(item))
              .toList() ??
          [],
      confidence: json['confidence'] ?? 0,
      detectedAt: json['detectedAt'] ?? '',
    );
  }
}

class HolderAction {
  final String name;
  final String action;
  final int sharesChange;
  final double valueChange;

  HolderAction({
    required this.name,
    required this.action,
    required this.sharesChange,
    required this.valueChange,
  });

  factory HolderAction.fromJson(Map<String, dynamic> json) {
    return HolderAction(
      name: json['name'] ?? '',
      action: json['action'] ?? '',
      sharesChange: json['sharesChange'] ?? 0,
      valueChange: (json['valueChange'] ?? 0).toDouble(),
    );
  }
}