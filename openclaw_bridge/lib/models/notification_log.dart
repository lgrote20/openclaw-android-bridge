import 'dart:convert';

class NotificationLog {
  final String title;
  final String body;
  final String packageName;
  final int timestamp;
  final bool success;
  final String? error;

  NotificationLog({
    required this.title,
    required this.body,
    required this.packageName,
    required this.timestamp,
    required this.success,
    this.error,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'packageName': packageName,
      'timestamp': timestamp,
      'success': success,
      'error': error,
    };
  }

  factory NotificationLog.fromMap(Map<String, dynamic> map) {
    return NotificationLog(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      packageName: map['packageName'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      success: map['success'] ?? false,
      error: map['error'],
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationLog.fromJson(String source) =>
      NotificationLog.fromMap(json.decode(source));
}
