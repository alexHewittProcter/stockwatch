import 'package:dio/dio.dart';

class AlphaVantageService {
  static const String _baseUrl = 'https://www.alphavantage.co/query';
  
  final Dio _dio;
  final String _apiKey;

  AlphaVantageService({required String apiKey}) : 
    _apiKey = apiKey,
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

  // Get economic indicators
  Future<Map<String, dynamic>?> getEconomicIndicator(String function) async {
    try {
      final response = await _dio.get('', queryParameters: {
        'function': function,
        'apikey': _apiKey,
      });
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print('AlphaVantageService: Error fetching $function: $e');
    }
    return null;
  }

  // Get news sentiment
  Future<Map<String, dynamic>?> getNewsSentiment({
    List<String>? tickers,
    String? topics,
    String? timeFrom,
    String? timeTo,
    int limit = 50,
  }) async {
    try {
      final queryParams = {
        'function': 'NEWS_SENTIMENT',
        'apikey': _apiKey,
        'limit': limit.toString(),
      };
      
      if (tickers != null && tickers.isNotEmpty) {
        queryParams['tickers'] = tickers.join(',');
      }
      if (topics != null) queryParams['topics'] = topics;
      if (timeFrom != null) queryParams['time_from'] = timeFrom;
      if (timeTo != null) queryParams['time_to'] = timeTo;
      
      final response = await _dio.get('', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print('AlphaVantageService: Error fetching news sentiment: $e');
    }
    return null;
  }

  // Get top gainers and losers
  Future<Map<String, dynamic>?> getTopGainersLosers() async {
    try {
      final response = await _dio.get('', queryParameters: {
        'function': 'TOP_GAINERS_LOSERS',
        'apikey': _apiKey,
      });
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print('AlphaVantageService: Error fetching top gainers/losers: $e');
    }
    return null;
  }

  void dispose() {
    _dio.close();
  }
}