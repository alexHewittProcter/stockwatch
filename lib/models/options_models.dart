class OptionContract {
  final double strike;
  final double lastPrice;
  final double bid;
  final double ask;
  final double change;
  final double changePct;
  final int volume;
  final int openInterest;
  final double impliedVolatility;
  final bool inTheMoney;
  final String contractSymbol;

  OptionContract({
    required this.strike,
    required this.lastPrice,
    required this.bid,
    required this.ask,
    required this.change,
    required this.changePct,
    required this.volume,
    required this.openInterest,
    required this.impliedVolatility,
    required this.inTheMoney,
    required this.contractSymbol,
  });

  factory OptionContract.fromJson(Map<String, dynamic> json) {
    return OptionContract(
      strike: (json['strike'] ?? 0).toDouble(),
      lastPrice: (json['lastPrice'] ?? 0).toDouble(),
      bid: (json['bid'] ?? 0).toDouble(),
      ask: (json['ask'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      changePct: (json['changePct'] ?? 0).toDouble(),
      volume: json['volume'] ?? 0,
      openInterest: json['openInterest'] ?? 0,
      impliedVolatility: (json['impliedVolatility'] ?? 0).toDouble(),
      inTheMoney: json['inTheMoney'] ?? false,
      contractSymbol: json['contractSymbol'] ?? '',
    );
  }
}

class OptionsChain {
  final String symbol;
  final List<String> expirations;
  final List<ChainExpiry> chains;

  OptionsChain({
    required this.symbol,
    required this.expirations,
    required this.chains,
  });

  factory OptionsChain.fromJson(Map<String, dynamic> json) {
    return OptionsChain(
      symbol: json['symbol'] ?? '',
      expirations: (json['expirations'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      chains: (json['chains'] as List<dynamic>?)
              ?.map((item) => ChainExpiry.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ChainExpiry {
  final String expiry;
  final int daysToExpiry;
  final List<OptionContract> calls;
  final List<OptionContract> puts;

  ChainExpiry({
    required this.expiry,
    required this.daysToExpiry,
    required this.calls,
    required this.puts,
  });

  factory ChainExpiry.fromJson(Map<String, dynamic> json) {
    return ChainExpiry(
      expiry: json['expiry'] ?? '',
      daysToExpiry: json['daysToExpiry'] ?? 0,
      calls: (json['calls'] as List<dynamic>?)
              ?.map((item) => OptionContract.fromJson(item))
              .toList() ??
          [],
      puts: (json['puts'] as List<dynamic>?)
              ?.map((item) => OptionContract.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class IVData {
  final String symbol;
  final double currentIV;
  final double ivRank;
  final double ivPercentile;
  final double iv52wHigh;
  final double iv52wLow;
  final double ivChange1d;
  final double ivChange1w;
  final List<IVHistoryPoint> history;
  final List<IVTermStructure> termStructure;

  IVData({
    required this.symbol,
    required this.currentIV,
    required this.ivRank,
    required this.ivPercentile,
    required this.iv52wHigh,
    required this.iv52wLow,
    required this.ivChange1d,
    required this.ivChange1w,
    required this.history,
    required this.termStructure,
  });

  factory IVData.fromJson(Map<String, dynamic> json) {
    return IVData(
      symbol: json['symbol'] ?? '',
      currentIV: (json['currentIV'] ?? 0).toDouble(),
      ivRank: (json['ivRank'] ?? 0).toDouble(),
      ivPercentile: (json['ivPercentile'] ?? 0).toDouble(),
      iv52wHigh: (json['iv52wHigh'] ?? 0).toDouble(),
      iv52wLow: (json['iv52wLow'] ?? 0).toDouble(),
      ivChange1d: (json['ivChange1d'] ?? 0).toDouble(),
      ivChange1w: (json['ivChange1w'] ?? 0).toDouble(),
      history: (json['history'] as List<dynamic>?)
              ?.map((item) => IVHistoryPoint.fromJson(item))
              .toList() ??
          [],
      termStructure: (json['termStructure'] as List<dynamic>?)
              ?.map((item) => IVTermStructure.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class IVHistoryPoint {
  final String date;
  final double iv;

  IVHistoryPoint({
    required this.date,
    required this.iv,
  });

  factory IVHistoryPoint.fromJson(Map<String, dynamic> json) {
    return IVHistoryPoint(
      date: json['date'] ?? '',
      iv: (json['iv'] ?? 0).toDouble(),
    );
  }
}

class IVTermStructure {
  final String expiry;
  final double iv;

  IVTermStructure({
    required this.expiry,
    required this.iv,
  });

  factory IVTermStructure.fromJson(Map<String, dynamic> json) {
    return IVTermStructure(
      expiry: json['expiry'] ?? '',
      iv: (json['iv'] ?? 0).toDouble(),
    );
  }
}

class UnusualActivity {
  final String id;
  final String ts;
  final String symbol;
  final String type;
  final double strike;
  final String expiry;
  final String sentiment;
  final String classification;
  final int volume;
  final int openInterest;
  final double volumeOIRatio;
  final double notionalValue;
  final double score;
  final String reason;

  UnusualActivity({
    required this.id,
    required this.ts,
    required this.symbol,
    required this.type,
    required this.strike,
    required this.expiry,
    required this.sentiment,
    required this.classification,
    required this.volume,
    required this.openInterest,
    required this.volumeOIRatio,
    required this.notionalValue,
    required this.score,
    required this.reason,
  });

  factory UnusualActivity.fromJson(Map<String, dynamic> json) {
    return UnusualActivity(
      id: json['id'] ?? '',
      ts: json['ts'] ?? '',
      symbol: json['symbol'] ?? '',
      type: json['type'] ?? '',
      strike: (json['strike'] ?? 0).toDouble(),
      expiry: json['expiry'] ?? '',
      sentiment: json['sentiment'] ?? '',
      classification: json['classification'] ?? '',
      volume: json['volume'] ?? 0,
      openInterest: json['openInterest'] ?? 0,
      volumeOIRatio: (json['volumeOIRatio'] ?? 0).toDouble(),
      notionalValue: (json['notionalValue'] ?? 0).toDouble(),
      score: (json['score'] ?? 0).toDouble(),
      reason: json['reason'] ?? '',
    );
  }
}

class PutCallRatio {
  final String symbol;
  final double ratio;
  final int putVolume;
  final int callVolume;
  final String sentiment;
  final List<PCRHistoryPoint> history;

  PutCallRatio({
    required this.symbol,
    required this.ratio,
    required this.putVolume,
    required this.callVolume,
    required this.sentiment,
    required this.history,
  });

  factory PutCallRatio.fromJson(Map<String, dynamic> json) {
    return PutCallRatio(
      symbol: json['symbol'] ?? '',
      ratio: (json['ratio'] ?? 0).toDouble(),
      putVolume: json['putVolume'] ?? 0,
      callVolume: json['callVolume'] ?? 0,
      sentiment: json['sentiment'] ?? '',
      history: (json['history'] as List<dynamic>?)
              ?.map((item) => PCRHistoryPoint.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class PCRHistoryPoint {
  final String date;
  final double ratio;

  PCRHistoryPoint({
    required this.date,
    required this.ratio,
  });

  factory PCRHistoryPoint.fromJson(Map<String, dynamic> json) {
    return PCRHistoryPoint(
      date: json['date'] ?? '',
      ratio: (json['ratio'] ?? 0).toDouble(),
    );
  }
}

class VolatilityDashboard {
  final VIXData vix;
  final List<HighIVStock> highestIV;
  final List<IVMover> biggestIVMoves;
  final List<UnusualActivity> unusualActivity;
  final String timestamp;

  VolatilityDashboard({
    required this.vix,
    required this.highestIV,
    required this.biggestIVMoves,
    required this.unusualActivity,
    required this.timestamp,
  });

  factory VolatilityDashboard.fromJson(Map<String, dynamic> json) {
    return VolatilityDashboard(
      vix: VIXData.fromJson(json['vix'] ?? {}),
      highestIV: (json['highestIV'] as List<dynamic>?)
              ?.map((item) => HighIVStock.fromJson(item))
              .toList() ??
          [],
      biggestIVMoves: (json['biggestIVMoves'] as List<dynamic>?)
              ?.map((item) => IVMover.fromJson(item))
              .toList() ??
          [],
      unusualActivity: (json['unusualActivity'] as List<dynamic>?)
              ?.map((item) => UnusualActivity.fromJson(item))
              .toList() ??
          [],
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class VIXData {
  final double current;
  final double change;
  final double changePct;
  final List<ChartPoint> chart;

  VIXData({
    required this.current,
    required this.change,
    required this.changePct,
    required this.chart,
  });

  factory VIXData.fromJson(Map<String, dynamic> json) {
    return VIXData(
      current: (json['current'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      changePct: (json['changePct'] ?? 0).toDouble(),
      chart: (json['chart'] as List<dynamic>?)
              ?.map((item) => ChartPoint.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ChartPoint {
  final int timestamp;
  final double value;

  ChartPoint({
    required this.timestamp,
    required this.value,
  });

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    return ChartPoint(
      timestamp: json['timestamp'] ?? 0,
      value: (json['value'] ?? 0).toDouble(),
    );
  }
}

class HighIVStock {
  final String symbol;
  final double iv;
  final double ivRank;

  HighIVStock({
    required this.symbol,
    required this.iv,
    required this.ivRank,
  });

  factory HighIVStock.fromJson(Map<String, dynamic> json) {
    return HighIVStock(
      symbol: json['symbol'] ?? '',
      iv: (json['iv'] ?? 0).toDouble(),
      ivRank: (json['ivRank'] ?? 0).toDouble(),
    );
  }
}

class IVMover {
  final String symbol;
  final double iv;
  final double change;
  final double changePct;

  IVMover({
    required this.symbol,
    required this.iv,
    required this.change,
    required this.changePct,
  });

  factory IVMover.fromJson(Map<String, dynamic> json) {
    return IVMover(
      symbol: json['symbol'] ?? '',
      iv: (json['iv'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      changePct: (json['changePct'] ?? 0).toDouble(),
    );
  }
}