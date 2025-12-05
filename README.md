# FLT SDK

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9.0+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9.0+-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**A powerful Flutter SDK for integrating chat functionality into your Flutter applications**

[Features](#-features) • [Installation](#-installation) • [Quick Start](#-quick-start) • [Documentation](#-documentation) • [Examples](#-examples)

</div>

---

## ✨ Features

- 💬 **Easy Integration** - Simple API to add chat functionality to any Flutter app
- 🎨 **Fully Customizable** - Customize colors, logos, branding, and UI components
- 🔄 **Built-in Retry Logic** - Automatic retry mechanism for failed requests
- 📱 **Multiple Widget Options** - Chat widget and floating action button
- 🎯 **Message Status Tracking** - Track message delivery (pending → sent → delivered → read)
- 📝 **Markdown Support** - Supports markdown formatting (headings, bold text)
- 🌙 **Theme Support** - Light and dark mode support
- 🔌 **Webhook Integration** - Connect to any webhook-based chat service
- 🛡️ **Error Handling** - Comprehensive error handling and logging
- ⚡ **Lightweight** - Minimal dependencies, optimized performance

## 📦 Installation

Add FLT SDK to your `pubspec.yaml`:

```yaml
dependencies:
  flt_sdk:
    git:
      url: https://github.com/JabbarKakar/flt_sdk.git
      ref: main  # or use a specific version tag like v1.0.0
```

Then run:

```bash
flutter pub get
```

### Using a Specific Version

For production apps, it's recommended to use a specific version tag:

```yaml
dependencies:
  flt_sdk:
    git:
      url: https://github.com/JabbarKakar/flt_sdk.git
      ref: v1.0.0  # Use specific version tag
```

## 🚀 Quick Start

### Step 1: Initialize the SDK

Initialize the SDK in your app's `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flt_sdk/flt_sdk.dart';

void main() {
  // Initialize FLT SDK
  FLTSDK.init(
    FLTConfig(
      webhookUrl: 'https://your-webhook-url.com/chat',
      appName: 'My App',
      logoPath: 'assets/images/logo.png',
      primaryColor: Colors.blue,
      secondaryColor: Colors.orange,
      enableLogging: true,
    ),
  );
  
  runApp(const MyApp());
}
```

### Step 2: Use the Chat Widget

#### Option A: Full Screen Chat Widget

```dart
import 'package:flt_sdk/flt_sdk.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Support')),
      body: FLTSDK.createChatWidget(
        initialMessage: 'Hello! How can I help you?',
        onChatClosed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
```

#### Option B: Floating Action Button

```dart
import 'package:flt_sdk/flt_sdk.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My App')),
      body: Center(child: Text('Welcome')),
      floatingActionButton: FLTSDK.createChatButton(
        backgroundColor: Colors.blue,
        iconColor: Colors.white,
        size: 56.0,
        onChatClosed: () {
          print('Chat closed');
        },
      ),
    );
  }
}
```

## 📚 Documentation

### FLTSDK Class

The main entry point for the SDK.

#### Methods

##### `init(FLTConfig config)`
Initialize the SDK with configuration.

```dart
FLTSDK.init(
  FLTConfig(
    webhookUrl: 'https://your-webhook.com/chat',
    appName: 'My App',
  ),
);
```

##### `createChatWidget({Key? key, String? initialMessage, VoidCallback? onChatClosed})`
Creates a full-screen chat widget.

**Parameters:**
- `key` - Widget key
- `initialMessage` - Optional initial message to pre-fill
- `onChatClosed` - Callback when chat is closed

##### `createChatButton({Key? key, String? initialMessage, VoidCallback? onChatClosed, Color? backgroundColor, Color? iconColor, double? size})`
Creates a floating action button that opens the chat.

**Parameters:**
- `key` - Widget key
- `initialMessage` - Optional initial message to pre-fill
- `onChatClosed` - Callback when chat is closed
- `backgroundColor` - Button background color
- `iconColor` - Icon color
- `size` - Button size (default: 56.0)

##### `config`
Get the current SDK configuration.

```dart
final config = FLTSDK.config;
print(config.appName);
```

### FLTConfig Class

Configuration class for customizing the SDK behavior.

#### Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `webhookUrl` | `String?` | Webhook endpoint URL | Required |
| `appName` | `String?` | App name displayed in header | `'FLT Agent'` |
| `logoPath` | `String?` | Path to logo asset | `'assets/images/new_logo.png'` |
| `primaryColor` | `Color?` | Primary theme color | `Color(0xff283B8C)` |
| `secondaryColor` | `Color?` | Secondary theme color | `Color(0xffFCB41A)` |
| `backgroundColor` | `Color?` | Background color | `Colors.white` |
| `showAppBar` | `bool?` | Show/hide app bar | `true` |
| `enableDarkMode` | `bool?` | Enable dark mode | `false` |
| `customHeaders` | `Map<String, dynamic>?` | Custom HTTP headers | `{}` |
| `maxRetryAttempts` | `int?` | Max retry attempts | `2` |
| `retryDelay` | `Duration?` | Delay between retries | `2 seconds` |
| `enableLogging` | `bool?` | Enable debug logging | `true` |

#### Example Configuration

```dart
FLTConfig(
  webhookUrl: 'https://api.example.com/webhook/chat',
  appName: 'Customer Support',
  logoPath: 'assets/images/my_logo.png',
  primaryColor: Colors.blue,
  secondaryColor: Colors.orange,
  backgroundColor: Colors.white,
  showAppBar: true,
  enableDarkMode: false,
  customHeaders: {
    'Authorization': 'Bearer YOUR_TOKEN',
    'X-API-Key': 'YOUR_API_KEY',
  },
  maxRetryAttempts: 3,
  retryDelay: Duration(seconds: 3),
  enableLogging: false, // Disable in production
)
```

#### Factory Methods

##### `FLTConfig.defaultConfig()`
Returns a configuration with default values.

```dart
final config = FLTConfig.defaultConfig();
```

##### `copyWith({...})`
Creates a copy of the configuration with updated values.

```dart
final newConfig = config.copyWith(
  appName: 'New App Name',
  primaryColor: Colors.red,
);
```

## 🔌 Webhook API Format

Your webhook endpoint should accept POST requests with the following format:

### Request Format

```json
{
  "action": "sendMessage",
  "chatInput": "User's message here"
}
```

### Response Format

```json
{
  "output": "Assistant's response here"
}
```

### Example Webhook Implementation

```dart
// Your webhook should return:
{
  "output": "Hello! How can I assist you today?"
}
```

## 🎨 Customization Examples

### Custom Colors

```dart
FLTSDK.init(
  FLTConfig(
    webhookUrl: 'https://your-webhook.com/chat',
    primaryColor: Color(0xFF6200EE),
    secondaryColor: Color(0xFF03DAC6),
    backgroundColor: Color(0xFFF5F5F5),
  ),
);
```

### Custom Logo and Branding

```dart
FLTSDK.init(
  FLTConfig(
    webhookUrl: 'https://your-webhook.com/chat',
    appName: 'My Company Support',
    logoPath: 'assets/images/company_logo.png',
  ),
);
```

### Custom Headers for Authentication

```dart
FLTSDK.init(
  FLTConfig(
    webhookUrl: 'https://your-webhook.com/chat',
    customHeaders: {
      'Authorization': 'Bearer YOUR_AUTH_TOKEN',
      'X-Client-ID': 'YOUR_CLIENT_ID',
    },
  ),
);
```

## 📱 Examples

Check out the complete example app in the [`example`](example) directory.

To run the example:

```bash
cd example
flutter run
```

## 🛠️ Requirements

- Flutter SDK: `>=3.9.0`
- Dart SDK: `^3.9.0`

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

- **GitHub Issues**: [Report an issue](https://github.com/JabbarKakar/flt_sdk/issues)
- **Repository**: [https://github.com/JabbarKakar/flt_sdk](https://github.com/JabbarKakar/flt_sdk)

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and version history.

---

<div align="center">

Made with ❤️ for Flutter developers

[⭐ Star on GitHub](https://github.com/JabbarKakar/flt_sdk) • [📖 Documentation](#-documentation) • [🐛 Report Bug](https://github.com/JabbarKakar/flt_sdk/issues)

</div>
