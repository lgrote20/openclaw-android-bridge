import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/action_model.dart';
import '../services/shortcut_service.dart';
import '../utils/constants.dart';
import 'settings_screen.dart';

class ActionListScreen extends StatefulWidget {
  const ActionListScreen({super.key});

  @override
  State<ActionListScreen> createState() => _ActionListScreenState();
}

class _ActionListScreenState extends State<ActionListScreen> {
  List<ActionModel> _actions = [];
  final ShortcutService _shortcutService = ShortcutService();

  @override
  void initState() {
    super.initState();
    _loadActions();
  }

  Future<void> _loadActions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? actionsString = prefs.getString(Constants.prefsActions);
    if (actionsString != null) {
      final List<dynamic> jsonList = jsonDecode(actionsString);
      setState(() {
        _actions = jsonList.map((e) => ActionModel.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveActions() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString =
        jsonEncode(_actions.map((e) => e.toJson()).toList());
    await prefs.setString(Constants.prefsActions, jsonString);

    // Update Android Shortcuts
    await _shortcutService.updateShortcuts(_actions);
  }

  void _addAction(String id, String label) {
    setState(() {
      _actions.add(ActionModel(id: id, label: label));
    });
    _saveActions();
  }

  void _removeAction(int index) {
    setState(() {
      _actions.removeAt(index);
    });
    _saveActions();
  }

  void _showAddActionDialog() {
    final idController = TextEditingController();
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Action'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration:
                  const InputDecoration(labelText: 'Action ID (e.g. night_mode)'),
            ),
            TextField(
              controller: labelController,
              decoration:
                  const InputDecoration(labelText: 'Label (e.g. Night Mode)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (idController.text.isNotEmpty &&
                  labelController.text.isNotEmpty) {
                _addAction(idController.text.trim(), labelController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _actions.isEmpty
          ? const Center(child: Text('No actions created yet.'))
          : ListView.builder(
              itemCount: _actions.length,
              itemBuilder: (context, index) {
                final action = _actions[index];
                return ListTile(
                  title: Text(action.label),
                  subtitle: Text('ID: ${action.id}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeAction(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddActionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}