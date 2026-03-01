import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
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
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> showPriceAlert({
    required String symbol,
    required double price,
    required double targetPrice,
    required bool isAbove,
  }) async {
    const notificationDetails = NotificationDetails(
      macOS: DarwinNotificationDetails(
        categoryIdentifier: 'price_alert',
        subtitle: 'Price Alert',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final direction = isAbove ? 'above' : 'below';
    final formattedPrice = '\$${price.toStringAsFixed(2)}';
    final formattedTarget = '\$${targetPrice.toStringAsFixed(2)}';

    await _notifications.show(
      symbol.hashCode,
      '$symbol Price Alert',
      '$symbol is now $formattedPrice ($direction $formattedTarget)',
      notificationDetails,
    );
  }

  static Future<void> showMovementAlert({
    required String symbol,
    required double changePercent,
    required double price,
  }) async {
    const notificationDetails = NotificationDetails(
      macOS: DarwinNotificationDetails(
        categoryIdentifier: 'movement_alert',
        subtitle: 'Movement Alert',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final direction = changePercent >= 0 ? '+' : '';
    final formattedPercent = '$direction${changePercent.toStringAsFixed(2)}%';
    final formattedPrice = '\$${price.toStringAsFixed(2)}';

    await _notifications.show(
      '${symbol}_movement'.hashCode,
      '$symbol Movement Alert',
      '$symbol moved $formattedPercent to $formattedPrice',
      notificationDetails,
    );
  }

  static Future<void> showTradeNotification({
    required String type,
    required String symbol,
    required int quantity,
    required double price,
  }) async {
    const notificationDetails = NotificationDetails(
      macOS: DarwinNotificationDetails(
        categoryIdentifier: 'trade_notification',
        subtitle: 'Trade Executed',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final formattedPrice = '\$${price.toStringAsFixed(2)}';

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch,
      'Trade Executed',
      '$type $quantity shares of $symbol at $formattedPrice',
      notificationDetails,
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - could navigate to specific screen
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}