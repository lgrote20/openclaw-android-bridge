import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_log.dart';
import '../utils/constants.dart';

class StorageService {
  static const int _maxLogs = 50;

  // Getters for Settings
  static Future<String?> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.prefsBaseUrl);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.prefsAuthToken);
  }

  static Future<List<String>> getKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(Constants.prefsKeywords) ?? [];
  }

  // Log Management
  static Future<void> addLog(NotificationLog log) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logs = prefs.getStringList('notification_history') ?? [];
    
    // Add new log to the beginning
    logs.insert(0, log.toJson());
    
    // Trim list to max size
    if (logs.length > _maxLogs) {
      logs = logs.sublist(0, _maxLogs);
    }
    
    await prefs.setStringList('notification_history', logs);
  }

  static Future<List<NotificationLog>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logs = prefs.getStringList('notification_history') ?? [];
    return logs.map((e) => NotificationLog.fromJson(e)).toList();
  }
  
  static Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_history');
  }
}
