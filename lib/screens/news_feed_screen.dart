import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';
import '../models/news_models.dart';

class NewsFeedScreen extends ConsumerStatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  ConsumerState<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends ConsumerState<NewsFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<NewsArticle> _articles = [];
  List<TrendingTicker> _trending = [];
  bool _isLoading = true;
  String? _error;
  String _currentTab = 'foryou';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadNewsFeed();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final tabs = ['foryou', 'trending', 'opportunities', 'social'];
    if (_tabController.index < tabs.length) {
      setState(() {
        _currentTab = tabs[_tabController.index];
      });
      _loadNewsFeed();
    }
  }

  Future<void> _loadNewsFeed() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiClient = ref.read(apiClientProvider);
      
      // Load trending data if on trending tab
      if (_currentTab == 'trending') {
        final trendingResponse = await apiClient.getSocialTrending();
        setState(() {
          _trending = (trendingResponse['trending'] as List<dynamic>?)
                  ?.map((item) => TrendingTicker.fromJson(item))
                  .toList() ??
              [];
        });
      }

      // Load news feed
      final response = await apiClient.getNewsFeed(tab: _currentTab);
      
      setState(() {
        _articles = (response['articles'] as List<dynamic>?)
                ?.map((item) => NewsArticle.fromJson(item))
                .toList() ??
            [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : RefreshIndicator(
                        onRefresh: _loadNewsFeed,
                        child: _buildContent(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Market News & Social Intel',
                  style: AppTextStyles.headingLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay informed with real-time news and social sentiment',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (_trending.isNotEmpty && _currentTab == 'trending')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warning, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_trending.length} Trending',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicator: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'For You'),
          Tab(text: 'Trending'),
          Tab(text: 'Opportunities'),
          Tab(text: 'Social Pulse'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_currentTab == 'trending' && _trending.isNotEmpty) {
      return Column(
        children: [
          _buildTrendingSection(),
          const SizedBox(height: 16),
          Expanded(child: _buildArticlesList()),
        ],
      );
    }

    return _buildArticlesList();
  }

  Widget _buildTrendingSection() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending Tickers',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _trending.length,
              itemBuilder: (context, index) {
                final ticker = _trending[index];
                return _buildTrendingTickerCard(ticker);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingTickerCard(TrendingTicker ticker) {
    final isPositive = ticker.sentiment > 0;
    final sentimentColor = isPositive ? AppColors.success : AppColors.error;

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ticker.ticker,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(
            '${ticker.mentions} mentions',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: sentimentColor,
              ),
              const SizedBox(width: 4),
              Text(
                ticker.sentiment.toStringAsFixed(2),
                style: AppTextStyles.bodySmall.copyWith(
                  color: sentimentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesList() {
    if (_articles.isEmpty) {
      return Center(
        child: Text(
          'No articles available',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _articles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final article = _articles[index];
        return _buildArticleCard(article);
      },
    );
  }

  Widget _buildArticleCard(NewsArticle article) {
    return InkWell(
      onTap: () => _openArticle(article),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildArticleHeader(article),
            const SizedBox(height: 12),
            Text(
              article.title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (article.contentSnippet.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                article.contentSnippet,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            _buildArticleFooter(article),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleHeader(NewsArticle article) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            article.sourceName,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildSentimentBadge(article.sentiment),
        const Spacer(),
        Text(
          _formatTimeAgo(article.publishedAt),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSentimentBadge(SentimentData sentiment) {
    Color color;
    String emoji;
    
    if (sentiment.isBullish) {
      color = AppColors.success;
      emoji = '📈';
    } else if (sentiment.isBearish) {
      color = AppColors.error;
      emoji = '📉';
    } else {
      color = AppColors.textMuted;
      emoji = '➖';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 2),
          Text(
            sentiment.label.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleFooter(NewsArticle article) {
    return Row(
      children: [
        if (article.tickers.isNotEmpty) ...[
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: article.tickers.take(3).map((ticker) => 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Text(
                    ticker.ticker,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
        ] else ...[
          const Spacer(),
        ],
        Icon(
          Icons.open_in_new,
          size: 16,
          color: AppColors.textMuted,
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load news feed',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNewsFeed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _openArticle(NewsArticle article) async {
    try {
      final uri = Uri.parse(article.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open article: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}