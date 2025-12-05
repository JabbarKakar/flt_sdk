# FLT SDK

A Flutter SDK for integrating chat functionality into your Flutter applications.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flt_sdk:
    git:
      url: https://github.com/YOUR_USERNAME/flt_sdk.git
      ref: main  # or use a specific tag/commit
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize the SDK

```dart
import 'package:flt_sdk/flt_sdk.dart';

void main() {
  FLTSDK.init(
    FLTConfig(
      webhookUrl: 'https://your-webhook-url.com/chat',
      appName: 'My App',
      logoPath: 'assets/images/logo.png',
      primaryColor: Colors.blue,
      enableLogging: true,
    ),
  );
  
  runApp(MyApp());
}
```

### 2. Use the Chat Widget

#### Option A: Full Screen Chat Widget

```dart
FLTSDK.createChatWidget(
  initialMessage: 'Hello!',
  onChatClosed: () {
    print('Chat closed');
  },
)
```

#### Option B: Floating Action Button

```dart
floatingActionButton: FLTSDK.createChatButton(
  backgroundColor: Colors.blue,
  iconColor: Colors.white,
  onChatClosed: () {
    print('Chat closed');
  },
)
```

## Configuration

The `FLTConfig` class provides various configuration options:

- `webhookUrl` - Your webhook endpoint URL (required)
- `appName` - Name displayed in chat header
- `logoPath` - Path to your app logo
- `primaryColor` - Primary theme color
- `secondaryColor` - Secondary theme color
- `backgroundColor` - Background color
- `showAppBar` - Show/hide app bar
- `enableDarkMode` - Enable dark mode
- `customHeaders` - Custom HTTP headers
- `maxRetryAttempts` - Maximum retry attempts
- `retryDelay` - Delay between retries
- `enableLogging` - Enable debug logging

## Webhook API Format

**Request:**
```json
{
  "action": "sendMessage",
  "chatInput": "User's message"
}
```

**Response:**
```json
{
  "output": "Assistant's response"
}
```

## Example

See the `example` directory for a complete example app.

## License

See LICENSE file for details.
