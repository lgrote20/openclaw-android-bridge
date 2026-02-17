import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  final _tokenController = TextEditingController();
  final _keywordController = TextEditingController();
  List<String> _keywords = [];
  bool _isForeground = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _urlController.text = prefs.getString(Constants.prefsBaseUrl) ?? '';
      _tokenController.text = prefs.getString(Constants.prefsAuthToken) ?? '';
      _keywords = prefs.getStringList(Constants.prefsKeywords) ?? [];
      _isForeground = prefs.getBool(Constants.prefsIsForeground) ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.prefsBaseUrl, _urlController.text.trim());
    await prefs.setString(Constants.prefsAuthToken, _tokenController.text.trim());
    await prefs.setStringList(Constants.prefsKeywords, _keywords);
    await prefs.setBool(Constants.prefsIsForeground, _isForeground);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  void _addKeyword() {
    final text = _keywordController.text.trim();
    if (text.isNotEmpty && !_keywords.contains(text)) {
      setState(() {
        _keywords.add(text);
        _keywordController.clear();
      });
    }
  }

  void _removeKeyword(String keyword) {
    setState(() {
      _keywords.remove(keyword);
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
            Text('Server Configuration',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                hintText: 'https://your-openclaw-instance.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Bearer Token',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const Divider(height: 32),
            Text('Service Settings',
                style: Theme.of(context).textTheme.titleMedium),
            SwitchListTile(
              title: const Text('Foreground Service'),
              subtitle: const Text(
                  'Shows a persistent notification to keep the service alive.'),
              value: _isForeground,
              onChanged: (val) => setState(() => _isForeground = val),
            ),
            ListTile(
              title: const Text('Notification Access'),
              subtitle: const Text('Required to listen for notifications.'),
              trailing: ElevatedButton(
                onPressed: () => NotificationService.requestPermissions(),
                child: const Text('Grant'),
              ),
            ),
            const Divider(height: 32),
            Text('Filter Keywords',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    decoration: const InputDecoration(
                      labelText: 'Add Keyword',
                      hintText: 'e.g. Alert',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addKeyword(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addKeyword,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _keywords
                  .map((k) => InputChip(
                        label: Text(k),
                        onDeleted: () => _removeKeyword(k),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
        ],
      ),
    );
  }
}