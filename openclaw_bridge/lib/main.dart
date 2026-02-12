import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';
import 'screens/action_list_screen.dart';
import 'services/api_service.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(const OpenClawBridgeApp());
}

class OpenClawBridgeApp extends StatefulWidget {
  const OpenClawBridgeApp({super.key});

  @override
  State<OpenClawBridgeApp> createState() => _OpenClawBridgeAppState();
}

class _OpenClawBridgeAppState extends State<OpenClawBridgeApp> {
  final QuickActions _quickActions = const QuickActions();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _setupQuickActions();
  }

  void _setupQuickActions() {
    _quickActions.initialize((String shortcutType) {
      _handleShortcut(shortcutType);
    });
  }

  Future<void> _handleShortcut(String actionId) async {
    try {
      await _apiService.triggerAction(actionId);
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Action triggered: $actionId')),
      );
    } catch (e) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenClaw Bridge',
      theme: ThemeData(useMaterial3: true),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      home: const ActionListScreen(),
    );
  }
}