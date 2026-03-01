import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:stockwatch/models/stock.dart';

class YahooFinanceService {
  static const String _baseUrl = 'https://query1.finance.yahoo.com/v8/finance/chart';
  static const String _quotesUrl = 'https://query1.finance.yahoo.com/v7/finance/quote';
  
  final Dio _dio;

  YahooFinanceService() : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // Get current quote for a symbol
  Future<Stock?> getQuote(String symbol) async {
    try {
      final response = await _dio.get(_quotesUrl, queryParameters: {
        'symbols': symbol,
      });
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['quoteResponse']['result'] as List<dynamic>;
        
        if (results.isNotEmpty) {
          return _parseStockQuote(results.first as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print('YahooFinanceService: Error fetching quote for $symbol: $e');
    }
    return null;
  }

  // Get multiple quotes efficiently
  Future<List<Stock>> getMultipleQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return [];
    
    try {
      final symbolsString = symbols.join(',');
      final response = await _dio.get(_quotesUrl, queryParameters: {
        'symbols': symbolsString,
      });
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['quoteResponse']['result'] as List<dynamic>;
        
        return results
            .map((item) => _parseStockQuote(item as Map<String, dynamic>))
            .whereType<Stock>()
            .toList();
      }
    } catch (e) {
      print('YahooFinanceService: Error fetching multiple quotes: $e');
    }
    return [];
  }

