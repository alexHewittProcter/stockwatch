class NewsArticle {
  final String id;
  final String url;
  final String title;
  final String content;
  final String contentSnippet;
  final DateTime publishedAt;
  final String source;
  final String sourceName;
  final List<TickerMention> tickers;
  final SentimentData sentiment;
  final String? author;
  final String? imageUrl;
  final String? category;

  NewsArticle({
    required this.id,
    required this.url,
    required this.title,
    required this.content,
    required this.contentSnippet,
    required this.publishedAt,
    required this.source,
    required this.sourceName,
    required this.tickers,
    required this.sentiment,
    this.author,
    this.imageUrl,
    this.category,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      contentSnippet: json['contentSnippet'] ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      source: json['source'] ?? '',
      sourceName: json['sourceName'] ?? '',
      tickers: (json['tickers'] as List<dynamic>?)
              ?.map((item) => TickerMention.fromJson(item))
              .toList() ??
          [],
      sentiment: SentimentData.fromJson(json['sentiment'] ?? {}),
      author: json['author'],
      imageUrl: json['imageUrl'],
      category: json['category'],
    );
  }
}

class TickerMention {
  final String ticker;
  final double confidence;
  final int mentionCount;
  final List<int> positions;

  TickerMention({
    required this.ticker,
    required this.confidence,
    required this.mentionCount,
    required this.positions,
  });

  factory TickerMention.fromJson(Map<String, dynamic> json) {
    return TickerMention(
      ticker: json['ticker'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      mentionCount: json['mentionCount'] ?? 0,
      positions: (json['positions'] as List<dynamic>?)
              ?.map((item) => item as int)
              .toList() ??
          [],
    );
  }
}

class SentimentData {
  final double score;
  final double confidence;
  final String label;
  final SentimentBreakdown breakdown;

  SentimentData({
    required this.score,
    required this.confidence,
    required this.label,
    required this.breakdown,
  });

  factory SentimentData.fromJson(Map<String, dynamic> json) {
    return SentimentData(
      score: (json['score'] ?? 0).toDouble(),
      confidence: (json['confidence'] ?? 0).toDouble(),
      label: json['label'] ?? 'neutral',
      breakdown: SentimentBreakdown.fromJson(json['breakdown'] ?? {}),
    );
  }

  bool get isBullish => label == 'bullish';
  bool get isBearish => label == 'bearish';
  bool get isNeutral => label == 'neutral';
}

class SentimentBreakdown {
  final double positive;
  final double negative;
  final double neutral;

  SentimentBreakdown({
    required this.positive,
    required this.negative,
    required this.neutral,
  });

  factory SentimentBreakdown.fromJson(Map<String, dynamic> json) {
    return SentimentBreakdown(
      positive: (json['positive'] ?? 0).toDouble(),
      negative: (json['negative'] ?? 0).toDouble(),
      neutral: (json['neutral'] ?? 0).toDouble(),
    );
  }
}

class NewsSource {
  final String id;
  final String name;
  final String url;
  final bool enabled;
  final DateTime? lastChecked;
  final int articleCount;

  NewsSource({
    required this.id,
    required this.name,
    required this.url,
    required this.enabled,
    this.lastChecked,
    required this.articleCount,
  });

  factory NewsSource.fromJson(Map<String, dynamic> json) {
    return NewsSource(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      enabled: json['enabled'] ?? false,
      lastChecked: json['lastChecked'] != null 
          ? DateTime.tryParse(json['lastChecked']) 
          : null,
      articleCount: json['articleCount'] ?? 0,
    );
  }
}

class SocialPost {
  final String id;
  final String platform;
  final String source;
  final String title;
  final String content;
  final String author;
  final int score;
  final int commentCount;
  final DateTime publishedAt;
  final String url;
  final List<TickerMention> tickers;
  final SentimentData sentiment;
  final bool isFiltered;

  SocialPost({
    required this.id,
    required this.platform,
    required this.source,
    required this.title,
    required this.content,
    required this.author,
    required this.score,
    required this.commentCount,
    required this.publishedAt,
    required this.url,
    required this.tickers,
    required this.sentiment,
    required this.isFiltered,
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'] ?? '',
      platform: json['platform'] ?? '',
      source: json['source'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? '',
      score: json['score'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      url: json['url'] ?? '',
      tickers: (json['tickers'] as List<dynamic>?)
              ?.map((item) => TickerMention.fromJson(item))
              .toList() ??
          [],
      sentiment: SentimentData.fromJson(json['sentiment'] ?? {}),
      isFiltered: json['isFiltered'] ?? false,
    );
  }
}

class TrendingTicker {
  final String ticker;
  final int mentions;
  final int mentionsChange;
  final double mentionsChangePercent;
  final double sentiment;
  final Map<String, int> sources;
  final double trendingScore;

  TrendingTicker({
    required this.ticker,
    required this.mentions,
    required this.mentionsChange,
    required this.mentionsChangePercent,
    required this.sentiment,
    required this.sources,
    required this.trendingScore,
  });

  factory TrendingTicker.fromJson(Map<String, dynamic> json) {
    return TrendingTicker(
      ticker: json['ticker'] ?? '',
      mentions: json['mentions'] ?? 0,
      mentionsChange: json['mentionsChange'] ?? 0,
      mentionsChangePercent: (json['mentionsChangePercent'] ?? 0).toDouble(),
      sentiment: (json['sentiment'] ?? 0).toDouble(),
      sources: Map<String, int>.from(json['sources'] ?? {}),
      trendingScore: (json['trendingScore'] ?? 0).toDouble(),
    );
  }
}

class HypeAlert {
  final String ticker;
  final int mentions;
  final int baseline;
  final double multiplier;
  final double confidence;
  final List<String> platforms;
  final DateTime detectedAt;

  HypeAlert({
    required this.ticker,
    required this.mentions,
    required this.baseline,
    required this.multiplier,
    required this.confidence,
    required this.platforms,
    required this.detectedAt,
  });

  factory HypeAlert.fromJson(Map<String, dynamic> json) {
    return HypeAlert(
      ticker: json['ticker'] ?? '',
      mentions: json['mentions'] ?? 0,
      baseline: json['baseline'] ?? 0,
      multiplier: (json['multiplier'] ?? 0).toDouble(),
      confidence: (json['confidence'] ?? 0).toDouble(),
      platforms: (json['platforms'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      detectedAt: DateTime.tryParse(json['detectedAt'] ?? '') ?? DateTime.now(),
    );
  }
}