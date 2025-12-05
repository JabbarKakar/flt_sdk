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
      title: 'FLT SDK Example',
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
  bool _showChat = false;

  void _toggleChat() {
    setState(() {
      _showChat = !_showChat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FLT SDK Example'),
      ),
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       const Text(
      //         'This is an example app using the FLT SDK',
      //       ),
      //       const SizedBox(height: 20),
      //       ElevatedButton(
      //         onPressed: _toggleChat,
      //         child: const Text('Open Chat'),
      //       ),
      //     ],
      //   ),
      // ),
      floatingActionButton: FLTSDK.createChatButton(
        // Removed initialMessage parameter
        onChatClosed: () {
          setState(() {
            _showChat = false;
          });
        },
      ),
      bottomSheet: _showChat
          ? Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: FLTSDK.createChatWidget(
                // Removed initialMessage parameter
                onChatClosed: () {
                  setState(() {
                    _showChat = false;
                  });
                },
              ),
            )
          : null,
    );
  }
}