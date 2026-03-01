import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:stockwatch/app.dart';
import 'package:stockwatch/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService.initialize();
  
  // Set up keyboard shortcuts
  LogicalKeyboardKey.enter;
  
  runApp(
    const ProviderScope(
      child: StockWatchApp(),
    ),
  );
}