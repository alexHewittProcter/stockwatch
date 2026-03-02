import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Onboarding state
  final _finnhubKeyController = TextEditingController();
  final _alpacaKeyController = TextEditingController();
  List<String> _selectedInterests = [];
  List<String> _selectedDashboards = [];
  bool _enableNotifications = true;
  String _quietHoursStart = '23:00';
  String _quietHoursEnd = '08:00';

  final List<String> _marketInterests = [
    'Technology',
    'Healthcare',
    'Energy',
    'Finance',
    'Consumer',
    'Real Estate',
    'Utilities',
    'Materials',
    'Industrials',
    'Telecommunications',
    'Crypto',
    'Commodities',
  ];

  final List<Map<String, String>> _defaultDashboards = [
    {'name': 'Market Overview', 'description': 'S&P 500, NASDAQ, Dow Jones'},
    {'name': 'Tech Giants', 'description': 'AAPL, GOOGL, MSFT, AMZN'},
    {'name': 'Growth Stocks', 'description': 'High-growth technology stocks'},
    {'name': 'Dividend Champions', 'description': 'High-yield dividend stocks'},
    {'name': 'Crypto Watch', 'description': 'Bitcoin, Ethereum, major alts'},
    {'name': 'Energy Sector', 'description': 'Oil, gas, renewable energy'},
    {'name': 'Healthcare Innovation', 'description': 'Biotech and pharma'},
    {'name': 'Financial Services', 'description': 'Banks, fintech, insurance'},
    {'name': 'ESG Leaders', 'description': 'Sustainable investing'},
    {'name': 'Value Picks', 'description': 'Undervalued opportunities'},
    {'name': 'International', 'description': 'Global and emerging markets'},
    {'name': 'Commodities', 'description': 'Gold, silver, agriculture'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _finnhubKeyController.dispose();
    _alpacaKeyController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    // Save onboarding preferences
    // TODO: Save to preferences service
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildProgressHeader(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildWelcomePage(),
                _buildApiKeysPage(),
                _buildInterestsPage(),
                _buildDashboardsPage(),
                _buildNotificationsPage(),
                _buildPortfolioPage(),
                _buildReadyPage(),
              ],
            ),
          ),
          _buildNavigationFooter(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'StockWatch Setup',
                style: AppTextStyles.headingLarge,
              ),
              const Spacer(),
              Text(
                '${_currentPage + 1} of 7',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentPage + 1) / 7,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to StockWatch',
            style: AppTextStyles.headingLarge.copyWith(
              fontSize: 32,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your AI-Powered Trading Terminal',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Text(
            'Track markets, analyze opportunities, and learn from your trades with advanced AI intelligence.',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Features included:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFeatureItem('🔍 Real-time market data & news'),
                _buildFeatureItem('🧠 AI pattern recognition'),
                _buildFeatureItem('📊 Advanced options analysis'),
                _buildFeatureItem('💼 Institutional holder tracking'),
                _buildFeatureItem('📱 Smart alerts & notifications'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(text, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildApiKeysPage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'API Keys Setup',
            style: AppTextStyles.headingLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Connect your data sources for real-time market information',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 40),
          
          _buildApiKeySection(
            'Finnhub API Key',
            'Free tier includes 60 API calls/minute',
            'https://finnhub.io/register',
            _finnhubKeyController,
            'sk-...',
          ),
          
          const SizedBox(height: 32),
          
          _buildApiKeySection(
            'Alpaca API Key (Optional)',
            'For live trading and portfolio management',
            'https://app.alpaca.markets/signup',
            _alpacaKeyController,
            'PKTEST...',
          ),
          
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'API keys are stored locally and never shared. You can skip this and add them later in settings.',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeySection(String title, String description, String signupUrl, 
      TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: TextButton(
              onPressed: () {
                // TODO: Launch URL
              },
              child: const Text('Get Key'),
            ),
          ),
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildInterestsPage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Interests',
            style: AppTextStyles.headingLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Select sectors you want to follow closely',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _marketInterests.length,
              itemBuilder: (context, index) {
                final interest = _marketInterests[index];
                final isSelected = _selectedInterests.contains(interest);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedInterests.remove(interest);
                      } else {
                        _selectedInterests.add(interest);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        interest,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.text,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardsPage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Starting Dashboards',
            style: AppTextStyles.headingLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose 3-5 dashboards to start with',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              itemCount: _defaultDashboards.length,
              itemBuilder: (context, index) {
                final dashboard = _defaultDashboards[index];
                final isSelected = _selectedDashboards.contains(dashboard['name']);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDashboards.remove(dashboard['name']);
                      } else if (_selectedDashboards.length < 5) {
                        _selectedDashboards.add(dashboard['name']!);
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.dashboard,
                          color: isSelected ? AppColors.primary : AppColors.textMuted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dashboard['name']!,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppColors.primary : AppColors.text,
                                ),
                              ),
                              Text(
                                dashboard['description']!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsPage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Preferences',
            style: AppTextStyles.headingLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Configure when and how you want to be notified',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 40),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive alerts for price movements, opportunities, and holder changes'),
            value: _enableNotifications,
            onChanged: (value) {
              setState(() {
                _enableNotifications = value;
              });
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Quiet Hours',
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'No notifications during these hours',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeSelector('From', _quietHoursStart, (time) {
                  setState(() {
                    _quietHoursStart = time;
                  });
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeSelector('To', _quietHoursEnd, (time) {
                  setState(() {
                    _quietHoursEnd = time;
                  });
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(String label, String time, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(time, style: AppTextStyles.bodyLarge),
        ),
      ],
    );
  }

  Widget _buildPortfolioPage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'Portfolio Setup',
            style: AppTextStyles.headingLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Connect your trading account to track real positions',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Connect Alpaca
            },
            icon: const Icon(Icons.link),
            label: const Text('Connect Alpaca Paper Trading'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // Skip portfolio setup
            },
            child: const Text('Skip for now'),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'You can always connect your portfolio later in settings. StockWatch works great for research and analysis without a connected account.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyPage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rocket_launch,
            size: 80,
            color: AppColors.success,
          ),
          const SizedBox(height: 32),
          Text(
            'You\'re All Set!',
            style: AppTextStyles.headingLarge.copyWith(
              color: AppColors.success,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your trading terminal is ready',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text(
                  'Quick Start Tips:',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTipItem('Press ⌘+K for global search'),
                _buildTipItem('Use ⌘+1-9 to switch dashboards'),
                _buildTipItem('Set price alerts on any symbol'),
                _buildTipItem('Track institutional holders'),
                _buildTipItem('Let AI learn from your trades'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildNavigationFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            OutlinedButton(
              onPressed: _previousPage,
              child: const Text('Back'),
            )
          else
            const SizedBox.shrink(),
          const Spacer(),
          ElevatedButton(
            onPressed: _currentPage == 6 ? _completeOnboarding : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(_currentPage == 6 ? 'Get Started' : 'Continue'),
          ),
        ],
      ),
    );
  }
}