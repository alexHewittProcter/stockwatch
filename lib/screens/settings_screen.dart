import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockwatch/theme/app_theme.dart';
import 'package:stockwatch/providers/market_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _finnhubController = TextEditingController();
  final _alpacaController = TextEditingController();
  final _alphaVantageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              'API Keys',
              [
                _buildApiKeyField(
                  'Finnhub API Key',
                  'Get free key at finnhub.io',
                  _finnhubController,
                ),
                const SizedBox(height: 16),
                _buildApiKeyField(
                  'Alpaca API Key',
                  'For paper trading at alpaca.markets',
                  _alpacaController,
                ),
                const SizedBox(height: 16),
                _buildApiKeyField(
                  'Alpha Vantage API Key',
                  'For economic data at alphavantage.co',
                  _alphaVantageController,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveApiKeys,
                  child: const Text('Save API Keys'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildApiKeyField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
    );
  }

  void _saveApiKeys() {
    final finnhubKey = _finnhubController.text.trim();
    final alphaVantageKey = _alphaVantageController.text.trim();

    if (finnhubKey.isNotEmpty || alphaVantageKey.isNotEmpty) {
      ref.read(marketDataProvider.notifier).initializeWithKeys(
        finnhubApiKey: finnhubKey.isNotEmpty ? finnhubKey : null,
        alphaVantageApiKey: alphaVantageKey.isNotEmpty ? alphaVantageKey : null,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API keys saved successfully'),
          backgroundColor: AppTheme.bullGreen,
        ),
      );
    }
  }

  @override
  void dispose() {
    _finnhubController.dispose();
    _alpacaController.dispose();
    _alphaVantageController.dispose();
    super.dispose();
  }
}