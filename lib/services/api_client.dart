import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Models for API responses
class Quote {
  final String symbol;
  final double price;
  final double change;
  final double changePercent;
  final double volume;
  final DateTime timestamp;

  Quote({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.timestamp,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      symbol: json['symbol'],
      price: json['price']?.toDouble() ?? 0.0,
      change: json['change']?.toDouble() ?? 0.0,
      changePercent: json['changePercent']?.toDouble() ?? 0.0,
      volume: json['volume']?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }
}

class Candle {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory Candle.fromJson(Map<String, dynamic> json) {
    return Candle(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      open: json['open']?.toDouble() ?? 0.0,
      high: json['high']?.toDouble() ?? 0.0,
      low: json['low']?.toDouble() ?? 0.0,
      close: json['close']?.toDouble() ?? 0.0,
      volume: json['volume']?.toDouble() ?? 0.0,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
  
  @override
  String toString() => 'ApiException: $message';
}

class ApiClient {
  late Dio _dio;
  WebSocketChannel? _wsChannel;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  final StreamController<Quote> _priceStreamController = StreamController<Quote>.broadcast();
  final Set<String> _subscribedSymbols = {};
  bool _isConnecting = false;
  
  String _baseUrl = 'http://localhost:3002';
  
  // Getters
  Stream<Quote> get priceStream => _priceStreamController.stream;
  bool get isConnected => _wsChannel != null;
  
