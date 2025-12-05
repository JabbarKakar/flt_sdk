# Quick Start for Developers

## Installation (Copy & Paste)

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flt_sdk:
    git:
      url: https://github.com/JabbarKakar/flt_sdk.git
      ref: v1.0.0
```

Then run:
```bash
flutter pub get
```

## Basic Usage (3 Steps)

### Step 1: Initialize

```dart
import 'package:flt_sdk/flt_sdk.dart';

void main() {
  FLTSDK.init(
    FLTConfig(
      webhookUrl: 'https://your-webhook-url.com/chat',
      appName: 'My App',
    ),
  );
  runApp(MyApp());
}
```

### Step 2: Add Chat Button

```dart
floatingActionButton: FLTSDK.createChatButton()
```

### Step 3: Done! 🎉

That's it! Your chat is ready.

## Full Example

```dart
import 'package:flutter/material.dart';
import 'package:flt_sdk/flt_sdk.dart';

void main() {
  FLTSDK.init(
    FLTConfig(
      webhookUrl: 'https://api.example.com/chat',
      appName: 'My App',
      primaryColor: Colors.blue,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('My App')),
        body: Center(child: Text('Welcome')),
        floatingActionButton: FLTSDK.createChatButton(),
      ),
    );
  }
}
```

## Need More?

- 📖 [Full Documentation](README.md)
- 🔧 [API Reference](API_REFERENCE.md)
- 💻 [Example App](example/)

