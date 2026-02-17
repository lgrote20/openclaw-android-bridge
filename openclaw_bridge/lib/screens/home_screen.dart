import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_log.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isServiceRunning = false;
  List<NotificationLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final isRunning = await NotificationService.isRunning;
    final logs = await StorageService.getLogs();
    if (mounted) {
      setState(() {
        _isServiceRunning = isRunning;
        _logs = logs;
      });
    }
  }

  Future<void> _toggleService() async {
    if (_isServiceRunning) {
      await NotificationService.stopService();
    } else {
      final prefs = await SharedPreferences.getInstance();
      final isForeground = prefs.getBool(Constants.prefsIsForeground) ?? false;

      // Ensure permissions are granted before starting
      await NotificationService.requestPermissions();
      
      await NotificationService.startService(isForeground: isForeground);
    }
    
    // Slight delay to allow service state to update
    await Future.delayed(const Duration(milliseconds: 500));
    await _refreshData();
  }

  Future<void> _clearLogs() async {
    await StorageService.clearLogs();
    await _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenClaw Bridge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearLogs,
            tooltip: 'Clear History',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              _refreshData(); // Refresh state when returning from settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Service Status Card
          Card(
            margin: const EdgeInsets.all(16.0),
            color: _isServiceRunning ? Colors.green.shade100 : Colors.red.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    _isServiceRunning ? Icons.check_circle : Icons.error,
                    color: _isServiceRunning ? Colors.green : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isServiceRunning ? 'Service Running' : 'Service Stopped',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _isServiceRunning
                              ? 'Listening for notifications...'
                              : 'Tap to start listening.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isServiceRunning,
                    onChanged: (val) => _toggleService(),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activity Log',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${_logs.length} entries',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: _logs.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 64),
                        Center(child: Text('No logs found.')),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return ListTile(
                          leading: Icon(
                            log.success ? Icons.cloud_done : Icons.cloud_off,
                            color: log.success ? Colors.green : Colors.red,
                          ),
                          title: Text(log.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.body,
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              Text(
                                DateTime.fromMillisecondsSinceEpoch(log.timestamp)
                                    .toString(),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              if (log.error != null)
                                Text(
                                  log.error!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 10),
                                ),
                            ],
                          ),
                          isThreeLine: true,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}