  // Get historical price data
  Future<List<PriceCandle>?> getHistoricalData(
    String symbol, {
    required DateTime from,
    required DateTime to,
    String interval = '1d', // 1m, 2m, 5m, 15m, 30m, 60m, 90m, 1h, 1d, 5d, 1wk, 1mo, 3mo
  }) async {
    try {
      final response = await _dio.get('$_baseUrl/$symbol', queryParameters: {
        'period1': from.millisecondsSinceEpoch ~/ 1000,
        'period2': to.millisecondsSinceEpoch ~/ 1000,
        'interval': interval,
        'includePrePost': 'true',
        'events': 'div,splits',
      });
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final chart = data['chart']['result'][0] as Map<String, dynamic>;
        
        return _parseHistoricalData(chart);
      }
    } catch (e) {
      print('YahooFinanceService: Error fetching historical data for $symbol: $e');
    }
    return null;
  }

  // Get major market indices
  Future<List<Stock>> getMajorIndices() async {
    final symbols = [
      '^GSPC', // S&P 500
      '^DJI',  // Dow Jones
      '^IXIC', // NASDAQ
      '^FTSE', // FTSE 100
      '^GDAXI', // DAX
      '^N225', // Nikkei 225
      '^HSI',  // Hang Seng
      '^AXJO', // ASX 200
    ];
    
    return getMultipleQuotes(symbols);
  }

  // Get commodity prices
  Future<List<Stock>> getCommodities() async {
    final symbols = [
      'GC=F',   // Gold
      'SI=F',   // Silver
      'PL=F',   // Platinum
      'PA=F',   // Palladium
      'CL=F',   // Crude Oil WTI
      'BZ=F',   // Brent Crude
      'NG=F',   // Natural Gas
      'HO=F',   // Heating Oil
      'ZW=F',   // Wheat
      'ZC=F',   // Corn
      'ZS=F',   // Soybeans
      'KC=F',   // Coffee
      'SB=F',   // Sugar
      'CC=F',   // Cocoa
      'CT=F',   // Cotton
      'HG=F',   // Copper
      'ALI=F',  // Aluminum
    ];
    
    return getMultipleQuotes(symbols);
  }

  // Get major forex pairs
  Future<List<Stock>> getForexPairs() async {
    final symbols = [
      'EURUSD=X',
      'GBPUSD=X',
      'USDJPY=X',
      'AUDUSD=X',
      'USDCHF=X',
      'USDCAD=X',
      'NZDUSD=X',
      'EURJPY=X',
      'GBPJPY=X',
      'EURGBP=X',
    ];
    
    return getMultipleQuotes(symbols);
  }

  // Get cryptocurrency prices
  Future<List<Stock>> getCryptoPrices() async {
    final symbols = [
      'BTC-USD',
      'ETH-USD',
      'BNB-USD',
      'XRP-USD',
      'ADA-USD',
      'SOL-USD',
      'DOT-USD',
      'DOGE-USD',
      'AVAX-USD',
      'MATIC-USD',
    ];
    
    return getMultipleQuotes(symbols);
  }

  // Get top gainers/losers
  Future<Map<String, List<Stock>>> getMarketMovers() async {
    try {
      // This is a simplified implementation - Yahoo Finance has specific endpoints for this
      final response = await _dio.get(
        'https://query1.finance.yahoo.com/v1/finance/screener',
        queryParameters: {
          'formatted': 'true',
          'crumb': 'placeholder', // Would need to get crumb token
          'lang': 'en-US',
          'region': 'US',
          'corsDomain': 'finance.yahoo.com',
        },
      );
      
      // This is a placeholder - actual implementation would parse screener results
      return {
        'gainers': <Stock>[],
        'losers': <Stock>[],
        'mostActive': <Stock>[],
      };
    } catch (e) {
      print('YahooFinanceService: Error fetching market movers: $e');
      return {
        'gainers': <Stock>[],
        'losers': <Stock>[],
        'mostActive': <Stock>[],
      };
    }
  }

  // Parse stock quote from Yahoo Finance data
  Stock _parseStockQuote(Map<String, dynamic> data) {
    final symbol = data['symbol'] as String;
    final name = data['shortName'] ?? data['longName'] ?? symbol;
    final exchange = data['fullExchangeName'] ?? data['exchange'] ?? 'Unknown';
    
    final price = (data['regularMarketPrice'] as num?)?.toDouble() ?? 0.0;
    final change = (data['regularMarketChange'] as num?)?.toDouble() ?? 0.0;
    final changePercent = (data['regularMarketChangePercent'] as num?)?.toDouble() ?? 0.0;
    final open = (data['regularMarketOpen'] as num?)?.toDouble() ?? 0.0;
    final high = (data['regularMarketDayHigh'] as num?)?.toDouble() ?? 0.0;
    final low = (data['regularMarketDayLow'] as num?)?.toDouble() ?? 0.0;
    final previousClose = (data['regularMarketPreviousClose'] as num?)?.toDouble() ?? 0.0;
    final volume = (data['regularMarketVolume'] as num?)?.toInt() ?? 0;
    final avgVolume = (data['averageDailyVolume10Day'] as num?)?.toInt() ?? 0;
    final marketCap = (data['marketCap'] as num?)?.toDouble() ?? 0.0;
    
    // Determine asset type
    String assetType = 'stock';
    if (symbol.contains('=X')) {
      assetType = 'forex';
    } else if (symbol.contains('=F')) {
      assetType = 'commodity';
    } else if (symbol.contains('-USD') || symbol.contains('-USDT')) {
      assetType = 'crypto';
    } else if (symbol.startsWith('^')) {
      assetType = 'index';
    }
    
    return Stock(
      symbol: symbol,
      name: name,
      exchange: exchange,
      type: assetType,
      price: price,
      change: change,
      changePercent: changePercent,
      open: open,
      high: high,
      low: low,
      previousClose: previousClose,
      volume: volume,
      avgVolume: avgVolume,
      marketCap: marketCap,
      lastUpdated: DateTime.now(),
      isRealTime: false,
    );
  }

  // Parse historical price data
  List<PriceCandle> _parseHistoricalData(Map<String, dynamic> chart) {
    final timestamps = (chart['timestamp'] as List<dynamic>).cast<int>();
    final indicators = chart['indicators']['quote'][0] as Map<String, dynamic>;
    
    final opens = (indicators['open'] as List<dynamic>).cast<num?>();
    final highs = (indicators['high'] as List<dynamic>).cast<num?>();
    final lows = (indicators['low'] as List<dynamic>).cast<num?>();
    final closes = (indicators['close'] as List<dynamic>).cast<num?>();
    final volumes = (indicators['volume'] as List<dynamic>).cast<int?>();

    final candles = <PriceCandle>[];
    for (int i = 0; i < timestamps.length; i++) {
      // Skip entries with null values
      if (opens[i] == null || highs[i] == null || 
          lows[i] == null || closes[i] == null) continue;
      
      candles.add(PriceCandle(
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000),
        open: opens[i]!.toDouble(),
        high: highs[i]!.toDouble(),
        low: lows[i]!.toDouble(),
        close: closes[i]!.toDouble(),
        volume: volumes[i] ?? 0,
      ));
    }
    
    return candles;
  }

  // Check if market is open (simplified)
  bool isMarketOpen() {
    final now = DateTime.now();
    final easternTime = now.toUtc().subtract(const Duration(hours: 5)); // EST/EDT approximation
    
    // Simple check - market is open Mon-Fri 9:30 AM to 4:00 PM ET
    if (easternTime.weekday > 5) return false; // Weekend
    
    final hour = easternTime.hour;
    final minute = easternTime.minute;
    final totalMinutes = hour * 60 + minute;
    
    // 9:30 AM = 570 minutes, 4:00 PM = 960 minutes
    return totalMinutes >= 570 && totalMinutes < 960;
  }

  // Get market status string
  String getMarketStatus() {
    if (isMarketOpen()) {
      return 'OPEN';
    } else {
      final now = DateTime.now();
      final easternTime = now.toUtc().subtract(const Duration(hours: 5));
      
      if (easternTime.weekday > 5) {
        return 'CLOSED (Weekend)';
      } else {
        final hour = easternTime.hour;
        if (hour < 9 || (hour == 9 && easternTime.minute < 30)) {
          return 'PRE_MARKET';
        } else {
          return 'AFTER_HOURS';
        }
      }
    }
  }

  void dispose() {
    _dio.close();
  }
}