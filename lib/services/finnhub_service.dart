import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:stockwatch/models/stock.dart';

class FinnhubService {
  static const String _baseUrl = 'https://finnhub.io/api/v1';
  static const String _wsUrl = 'wss://ws.finnhub.io';
  
  final Dio _dio;
  final String _apiKey;
  
  WebSocketChannel? _wsChannel;
  StreamController<Map<String, Stock>>? _priceStreamController;
  final Map<String, Stock> _currentPrices = {};
  final Set<String> _subscribedSymbols = {};
  
  bool _isConnected = false;
  Timer? _reconnectTimer;
  
  FinnhubService({required String apiKey}) : 
    _apiKey = apiKey,
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      queryParameters: {'token': apiKey},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

  // Stream of real-time price updates
  Stream<Map<String, Stock>> get priceStream {
    _priceStreamController ??= StreamController<Map<String, Stock>>.broadcast();
    return _priceStreamController!.stream;
  }

  // Connect to WebSocket for real-time data
  Future<void> connectWebSocket() async {
    if (_isConnected) return;
    
    try {
      _wsChannel = IOWebSocketChannel.connect('$_wsUrl?token=$_apiKey');
      _isConnected = true;
      
      _wsChannel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketDone,
      );
      
      print('FinnhubService: WebSocket connected');
    } catch (e) {
      print('FinnhubService: WebSocket connection failed: $e');
      _scheduleReconnect();
    }
  }

  // Disconnect WebSocket
  void disconnectWebSocket() {
    _isConnected = false;
    _reconnectTimer?.cancel();
    _wsChannel?.sink.close();
    _wsChannel = null;
  }

  // Subscribe to real-time updates for symbols
  Future<void> subscribeToSymbols(List<String> symbols) async {
    if (!_isConnected) {
      await connectWebSocket();
    }
    
    for (final symbol in symbols) {
      if (!_subscribedSymbols.contains(symbol)) {
        _subscribedSymbols.add(symbol);
        _wsChannel?.sink.add(jsonEncode({
          'type': 'subscribe',
          'symbol': symbol,
        }));
      }
    }
  }

  // Unsubscribe from symbols
  void unsubscribeFromSymbols(List<String> symbols) {
    for (final symbol in symbols) {
      if (_subscribedSymbols.contains(symbol)) {
        _subscribedSymbols.remove(symbol);
        _wsChannel?.sink.add(jsonEncode({
          'type': 'unsubscribe',
          'symbol': symbol,
        }));
      }
    }
  }

  // Get current quote via REST API
  Future<Stock?> getQuote(String symbol) async {
    try {
      final response = await _dio.get('/quote', queryParameters: {
        'symbol': symbol,
      });
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return _parseStockQuote(symbol, data);
      }
    } catch (e) {
      print('FinnhubService: Error fetching quote for $symbol: $e');
    }
    return null;
  }

  // Get multiple quotes
  Future<List<Stock>> getMultipleQuotes(List<String> symbols) async {
    final futures = symbols.map((symbol) => getQuote(symbol));
    final results = await Future.wait(futures);
    return results.whereType<Stock>().toList();
  }

  // Get company profile
  Future<Map<String, dynamic>?> getCompanyProfile(String symbol) async {
    try {
      final response = await _dio.get('/stock/profile2', queryParameters: {
        'symbol': symbol,
      });
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print('FinnhubService: Error fetching company profile for $symbol: $e');
    }
    return null;
  }

  // Get market status
  Future<Map<String, dynamic>?> getMarketStatus() async {
    try {
      final response = await _dio.get('/stock/market-status', queryParameters: {
        'exchange': 'US',
      });
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print('FinnhubService: Error fetching market status: $e');
    }
    return null;
  }

  // Get historical candles
  Future<List<PriceCandle>?> getCandles(
    String symbol, {
    required String resolution, // 1, 5, 15, 30, 60, D, W, M
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final response = await _dio.get('/stock/candle', queryParameters: {
        'symbol': symbol,
        'resolution': resolution,
        'from': from.millisecondsSinceEpoch ~/ 1000,
        'to': to.millisecondsSinceEpoch ~/ 1000,
      });
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['s'] == 'ok') {
          return _parseCandleData(data);
        }
      }
    } catch (e) {
      print('FinnhubService: Error fetching candles for $symbol: $e');
    }
    return null;
  }

  // Handle WebSocket messages
  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      
      if (data['type'] == 'trade') {
        final trades = data['data'] as List<dynamic>;
        for (final trade in trades) {
          _processTrade(trade as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print('FinnhubService: Error processing WebSocket message: $e');
    }
  }

  // Process individual trade data
  void _processTrade(Map<String, dynamic> trade) {
    final symbol = trade['s'] as String;
    final price = (trade['p'] as num).toDouble();
    final volume = trade['v'] as int;
    final timestamp = DateTime.fromMillisecondsSinceEpoch(
      (trade['t'] as int),
    );

    // Update current price and emit update
    final existingStock = _currentPrices[symbol];
    if (existingStock != null) {
      final change = price - existingStock.previousClose;
      final changePercent = (change / existingStock.previousClose) * 100;
      
      _currentPrices[symbol] = existingStock.copyWith(
        price: price,
        change: change,
        changePercent: changePercent,
        volume: volume,
        lastUpdated: timestamp,
        isRealTime: true,
      );
    } else {
      // Create new stock entry (will need to fetch additional data)
      _currentPrices[symbol] = Stock(
        symbol: symbol,
        name: symbol, // Will be updated when profile is fetched
        exchange: 'US',
        type: 'stock',
        price: price,
        change: 0.0,
        changePercent: 0.0,
        open: price,
        high: price,
        low: price,
        previousClose: price,
        volume: volume,
        avgVolume: volume,
        marketCap: 0.0,
        lastUpdated: timestamp,
        isRealTime: true,
      );
    }

    // Emit update
    _priceStreamController?.add(Map.from(_currentPrices));
  }

  // Handle WebSocket errors
  void _handleWebSocketError(dynamic error) {
    print('FinnhubService: WebSocket error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  // Handle WebSocket disconnection
  void _handleWebSocketDone() {
    print('FinnhubService: WebSocket disconnected');
    _isConnected = false;
    _scheduleReconnect();
  }

  // Schedule reconnection attempt
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        print('FinnhubService: Attempting to reconnect...');
        connectWebSocket();
      }
    });
  }

  // Parse stock quote data
  Stock _parseStockQuote(String symbol, Map<String, dynamic> data) {
    final price = (data['c'] as num).toDouble(); // Current price
    final change = (data['d'] as num).toDouble(); // Change
    final changePercent = (data['dp'] as num).toDouble(); // Change percent
    final high = (data['h'] as num).toDouble(); // Day high
    final low = (data['l'] as num).toDouble(); // Day low
    final open = (data['o'] as num).toDouble(); // Day open
    final previousClose = (data['pc'] as num).toDouble(); // Previous close
    
    return Stock(
      symbol: symbol,
      name: symbol, // Will be updated when profile is fetched
      exchange: 'US',
      type: 'stock',
      price: price,
      change: change,
      changePercent: changePercent,
      open: open,
      high: high,
      low: low,
      previousClose: previousClose,
      volume: 0, // Not provided in quote
      avgVolume: 0, // Not provided in quote
      marketCap: 0.0, // Not provided in quote
      lastUpdated: DateTime.now(),
      isRealTime: false,
    );
  }

  // Parse candle data
  List<PriceCandle> _parseCandleData(Map<String, dynamic> data) {
    final timestamps = (data['t'] as List<dynamic>).cast<int>();
    final opens = (data['o'] as List<dynamic>).cast<num>();
    final highs = (data['h'] as List<dynamic>).cast<num>();
    final lows = (data['l'] as List<dynamic>).cast<num>();
    final closes = (data['c'] as List<dynamic>).cast<num>();
    final volumes = (data['v'] as List<dynamic>).cast<int>();

    final candles = <PriceCandle>[];
    for (int i = 0; i < timestamps.length; i++) {
      candles.add(PriceCandle(
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000),
        open: opens[i].toDouble(),
        high: highs[i].toDouble(),
        low: lows[i].toDouble(),
        close: closes[i].toDouble(),
        volume: volumes[i],
      ));
    }
    
    return candles;
  }

  // Clean up resources
  void dispose() {
    disconnectWebSocket();
    _priceStreamController?.close();
    _reconnectTimer?.cancel();
  }
}