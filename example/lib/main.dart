import 'package:flutter/material.dart';
import 'package:flt_sdk/flt_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the SDK with custom configuration
    // FLTSDK.init(
    //   FLTConfig(
    //     appName: 'My App',
    //     primaryColor: Colors.blue,
    //     secondaryColor: Colors.orange,
    //     webhookUrl: 'https://aidev.3utilities.com/webhook/77d24095-3bb5-4158-bfeb-63696c716758/chat',
    //     enableLogging: true,
    //   ),
    // );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FLT CHAT SDK',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FLT CHAT SDK'),
      ),
      body: FLTSDK.createChatWidget(
        // Opens chat screen directly without needing the floating button
        onChatClosed: () {
          // Optionally handle close; for example, Navigator.pop(context);
        },
      ),
    );
  }
}