import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../theme/app_theme.dart';
import '../services/api_client.dart';

class SearchResult {
  final String id;
  final String title;
  final String? subtitle;
  final String type;
  final Map<String, dynamic> data;
  final double relevance;
  final List<SearchAction>? quickActions;

  SearchResult({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    required this.data,
    required this.relevance,
    this.quickActions,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      type: json['type'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      relevance: (json['relevance'] ?? 0).toDouble(),
      quickActions: (json['quickActions'] as List<dynamic>?)
          ?.map((item) => SearchAction.fromJson(item))
          .toList(),
    );
  }

  IconData get typeIcon {
    switch (type) {
      case 'symbol':
        return Icons.trending_up;
      case 'holder':
        return Icons.business;
      case 'dashboard':
        return Icons.dashboard;
      case 'report':
        return Icons.description;
      case 'condition':
        return Icons.rule;
      case 'pattern':
        return Icons.psychology;
      default:
        return Icons.search;
    }
  }

  Color get typeColor {
    switch (type) {
      case 'symbol':
        return AppColors.primary;
      case 'holder':
        return AppColors.success;
      case 'dashboard':
        return AppColors.warning;
      case 'report':
        return Colors.orange;
      case 'condition':
        return Colors.purple;
      case 'pattern':
        return Colors.teal;
      default:
        return AppColors.textMuted;
    }
  }
}

class SearchAction {
  final String label;
  final String action;
  final Map<String, dynamic>? params;

  SearchAction({
    required this.label,
    required this.action,
    this.params,
  });

  factory SearchAction.fromJson(Map<String, dynamic> json) {
    return SearchAction(
      label: json['label'] ?? '',
      action: json['action'] ?? '',
      params: json['params'] != null ? Map<String, dynamic>.from(json['params']) : null,
    );
  }
}

class GlobalSearchOverlay extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const GlobalSearchOverlay({super.key, this.onClose});

  @override
  ConsumerState<GlobalSearchOverlay> createState() => _GlobalSearchOverlayState();
}

class _GlobalSearchOverlayState extends ConsumerState<GlobalSearchOverlay>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _debounceTimer;
  List<SearchResult> _results = [];
  List<SearchResult> _recentResults = [];
  bool _isLoading = false;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
      _loadRecentSearches();
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _animationController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _results = [];
          _selectedIndex = -1;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.globalSearch(query: query, limit: 10);
      
      final results = (response['results'] as List<dynamic>?)
          ?.map((item) => SearchResult.fromJson(item))
          .toList() ?? [];

      setState(() {
        _results = results;
        _selectedIndex = results.isNotEmpty ? 0 : -1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _results = [];
        _selectedIndex = -1;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecentSearches() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.getRecentSearches(limit: 5);
      
      final results = (response['results'] as List<dynamic>?)
          ?.map((item) => SearchResult.fromJson(item))
          .toList() ?? [];

      setState(() {
        _recentResults = results;
      });
    } catch (e) {
      // Silently fail for recent searches
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final currentResults = _results.isNotEmpty ? _results : _recentResults;
      
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
          setState(() {
            _selectedIndex = (_selectedIndex + 1) % currentResults.length;
          });
          break;
          
        case LogicalKeyboardKey.arrowUp:
          setState(() {
            _selectedIndex = _selectedIndex <= 0 
                ? currentResults.length - 1 
                : _selectedIndex - 1;
          });
          break;
          
        case LogicalKeyboardKey.enter:
          if (_selectedIndex >= 0 && _selectedIndex < currentResults.length) {
            _selectResult(currentResults[_selectedIndex]);
          }
          break;
          
        case LogicalKeyboardKey.escape:
          _close();
          break;
      }
    }
  }

  void _selectResult(SearchResult result) {
    // Handle result selection based on type
    switch (result.type) {
      case 'symbol':
        _handleSymbolResult(result);
        break;
      case 'dashboard':
        _handleDashboardResult(result);
        break;
      case 'holder':
        _handleHolderResult(result);
        break;
      case 'report':
        _handleReportResult(result);
        break;
      case 'condition':
        _handleConditionResult(result);
        break;
      case 'pattern':
        _handlePatternResult(result);
        break;
    }
    
    _close();
  }

  void _handleSymbolResult(SearchResult result) {
    final symbol = result.data['symbol'] as String;
    // TODO: Navigate to symbol detail or add to dashboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected symbol: $symbol')),
    );
  }

  void _handleDashboardResult(SearchResult result) {
    final dashboardId = result.data['id'] as String;
    // TODO: Navigate to dashboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening dashboard: ${result.title}')),
    );
  }

  void _handleHolderResult(SearchResult result) {
    // TODO: Navigate to holder detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected holder: ${result.title}')),
    );
  }

  void _handleReportResult(SearchResult result) {
    // TODO: Navigate to report detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening report: ${result.title}')),
    );
  }

  void _handleConditionResult(SearchResult result) {
    // TODO: Navigate to condition detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected condition: ${result.title}')),
    );
  }

  void _handlePatternResult(SearchResult result) {
    // TODO: Navigate to pattern detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected pattern: ${result.title}')),
    );
  }

  void _close() async {
    await _animationController.reverse();
    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _close,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Focus(
          onKeyEvent: (node, event) {
            _handleKeyEvent(event);
            return KeyEventResult.handled;
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: _buildSearchPanel(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchPanel() {
    return GestureDetector(
      onTap: () {}, // Prevent closing when tapping on the panel
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSearchInput(),
            if (_isLoading) _buildLoadingIndicator(),
            if (!_isLoading && _results.isNotEmpty) _buildResults(_results),
            if (!_isLoading && _results.isEmpty && _searchController.text.isEmpty && _recentResults.isNotEmpty)
              _buildRecentSection(),
            if (!_isLoading && _results.isEmpty && _searchController.text.isNotEmpty)
              _buildNoResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                hintText: 'Search symbols, holders, dashboards...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
              ),
              style: AppTextStyles.bodyLarge,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'ESC',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildResults(List<SearchResult> results) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          final isSelected = index == _selectedIndex;
          
          return _buildResultItem(result, isSelected, index);
        },
      ),
    );
  }

  Widget _buildResultItem(SearchResult result, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => _selectResult(result),
      onHover: (hovering) {
        if (hovering) {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: result.typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                result.typeIcon,
                size: 16,
                color: result.typeColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.text,
                    ),
                  ),
                  if (result.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      result.subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            'Recent',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _recentResults.length,
            itemBuilder: (context, index) {
              final result = _recentResults[index];
              final isSelected = index == _selectedIndex;
              
              return _buildResultItem(result, isSelected, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try searching for symbols, holders, or dashboards',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}