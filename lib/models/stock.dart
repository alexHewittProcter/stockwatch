import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'stock.g.dart';

@JsonSerializable()
class Stock {
  final String symbol;
  final String name;
  final String exchange;
  final String type; // stock, forex, crypto, commodity
  final double price;
  final double change;
  final double changePercent;
  final double open;
  final double high;
  final double low;
  final double previousClose;
  final int volume;
  final int avgVolume;
  final double marketCap;
  final DateTime lastUpdated;
  final bool isRealTime;

  const Stock({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.type,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.open,
    required this.high,
    required this.low,
    required this.previousClose,
    required this.volume,
    required this.avgVolume,
    required this.marketCap,
    required this.lastUpdated,
    this.isRealTime = false,
  });

  bool get isPositive => change >= 0;
  bool get isNegative => change < 0;
  
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedChange => '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}';
  String get formattedChangePercent => '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';
  
  Stock copyWith({
    String? symbol,
    String? name,
    String? exchange,
    String? type,
    double? price,
    double? change,
    double? changePercent,
    double? open,
    double? high,
    double? low,
    double? previousClose,
    int? volume,
    int? avgVolume,
    double? marketCap,
    DateTime? lastUpdated,
    bool? isRealTime,
  }) {
    return Stock(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      exchange: exchange ?? this.exchange,
      type: type ?? this.type,
      price: price ?? this.price,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      previousClose: previousClose ?? this.previousClose,
      volume: volume ?? this.volume,
      avgVolume: avgVolume ?? this.avgVolume,
      marketCap: marketCap ?? this.marketCap,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isRealTime: isRealTime ?? this.isRealTime,
    );
  }

  factory Stock.fromJson(Map<String, dynamic> json) => _$StockFromJson(json);
  Map<String, dynamic> toJson() => _$StockToJson(this);

  @override
  String toString() => 'Stock($symbol: $formattedPrice $formattedChangePercent)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Stock &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol;

  @override
  int get hashCode => symbol.hashCode;
}

@JsonSerializable()
class MarketData {
  final List<Stock> stocks;
  final DateTime lastUpdated;
  final bool isMarketOpen;
  final String marketStatus;

  const MarketData({
    required this.stocks,
    required this.lastUpdated,
    required this.isMarketOpen,
    required this.marketStatus,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) => _$MarketDataFromJson(json);
  Map<String, dynamic> toJson() => _$MarketDataToJson(this);

  MarketData copyWith({
    List<Stock>? stocks,
    DateTime? lastUpdated,
    bool? isMarketOpen,
    String? marketStatus,
  }) {
    return MarketData(
      stocks: stocks ?? this.stocks,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isMarketOpen: isMarketOpen ?? this.isMarketOpen,
      marketStatus: marketStatus ?? this.marketStatus,
    );
  }
}

// Historical price data for charts
@JsonSerializable()
class PriceCandle {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  const PriceCandle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory PriceCandle.fromJson(Map<String, dynamic> json) => _$PriceCandleFromJson(json);
  Map<String, dynamic> toJson() => _$PriceCandleToJson(this);
}