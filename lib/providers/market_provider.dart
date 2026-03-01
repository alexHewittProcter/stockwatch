import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockwatch/models/stock.dart';
import 'package:stockwatch/services/finnhub_service.dart';
import 'package:stockwatch/services/yahoo_finance_service.dart';
import 'package:stockwatch/services/alpha_vantage_service.dart';

// Providers for services
final finnhubServiceProvider = StateProvider<FinnhubService?>((ref) => null);
final yahooFinanceServiceProvider = Provider((ref) => YahooFinanceService());
final alphaVantageServiceProvider = StateProvider<AlphaVantageService?>((ref) => null);

// Market data provider
final marketDataProvider = StateNotifierProvider<MarketDataNotifier, AsyncValue<MarketData>>(
  (ref) => MarketDataNotifier(ref),
);

// Individual stock provider
final stockQuoteProvider = FutureProvider.family<Stock?, String>((ref, symbol) async {
  final finnhub = ref.read(finnhubServiceProvider);
  final yahoo = ref.read(yahooFinanceServiceProvider);
  
  // Try Finnhub first for US stocks, then fallback to Yahoo
  if (finnhub != null && !symbol.contains('=') && !symbol.contains('.L')) {
    final stock = await finnhub.getQuote(symbol);
    if (stock != null) return stock;
  }
  
  // Use Yahoo Finance for commodities, forex, and international stocks
  return await yahoo.getQuote(symbol);
});

// Real-time price stream provider
final realTimePricesProvider = StreamProvider<Map<String, Stock>>((ref) {
  final finnhub = ref.read(finnhubServiceProvider);
  return finnhub?.priceStream ?? const Stream.empty();
});

// Market status provider
final marketStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final finnhub = ref.read(finnhubServiceProvider);
  final yahoo = ref.read(yahooFinanceServiceProvider);
  
  final status = await finnhub?.getMarketStatus();
  
  return {
    'isOpen': status?['isOpen'] ?? yahoo.isMarketOpen(),
    'marketStatus': status?['marketStatus'] ?? yahoo.getMarketStatus(),
    'lastUpdated': DateTime.now(),
  };
});

// Watchlist provider
final watchlistProvider = StateNotifierProvider<WatchlistNotifier, List<String>>(
  (ref) => WatchlistNotifier(),
);

class MarketDataNotifier extends StateNotifier<AsyncValue<MarketData>> {
  final Ref _ref;
  Timer? _refreshTimer;
  final List<String> _activeSymbols = [];

  MarketDataNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initializeServices();
    _startPeriodicRefresh();
  }

  Future<void> _initializeServices() async {
    // Initialize with empty data first
    state = AsyncValue.data(MarketData(
      stocks: [],
      lastUpdated: DateTime.now(),
      isMarketOpen: false,
      marketStatus: 'INITIALIZING',
    ));
  }

  // Set up API keys and initialize services
  Future<void> initializeWithKeys({
    String? finnhubApiKey,
    String? alphaVantageApiKey,
  }) async {
    if (finnhubApiKey != null) {
      final finnhub = FinnhubService(apiKey: finnhubApiKey);
      await finnhub.connectWebSocket();
      _ref.read(finnhubServiceProvider.notifier).state = finnhub;
    }
    
    if (alphaVantageApiKey != null) {
      _ref.read(alphaVantageServiceProvider.notifier).state = 
          AlphaVantageService(apiKey: alphaVantageApiKey);
    }
    
    // Refresh data after initializing services
    await refreshMarketData();
  }

  // Add symbols to track
  Future<void> addSymbols(List<String> symbols) async {
    _activeSymbols.addAll(symbols.where((s) => !_activeSymbols.contains(s)));
    
    final finnhub = _ref.read(finnhubServiceProvider);
    if (finnhub != null) {
      await finnhub.subscribeToSymbols(_getUSStocks(symbols));
    }
    
    await refreshMarketData();
  }

  // Remove symbols from tracking
  void removeSymbols(List<String> symbols) {
    _activeSymbols.removeWhere((s) => symbols.contains(s));
    
    final finnhub = _ref.read(finnhubServiceProvider);
    if (finnhub != null) {
      finnhub.unsubscribeFromSymbols(_getUSStocks(symbols));
    }
  }

  // Refresh all market data
  Future<void> refreshMarketData() async {
    if (_activeSymbols.isEmpty) return;
    
    state = const AsyncValue.loading();
    
    try {
      final finnhub = _ref.read(finnhubServiceProvider);
      final yahoo = _ref.read(yahooFinanceServiceProvider);
      
      final List<Stock> allStocks = [];
      
      // Get US stocks from Finnhub
      final usStocks = _getUSStocks(_activeSymbols);
      if (usStocks.isNotEmpty && finnhub != null) {
        final finnhubStocks = await finnhub.getMultipleQuotes(usStocks);
        allStocks.addAll(finnhubStocks);
      }
      
      // Get commodities, forex, and international stocks from Yahoo
      final nonUSSymbols = _getNonUSSymbols(_activeSymbols);
      if (nonUSSymbols.isNotEmpty) {
        final yahooStocks = await yahoo.getMultipleQuotes(nonUSSymbols);
        allStocks.addAll(yahooStocks);
      }
      
      // Get market status
      final marketStatus = await _ref.read(marketStatusProvider.future);
      
      state = AsyncValue.data(MarketData(
        stocks: allStocks,
        lastUpdated: DateTime.now(),
        isMarketOpen: marketStatus['isOpen'] ?? false,
        marketStatus: marketStatus['marketStatus'] ?? 'UNKNOWN',
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Start periodic refresh during market hours
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      final currentState = state.valueOrNull;
      if (currentState?.isMarketOpen == true) {
        await refreshMarketData();
      }
    });
  }

  // Get US stock symbols (for Finnhub)
  List<String> _getUSStocks(List<String> symbols) {
    return symbols.where((symbol) =>
        !symbol.contains('=') &&     // Not commodity/forex
        !symbol.contains('.L') &&    // Not London exchange
        !symbol.startsWith('^')      // Not index
    ).toList();
  }

  // Get non-US symbols (for Yahoo Finance)
  List<String> _getNonUSSymbols(List<String> symbols) {
    return symbols.where((symbol) =>
        symbol.contains('=') ||      // Commodity/forex
        symbol.contains('.L') ||     // London exchange
        symbol.startsWith('^')       // Index
    ).toList();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    final finnhub = _ref.read(finnhubServiceProvider);
    finnhub?.dispose();
    super.dispose();
  }
}

class WatchlistNotifier extends StateNotifier<List<String>> {
  WatchlistNotifier() : super(_defaultWatchlist);

  static const List<String> _defaultWatchlist = [
    'AAPL', 'GOOGL', 'MSFT', 'NVDA', 'TSLA',
    'SPY', 'QQQ', 'IWM',
    'GC=F', 'CL=F',
    'BTC-USD', 'ETH-USD',
  ];

  void addSymbol(String symbol) {
    if (!state.contains(symbol)) {
      state = [...state, symbol];
    }
  }

  void removeSymbol(String symbol) {
    state = state.where((s) => s != symbol).toList();
  }

  void reorderSymbols(int oldIndex, int newIndex) {
    final items = List<String>.from(state);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    state = items;
  }

  void clearAll() {
    state = [];
  }

  void resetToDefault() {
    state = List.from(_defaultWatchlist);
  }
}