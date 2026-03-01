import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';
import 'screens/main_layout.dart';
import 'services/api_client.dart';
import 'services/notification_service.dart';
import 'services/keyboard_shortcuts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService.initialize();
  
  runApp(
    const ProviderScope(
      child: StockWatchApp(),
    ),
  );
}

class StockWatchApp extends ConsumerWidget {
  const StockWatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'StockWatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      
      // Set up keyboard shortcuts globally
      shortcuts: KeyboardShortcuts.shortcuts,
      actions: KeyboardShortcuts.getActions(ref),
      
      home: const MainLayout(),
      
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Ensure text doesn't scale beyond readable sizes
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
          ),
          child: child!,
        );
      },
    );
  }
}

// Global providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

// Initialize SharedPreferences provider
final sharedPreferencesInitProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// App state providers
final currentPageProvider = StateProvider<int>((ref) => 0);

final selectedSymbolProvider = StateProvider<String?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final isSearchActiveProvider = StateProvider<bool>((ref) => false);

// Theme and UI preferences
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);

final chartTypeProvider = StateProvider<String>((ref) => 'candlestick');

final chartIntervalProvider = StateProvider<String>((ref) => '5m');

// Dashboard state
final selectedDashboardProvider = StateProvider<String?>((ref) => null);

final dashboardEditModeProvider = StateProvider<bool>((ref) => false);

// Market hours provider
final marketHoursProvider = Provider<bool>((ref) {
  // Simple market hours check - 9:30 AM to 4:00 PM ET on weekdays
  final now = DateTime.now().toUtc().subtract(const Duration(hours: 4)); // Convert to ET
  final weekday = now.weekday;
  
  // Weekend check
  if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
    return false;
  }
  
  // Time check
  final timeOfDay = now.hour * 60 + now.minute;
  const marketOpen = 9 * 60 + 30; // 9:30 AM
  const marketClose = 16 * 60; // 4:00 PM
  
  return timeOfDay >= marketOpen && timeOfDay <= marketClose;
});

// App lifecycle provider to handle background/foreground
final appLifecycleProvider = StateNotifierProvider<AppLifecycleNotifier, AppLifecycleState>(
  (ref) => AppLifecycleNotifier(ref),
);

class AppLifecycleNotifier extends StateNotifier<AppLifecycleState> with WidgetsBindingObserver {
  final Ref _ref;

  AppLifecycleNotifier(this._ref) : super(AppLifecycleState.resumed) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    this.state = state;
    
    // Handle WebSocket connections based on app state
    final apiClient = _ref.read(apiClientProvider);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // Reconnect WebSocket when app comes to foreground
        apiClient.connectWebSocket();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Keep WebSocket alive but reduce activity
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        apiClient.dispose();
        break;
    }
  }
}

// User preferences provider
final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>(
  (ref) => UserPreferencesNotifier(ref),
);

class UserPreferences {
  final String defaultChartType;
  final String defaultInterval;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final String apiBaseUrl;
  final Map<String, Map<String, dynamic>> graphOverrides;
  
  const UserPreferences({
    this.defaultChartType = 'candlestick',
    this.defaultInterval = '5m',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.apiBaseUrl = 'http://localhost:3002',
    this.graphOverrides = const {},
  });
  
  UserPreferences copyWith({
    String? defaultChartType,
    String? defaultInterval,
    bool? notificationsEnabled,
    bool? soundEnabled,
    String? apiBaseUrl,
    Map<String, Map<String, dynamic>>? graphOverrides,
  }) {
    return UserPreferences(
      defaultChartType: defaultChartType ?? this.defaultChartType,
      defaultInterval: defaultInterval ?? this.defaultInterval,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      graphOverrides: graphOverrides ?? this.graphOverrides,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'defaultChartType': defaultChartType,
      'defaultInterval': defaultInterval,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'apiBaseUrl': apiBaseUrl,
      'graphOverrides': graphOverrides,
    };
  }
  
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      defaultChartType: json['defaultChartType'] ?? 'candlestick',
      defaultInterval: json['defaultInterval'] ?? '5m',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      apiBaseUrl: json['apiBaseUrl'] ?? 'http://localhost:3002',
      graphOverrides: Map<String, Map<String, dynamic>>.from(
        json['graphOverrides'] ?? {},
      ),
    );
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final Ref _ref;

  UserPreferencesNotifier(this._ref) : super(const UserPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('user_preferences');
      
      if (prefsJson != null) {
        final Map<String, dynamic> json = Map<String, dynamic>.from(
          // In a real app, you'd use proper JSON decoding
          {'defaultChartType': prefs.getString('defaultChartType') ?? 'candlestick'}
        );
        state = UserPreferences.fromJson(json);
      }
      
      // Update API client with saved base URL
      _ref.read(apiClientProvider).updateBaseUrl(state.apiBaseUrl);
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    state = preferences;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = preferences.toJson();
      
      // Save individual preferences
      await prefs.setString('defaultChartType', preferences.defaultChartType);
      await prefs.setString('defaultInterval', preferences.defaultInterval);
      await prefs.setBool('notificationsEnabled', preferences.notificationsEnabled);
      await prefs.setBool('soundEnabled', preferences.soundEnabled);
      await prefs.setString('apiBaseUrl', preferences.apiBaseUrl);
      
      // Update API client
      await _ref.read(apiClientProvider).updateBaseUrl(preferences.apiBaseUrl);
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }
  
  Future<void> updateGraphOverride(String graphId, Map<String, dynamic> override) async {
    final newOverrides = Map<String, Map<String, dynamic>>.from(state.graphOverrides);
    newOverrides[graphId] = override;
    
    final newPreferences = state.copyWith(graphOverrides: newOverrides);
    await updatePreferences(newPreferences);
  }
  
  Map<String, dynamic>? getGraphOverride(String graphId) {
    return state.graphOverrides[graphId];
  }
}