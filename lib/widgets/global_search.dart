import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';

class GlobalSearchOverlay extends ConsumerStatefulWidget {
  const GlobalSearchOverlay({super.key});

  @override
  ConsumerState<GlobalSearchOverlay> createState() => _GlobalSearchOverlayState();
}

class _GlobalSearchOverlayState extends ConsumerState<GlobalSearchOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
    
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _closeSearch() {
    _animationController.reverse().then((_) {
      ref.read(isSearchActiveProvider.notifier).state = false;
      ref.read(searchQueryProvider.notifier).state = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);

    return GestureDetector(
      onTap: _closeSearch,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Container(
            color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
            child: Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _SearchDialog(
                    searchController: _searchController,
                    focusNode: _focusNode,
                    onClose: _closeSearch,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchDialog extends ConsumerStatefulWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final VoidCallback onClose;

  const _SearchDialog({
    required this.searchController,
    required this.focusNode,
    required this.onClose,
  });

  @override
  ConsumerState<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends ConsumerState<_SearchDialog> {
  List<SearchResult> _results = [];
  bool _isLoading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    final query = widget.searchController.text;
    ref.read(searchQueryProvider.notifier).state = query;
    
    if (query.isNotEmpty) {
      _performSearch(query);
    } else {
      setState(() {
        _results = [];
        _selectedIndex = 0;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Search symbols
      final apiClient = ref.read(apiClientProvider);
      final symbolResults = await apiClient.searchSymbols(query);
      
      // Create search results
      final results = <SearchResult>[];
      
      // Add symbol results
      for (final symbol in symbolResults.take(8)) {
        results.add(SearchResult(
          type: SearchResultType.symbol,
          title: symbol['symbol'] ?? '',
          subtitle: symbol['description'] ?? '',
          data: symbol,
          icon: Icons.trending_up,
        ));
      }
      
      // Add quick navigation results
      final navigationResults = _getNavigationResults(query);
      results.addAll(navigationResults.take(5));
      
      setState(() {
        _results = results;
        _selectedIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Search error: $e');
    }
  }

  List<SearchResult> _getNavigationResults(String query) {
    final navigation = [
      {'title': 'Home', 'page': 0, 'icon': Icons.home},
      {'title': 'Dashboard', 'page': 1, 'icon': Icons.dashboard},
      {'title': 'Portfolio', 'page': 9, 'icon': Icons.pie_chart},
      {'title': 'Options', 'page': 5, 'icon': Icons.swap_horiz},
      {'title': 'News', 'page': 6, 'icon': Icons.article},
      {'title': 'Opportunities', 'page': 7, 'icon': Icons.lightbulb},
      {'title': 'Holders', 'page': 3, 'icon': Icons.groups},
      {'title': 'Reports', 'page': 8, 'icon': Icons.description},
      {'title': 'Trade Journal', 'page': 10, 'icon': Icons.book},
      {'title': 'Alerts', 'page': 11, 'icon': Icons.notifications},
      {'title': 'Settings', 'page': 12, 'icon': Icons.settings},
    ];
    
    return navigation
        .where((nav) => nav['title']!.toString().toLowerCase().contains(query.toLowerCase()))
        .map((nav) => SearchResult(
              type: SearchResultType.navigation,
              title: nav['title']! as String,
              subtitle: 'Navigate to ${nav['title']}',
              data: nav,
              icon: nav['icon']! as IconData,
            ))
        .toList();
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % _results.length;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selectedIndex = (_selectedIndex - 1) % _results.length;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        _selectResult(_results[_selectedIndex]);
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.onClose();
      }
    }
  }

  void _selectResult(SearchResult result) {
    switch (result.type) {
      case SearchResultType.symbol:
        // Navigate to stock detail and set selected symbol
        ref.read(selectedSymbolProvider.notifier).state = result.title;
        ref.read(currentPageProvider.notifier).state = 2; // Stock detail page
        break;
      case SearchResultType.navigation:
        final page = result.data['page'] as int;
        ref.read(currentPageProvider.notifier).state = page;
        break;
    }
    
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // Prevent closing when tapping the dialog
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: _handleKeyPress,
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.textMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: widget.searchController,
                        focusNode: widget.focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Search symbols, news, or navigate...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: AppTextStyles.bodyLarge,
                      ),
                    ),
                    if (_isLoading) ...[
                      const SizedBox(width: 12),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ],
                    const SizedBox(width: 12),
                    Text(
                      'ESC',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search results
              if (_results.isNotEmpty) ...[
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      final isSelected = index == _selectedIndex;
                      
                      return _SearchResultItem(
                        result: result,
                        isSelected: isSelected,
                        onTap: () => _selectResult(result),
                      );
                    },
                  ),
                ),
              ] else if (widget.searchController.text.isNotEmpty && !_isLoading) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No results found',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Search for stocks, news, or navigate to any screen',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '↑↓ to navigate • Enter to select • Esc to close',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final SearchResult result;
  final bool isSelected;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.result,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.selectionBackground : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  result.icon,
                  size: 18,
                  color: _getIconColor(),
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (result.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        result.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (result.type == SearchResultType.symbol) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'STOCK',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getIconBackgroundColor() {
    switch (result.type) {
      case SearchResultType.symbol:
        return AppColors.info.withOpacity(0.2);
      case SearchResultType.navigation:
        return AppColors.surfaceVariant;
    }
  }

  Color _getIconColor() {
    switch (result.type) {
      case SearchResultType.symbol:
        return AppColors.info;
      case SearchResultType.navigation:
        return AppColors.textSecondary;
    }
  }
}

enum SearchResultType {
  symbol,
  navigation,
}

class SearchResult {
  final SearchResultType type;
  final String title;
  final String subtitle;
  final Map<String, dynamic> data;
  final IconData icon;

  SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.data,
    required this.icon,
  });
}