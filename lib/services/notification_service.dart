import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
      
  static bool _initialized = false;
  
  static Future<void> initialize() async {
    if (_initialized) return;
    
    // Initialize settings for macOS
    const macOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      macOS: macOSSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    
    // Request permissions on macOS
    if (Platform.isMacOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    
    _initialized = true;
  }
  
  static void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
    // TODO: Navigate to relevant screen based on payload
  }
  
  // Show price alert notification
  static Future<void> showPriceAlert({
    required String symbol,
    required double price,
    required String condition,
  }) async {
    const details = NotificationDetails(
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        categoryIdentifier: 'PRICE_ALERT',
      ),
    );
    
    await _notifications.show(
      symbol.hashCode,
      'Price Alert: $symbol',
      '$symbol $condition \$${price.toStringAsFixed(2)}',
      details,
      payload: 'price_alert:$symbol',
    );
  }
  
  // Show opportunity notification
  static Future<void> showOpportunity({
    required String title,
    required String description,
    String? symbol,
  }) async {
    const details = NotificationDetails(
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        categoryIdentifier: 'OPPORTUNITY',
      ),
    );
    
    await _notifications.show(
      title.hashCode,
      'Opportunity: $title',
      description,
      details,
      payload: 'opportunity:${symbol ?? ''}',
    );
  }
  
  // Show holder movement notification
  static Future<void> showHolderMovement({
    required String holder,
    required String symbol,
    required String action,
    required double shares,
  }) async {
    const details = NotificationDetails(
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        categoryIdentifier: 'HOLDER_MOVEMENT',
      ),
    );
    
    final shareText = shares > 1000000 
        ? '${(shares / 1000000).toStringAsFixed(1)}M shares'
        : shares > 1000 
            ? '${(shares / 1000).toStringAsFixed(1)}K shares'
            : '${shares.toInt()} shares';
    
    await _notifications.show(
      '$holder-$symbol'.hashCode,
      'Holder Alert: $holder',
      '$action $shareText of $symbol',
      details,
      payload: 'holder:$symbol',
    );
  }
  
  // Show news notification
  static Future<void> showNews({
    required String headline,
    required String summary,
    String? symbol,
  }) async {
    const details = NotificationDetails(
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        categoryIdentifier: 'NEWS',
      ),
    );
    
    await _notifications.show(
      headline.hashCode,
      'News Alert',
      headline,
      details,
      payload: 'news:${symbol ?? ''}',
    );
  }
  
  // Cancel notification
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
  
  // Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}