  ApiClient() {
    _initDio();
    _loadSettings();
  }
  
  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ));
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[API] $obj'),
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        print('[API Error] ${error.message}');
        return handler.next(error);
      },
    ));
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('api_base_url');
    if (savedUrl != null) {
      _baseUrl = savedUrl;
      _dio.options.baseUrl = _baseUrl;
    }
  }
  
  Future<void> updateBaseUrl(String url) async {
    _baseUrl = url;
    _dio.options.baseUrl = url;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
    
    // Reconnect WebSocket with new URL
    if (_wsChannel != null) {
      _disconnect();
      await _connectWebSocket();
    }
  }
  
  // HTTP API Methods
  Future<T> _request<T>(
    String method,
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    T Function(dynamic)? parser,
  }) async {
    try {
      Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(path, queryParameters: queryParameters);
          break;
        case 'POST':
          response = await _dio.post(path, data: data, queryParameters: queryParameters);
          break;
        case 'PUT':
          response = await _dio.put(path, data: data, queryParameters: queryParameters);
          break;
        case 'DELETE':
          response = await _dio.delete(path, queryParameters: queryParameters);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
      
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return parser != null ? parser(response.data) : response.data as T;
      } else {
        throw ApiException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    }
  }
  
  // Market Data API
  Future<Quote> getQuote(String symbol) async {
    return await _request<Quote>(
      'GET',
      '/api/market/quote/$symbol',
      parser: (data) => Quote.fromJson(data),
    );
  }
  
  Future<List<Candle>> getCandles(
    String symbol, {
    String interval = '5m',
    DateTime? from,
    DateTime? to,
  }) async {
    final queryParams = <String, dynamic>{
      'interval': interval,
      if (from != null) 'from': from.millisecondsSinceEpoch,
      if (to != null) 'to': to.millisecondsSinceEpoch,
    };
    
    return await _request<List<Candle>>(
      'GET',
      '/api/market/candles/$symbol',
      queryParameters: queryParams,
      parser: (data) => (data as List).map((item) => Candle.fromJson(item)).toList(),
    );
  }
  
  Future<List<dynamic>> searchSymbols(String query) async {
    return await _request<List<dynamic>>(
      'GET',
      '/api/market/search',
      queryParameters: {'q': query},
      parser: (data) => data as List<dynamic>,
    );
  }
  
  Future<List<dynamic>> getTopMovers() async {
    return await _request<List<dynamic>>(
      'GET',
      '/api/market/movers',
      parser: (data) => data as List<dynamic>,
    );
  }
  
  // Dashboard API
  Future<List<dynamic>> getDashboards() async {
    return await _request<List<dynamic>>(
      'GET',
      '/api/dashboards',
      parser: (data) => data as List<dynamic>,
    );
  }
  
  Future<List<dynamic>> getDefaultDashboards() async {
    return await _request<List<dynamic>>(
      'GET',
      '/api/dashboards/defaults',
      parser: (data) => data as List<dynamic>,
    );
  }
  
  Future<dynamic> createDashboard(Map<String, dynamic> dashboard) async {
    return await _request<dynamic>(
      'POST',
      '/api/dashboards',
      data: dashboard,
    );
  }
  
  Future<dynamic> updateDashboard(String id, Map<String, dynamic> dashboard) async {
    return await _request<dynamic>(
      'PUT',
      '/api/dashboards/$id',
      data: dashboard,
    );
  }
  
  Future<void> deleteDashboard(String id) async {
    await _request<void>('DELETE', '/api/dashboards/$id');
  }
  
  // Portfolio API
  Future<List<dynamic>> getPositions() async {
    return await _request<List<dynamic>>(
      'GET',
      '/api/portfolio/positions',
      parser: (data) => data as List<dynamic>,
    );
  }
  
  Future<dynamic> placeOrder(Map<String, dynamic> order) async {
    return await _request<dynamic>(
      'POST',
      '/api/portfolio/order',
      data: order,
    );
  }
  
  // News API
  Future<List<dynamic>> getNewsFeed({String tab = 'foryou'}) async {
    return await _request<List<dynamic>>(
      'GET',
      '/api/news/feed',
      queryParameters: {'tab': tab},
      parser: (data) => data as List<dynamic>,
    );
  }
  
  // Holders API
  Future<dynamic> getHolders(String symbol) async {
    return await _request<dynamic>(
      'GET',
      '/api/holders/$symbol',
    );
  }
  
  Future<dynamic> getInstitutionPortfolio(String cik) async {
    return await _request<dynamic>(
      'GET',
      '/api/holders/institution/$cik',
    );
  }
  
  Future<dynamic> getInsiderTransactions(String symbol, {int days = 90}) async {
    return await _request<dynamic>(
      'GET',
      '/api/holders/insider/$symbol',
      queryParameters: {'days': days.toString()},
    );
  }
  
  Future<List<dynamic>> getTrackedHolders() async {
    return await _request<List<dynamic>>(
      'GET',
      '/api/holders/tracked',
      parser: (data) => data as List<dynamic>,
    );
  }
  
  Future<dynamic> trackHolder(String name, {String? cik}) async {
    return await _request<dynamic>(
      'POST',
      '/api/holders/track',
      data: {'name': name, if (cik != null) 'cik': cik},
    );
  }
  
  Future<void> untrackHolder(String cik) async {
    await _request<void>('DELETE', '/api/holders/track/$cik');
  }
  
  Future<dynamic> getHolderChanges({String? quarter, int limit = 50}) async {
    final params = <String, String>{
      'limit': limit.toString(),
      if (quarter != null) 'quarter': quarter,
    };
    
    return await _request<dynamic>(
      'GET',
      '/api/holders/changes',
      queryParameters: params,
    );
  }
  
  Future<dynamic> getHolderChangesById(String cik, {int quarters = 4}) async {
    return await _request<dynamic>(
      'GET',
      '/api/holders/changes/$cik',
      queryParameters: {'quarters': quarters.toString()},
    );
  }
  
  Future<dynamic> getSmartMoneySignals({String? quarter}) async {
    final params = quarter != null ? {'quarter': quarter} : <String, String>{};
    
    return await _request<dynamic>(
      'GET',
      '/api/holders/signals',
      queryParameters: params,
    );
  }
  
  // Options API
  Future<dynamic> getOptionsChain(String symbol, {String? expiry, String? type}) async {
    final params = <String, String>{};
    if (expiry != null) params['expiry'] = expiry;
    if (type != null) params['type'] = type;
    
    return await _request<dynamic>(
      'GET',
      '/api/options/chain/$symbol',
      queryParameters: params,
    );
  }

  Future<dynamic> getOptionsExpirations(String symbol) async {
    return await _request<dynamic>(
      'GET',
      '/api/options/expirations/$symbol',
    );
  }

  Future<dynamic> getIVData(String symbol) async {
    return await _request<dynamic>(
      'GET',
      '/api/options/iv/$symbol',
    );
  }

  Future<dynamic> getIVHistory(String symbol) async {
    return await _request<dynamic>(
      'GET',
      '/api/options/iv/history/$symbol',
    );
  }

  Future<dynamic> getPutCallRatio(String symbol) async {
    return await _request<dynamic>(
      'GET',
      '/api/options/pcr/$symbol',
    );
  }

  Future<dynamic> getOptionsFlow({int minValue = 0, String? type, int limit = 50}) async {
    final params = <String, String>{
      'minValue': minValue.toString(),
      'limit': limit.toString(),
    };
    if (type != null) params['type'] = type;

    return await _request<dynamic>(
      'GET',
      '/api/options/flow',
      queryParameters: params,
    );
  }

  Future<dynamic> getSymbolOptionsFlow(String symbol, {int limit = 20}) async {
    return await _request<dynamic>(
      'GET',
      '/api/options/flow/$symbol',
      queryParameters: {'limit': limit.toString()},
    );
  }

  Future<dynamic> getVolatilityDashboard() async {
    return await _request<dynamic>(
      'GET',
      '/api/options/volatility/dashboard',
    );
  }

  Future<dynamic> getMarketPCR() async {
    return await _request<dynamic>(
      'GET',
      '/api/options/pcr/market',
    );
  }

  Future<dynamic> getExtremeRatios() async {
    return await _request<dynamic>(
      'GET',
      '/api/options/extremes',
    );
  }

  Future<dynamic> getReversalSignals() async {
    return await _request<dynamic>(
      'GET',
      '/api/options/reversals',
    );
  }

  // News API
  Future<dynamic> getNewsFeed({
    String tab = 'foryou',
    List<String>? symbols,
    List<String>? sources, 
    String? sentiment,
    int limit = 50,
    int offset = 0,
  }) async {
    final params = <String, String>{
      'tab': tab,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    
    if (symbols != null && symbols.isNotEmpty) {
      params['symbols'] = symbols.join(',');
    }
    if (sources != null && sources.isNotEmpty) {
      params['sources'] = sources.join(',');
    }
    if (sentiment != null) {
      params['sentiment'] = sentiment;
    }

    return await _request<dynamic>(
      'GET',
      '/api/news/feed',
      queryParameters: params,
    );
  }

  Future<dynamic> getNewsArticle(String id) async {
    return await _request<dynamic>(
      'GET',
      '/api/news/article/$id',
    );
  }

  Future<dynamic> getNewsSources() async {
    return await _request<dynamic>(
      'GET',
      '/api/news/sources',
    );
  }

  // Social API
  Future<dynamic> getSocialTrending({String period = '24h'}) async {
    return await _request<dynamic>(
      'GET',
      '/api/social/trending',
      queryParameters: {'period': period},
    );
  }

  Future<dynamic> getSocialSentiment(String symbol, {String period = '24h'}) async {
    return await _request<dynamic>(
      'GET',
      '/api/social/sentiment/$symbol',
      queryParameters: {'period': period},
    );
  }

  Future<dynamic> getRedditHotPosts({int limit = 100}) async {
    return await _request<dynamic>(
      'GET',
      '/api/social/reddit/hot',
      queryParameters: {'limit': limit.toString()},
    );
  }

  Future<dynamic> getSubredditPosts(String subreddit, {int limit = 50}) async {
    return await _request<dynamic>(
      'GET',
      '/api/social/reddit/$subreddit',
      queryParameters: {'limit': limit.toString()},
    );
  }

  Future<dynamic> getHypeAlerts({int hours = 24}) async {
    return await _request<dynamic>(
      'GET',
      '/api/social/hype',
      queryParameters: {'hours': hours.toString()},
    );
  }

  // Opportunities API
  Future<dynamic> getOpportunities({
    String? direction,
    int? confidence,
    String? timeframe,
    int limit = 20,
    int offset = 0,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    
    if (direction != null) params['direction'] = direction;
    if (confidence != null) params['confidence'] = confidence.toString();
    if (timeframe != null) params['timeframe'] = timeframe;

    return await _request<dynamic>(
      'GET',
      '/api/opportunities',
      queryParameters: params,
    );
  }

  Future<dynamic> getOpportunity(String id) async {
    return await _request<dynamic>(
      'GET',
      '/api/opportunities/$id',
    );
  }

  Future<dynamic> updateOpportunityStatus(String id, String status, {Map<String, dynamic>? outcome}) async {
    final data = {'status': status};
    if (outcome != null) data['outcome'] = outcome;
    
    return await _request<dynamic>(
      'PUT',
      '/api/opportunities/$id/status',
      data: data,
    );
  }

  Future<dynamic> generateOpportunities() async {
    return await _request<dynamic>(
      'POST',
      '/api/opportunities/generate',
    );
  }

  Future<dynamic> getRecentSignals({int hours = 24, int limit = 100}) async {
    return await _request<dynamic>(
      'GET',
      '/api/opportunities/signals/recent',
      queryParameters: {
        'hours': hours.toString(),
        'limit': limit.toString(),
      },
    );
  }

  Future<dynamic> detectSignals({List<String>? symbols}) async {
    return await _request<dynamic>(
      'POST',
      '/api/opportunities/signals/detect',
      data: {'symbols': symbols},
    );
  }

  // Conditions API
  Future<dynamic> getConditions() async {
    return await _request<dynamic>(
      'GET',
      '/api/opportunities/conditions',
    );
  }

  Future<dynamic> getCondition(String id) async {
    return await _request<dynamic>(
      'GET',
      '/api/opportunities/conditions/$id',
    );
  }

  Future<dynamic> createCondition({
    required String name,
    String? description,
    required List<Map<String, dynamic>> rules,
    required String logic,
    List<String>? symbols,
    bool notifyOnTrigger = true,
  }) async {
    return await _request<dynamic>(
      'POST',
      '/api/opportunities/conditions',
      data: {
        'name': name,
        'description': description,
        'rules': rules,
        'logic': logic,
        'symbols': symbols,
        'notifyOnTrigger': notifyOnTrigger,
      },
    );
  }

  Future<dynamic> updateCondition(String id, Map<String, dynamic> updates) async {
    return await _request<dynamic>(
      'PUT',
      '/api/opportunities/conditions/$id',
      data: updates,
    );
  }

  Future<dynamic> deleteCondition(String id) async {
    return await _request<dynamic>(
      'DELETE',
      '/api/opportunities/conditions/$id',
    );
  }

  Future<dynamic> evaluateConditions() async {
    return await _request<dynamic>(
      'POST',
      '/api/opportunities/conditions/evaluate',
    );
  }

  Future<dynamic> backtestCondition(String id, String fromDate, String toDate) async {
    return await _request<dynamic>(
      'POST',
      '/api/opportunities/conditions/$id/backtest',
      data: {
        'fromDate': fromDate,
        'toDate': toDate,
      },
    );
  }

  Future<dynamic> getBacktests({String? conditionId}) async {
    final params = <String, String>{};
    if (conditionId != null) params['conditionId'] = conditionId;
    
    return await _request<dynamic>(
      'GET',
      '/api/opportunities/backtests',
      queryParameters: params.isNotEmpty ? params : null,
    );
  }
  
  // Opportunities API
  Future<List<dynamic>> getOpportunities() async {
    return await _request<List<dynamic>>(
      'GET',
      '/api/opportunities',
      parser: (data) => data as List<dynamic>,
    );
  }
  
  // WebSocket Connection Management
  Future<void> connectWebSocket() async {
    await _connectWebSocket();
  }
  
  Future<void> _connectWebSocket() async {
    if (_isConnecting || _wsChannel != null) return;
    
    _isConnecting = true;
    
    try {
      final wsUrl = _baseUrl.replaceFirst('http', 'ws') + '/ws/prices';
      print('[WebSocket] Connecting to $wsUrl');
      
      _wsChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Listen for messages
      _wsChannel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketClosed,
      );
      
      // Start ping timer to keep connection alive
      _startPingTimer();
      
      // Subscribe to existing symbols
      for (final symbol in _subscribedSymbols) {
        _sendSubscription(symbol, true);
      }
      
      print('[WebSocket] Connected successfully');
    } catch (e) {
      print('[WebSocket] Connection failed: $e');
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }
  
  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      
      if (data['type'] == 'quote') {
        final quote = Quote.fromJson(data['data']);
        _priceStreamController.add(quote);
      } else if (data['type'] == 'pong') {
        print('[WebSocket] Received pong');
      }
    } catch (e) {
      print('[WebSocket] Error parsing message: $e');
    }
  }
  
  void _handleWebSocketError(error) {
    print('[WebSocket] Error: $error');
    _disconnect();
    _scheduleReconnect();
  }
  
  void _handleWebSocketClosed() {
    print('[WebSocket] Connection closed');
    _disconnect();
    _scheduleReconnect();
  }
  
  void _disconnect() {
    _wsChannel?.sink.close();
    _wsChannel = null;
    _pingTimer?.cancel();
    _pingTimer = null;
  }
  
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_wsChannel == null && _subscribedSymbols.isNotEmpty) {
        _connectWebSocket();
      }
    });
  }
  
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_wsChannel != null) {
        _sendPing();
      }
    });
  }
  
  void _sendPing() {
    try {
      _wsChannel?.sink.add(jsonEncode({
        'type': 'ping',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));
    } catch (e) {
      print('[WebSocket] Failed to send ping: $e');
    }
  }
  
  void _sendSubscription(String symbol, bool subscribe) {
    try {
      _wsChannel?.sink.add(jsonEncode({
        'type': subscribe ? 'subscribe' : 'unsubscribe',
        'symbol': symbol,
      }));
    } catch (e) {
      print('[WebSocket] Failed to send subscription: $e');
    }
  }
  
  // Symbol subscription management
  void subscribeToSymbol(String symbol) {
    _subscribedSymbols.add(symbol);
    
    if (_wsChannel == null) {
      _connectWebSocket();
    } else {
      _sendSubscription(symbol, true);
    }
  }
  
  void unsubscribeFromSymbol(String symbol) {
    _subscribedSymbols.remove(symbol);
    
    if (_wsChannel != null) {
      _sendSubscription(symbol, false);
    }
    
    // Disconnect if no more subscriptions
    if (_subscribedSymbols.isEmpty) {
      _disconnect();
    }
  }
  
  void updateSubscriptions(List<String> symbols) {
    final currentSymbols = Set<String>.from(_subscribedSymbols);
    final newSymbols = Set<String>.from(symbols);
    
    // Unsubscribe from removed symbols
    for (final symbol in currentSymbols.difference(newSymbols)) {
      unsubscribeFromSymbol(symbol);
    }
    
    // Subscribe to new symbols
    for (final symbol in newSymbols.difference(currentSymbols)) {
      subscribeToSymbol(symbol);
    }
  }
  
  void dispose() {
    _disconnect();
    _reconnectTimer?.cancel();
    _priceStreamController.close();
  }
}

// Riverpod provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  
  ref.onDispose(() {
    client.dispose();
  });
  
  return client;
});