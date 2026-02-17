import 'dart:ui';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import '../models/notification_log.dart';
import 'api_service.dart';
import 'storage_service.dart';

class NotificationService {
  /// Entry point for the background isolate.
  /// Must be static and annotated with @pragma('vm:entry-point') to prevent tree-shaking.
  @pragma('vm:entry-point')
  static void onData(NotificationEvent event) async {
    // 1. Load Keywords
    final keywords = await StorageService.getKeywords();
    
    // If no keywords are defined, we ignore everything (per spec).
    if (keywords.isEmpty) return;

    final String? title = event.title;
    final String? body = event.text; // 'text' usually contains the body content
    final String? packageName = event.packageName;
    
    // Use event timestamp or fallback to now
    final int timestamp = event.timestamp ?? DateTime.now().millisecondsSinceEpoch;

    if (title == null) return;

    // 2. Filter Logic (Case-insensitive)
    bool matchFound = false;
    for (final keyword in keywords) {
      if (title.toLowerCase().contains(keyword.toLowerCase())) {
        matchFound = true;
        break;
      }
    }

    if (!matchFound) return;

    // 3. Prepare Payload
    final payload = {
      'title': title,
      'body': body ?? '',
      'packageName': packageName ?? '',
      'timestamp': timestamp,
    };

    // 4. Send Webhook
    bool success = false;
    String? error;
    
    try {
      success = await ApiService.sendNotification(payload);
      if (!success) {
        error = "HTTP Error (Non-200 response)";
      }
    } catch (e) {
      error = e.toString();
    }

    // 5. Log to Storage
    final log = NotificationLog(
      title: title,
      body: body ?? '',
      packageName: packageName ?? '',
      timestamp: timestamp,
      success: success,
      error: error,
    );

    await StorageService.addLog(log);
  }

  static Future<void> initialize() async {
    await NotificationsListener.initialize(callbackHandle: onData);
  }

  static Future<void> startService({bool isForeground = false}) async {
    final bool? isRunning = await NotificationsListener.isRunning;
    if (isRunning != true) {
      await NotificationsListener.startService(
        foreground: isForeground,
        title: "OpenClaw Bridge",
        description: "Listening for notifications...",
      );
    }
  }

  static Future<void> stopService() async {
    await NotificationsListener.stopService();
  }

  static Future<void> requestPermissions() async {
    final bool? hasPermission = await NotificationsListener.hasPermission;
    if (hasPermission != true) {
      await NotificationsListener.openPermissionSettings();
    }
  }
  
  static Future<bool> get isRunning async {
    return (await NotificationsListener.isRunning) ?? false;
  }
}