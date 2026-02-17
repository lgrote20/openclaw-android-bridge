import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(const OpenClawBridgeApp());
}

class OpenClawBridgeApp extends StatelessWidget {
  const OpenClawBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenClaw Bridge',
      theme: ThemeData(useMaterial3: true),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      home: const HomeScreen(),
    );
  }
}