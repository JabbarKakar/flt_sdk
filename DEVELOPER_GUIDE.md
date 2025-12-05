# Developer Guide

Welcome to FLT SDK! This guide will help you get started quickly.

## 🚀 Quick Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flt_sdk:
    git:
      url: https://github.com/JabbarKakar/flt_sdk.git
      ref: v1.0.0  # Use latest version tag
```

Run: `flutter pub get`

## 📖 Documentation Links

- **[README.md](README.md)** - Main documentation with features and quick start
- **[INSTALLATION.md](INSTALLATION.md)** - Detailed installation guide
- **[API_REFERENCE.md](API_REFERENCE.md)** - Complete API documentation
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes

## 🎯 Common Use Cases

### Use Case 1: Customer Support Chat

```dart
// Initialize in main.dart
FLTSDK.init(
  FLTConfig(
    webhookUrl: 'https://your-support-api.com/chat',
    appName: 'Customer Support',
    primaryColor: Colors.blue,
  ),
);

// Add FAB to any screen
floatingActionButton: FLTSDK.createChatButton()
```

### Use Case 2: In-App Help

```dart
// Full screen help chat
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => Scaffold(
      body: FLTSDK.createChatWidget(),
    ),
  ),
);
```

### Use Case 3: Custom Branded Chat

```dart
FLTSDK.init(
  FLTConfig(
    webhookUrl: 'https://api.example.com/chat',
    appName: 'My Company',
    logoPath: 'assets/images/logo.png',
    primaryColor: Color(0xFF6200EE),
    secondaryColor: Color(0xFF03DAC6),
    customHeaders: {
      'Authorization': 'Bearer $token',
    },
  ),
);
```

## 🔧 Configuration Tips

### Production Settings

```dart
FLTSDK.init(
  FLTConfig(
    webhookUrl: 'https://api.production.com/chat',
    enableLogging: false,  // Disable in production
    maxRetryAttempts: 3,   // More retries for production
    retryDelay: Duration(seconds: 3),
  ),
);
```

### Development Settings

```dart
FLTSDK.init(
  FLTConfig(
    webhookUrl: 'https://api.dev.com/chat',
    enableLogging: true,   // Enable for debugging
    maxRetryAttempts: 1,   // Fewer retries for faster feedback
  ),
);
```

## 🐛 Troubleshooting

### Chat not appearing?

1. Check if SDK is initialized: `FLTSDK.config`
2. Verify webhook URL is correct
3. Check network connectivity
4. Enable logging: `enableLogging: true`

### Messages not sending?

1. Check webhook URL is accessible
2. Verify webhook response format matches expected format
3. Check custom headers if using authentication
4. Review error logs with `enableLogging: true`

### Styling issues?

1. Ensure colors are valid Color objects
2. Check logo path is correct and asset is included in `pubspec.yaml`
3. Verify Material Design is enabled

## 📝 Best Practices

1. **Initialize Early**: Call `FLTSDK.init()` in `main()` before `runApp()`
2. **Use Version Tags**: Pin to specific versions in production
3. **Error Handling**: Implement `onChatClosed` callbacks
4. **Logging**: Disable in production, enable in development
5. **Custom Headers**: Use for authentication tokens
6. **Testing**: Test with your webhook before deploying

## 🔗 Resources

- **GitHub Repository**: https://github.com/JabbarKakar/flt_sdk
- **Example App**: See `example/` directory
- **Issues**: https://github.com/JabbarKakar/flt_sdk/issues

## 💡 Tips

- Use `FLTConfig.defaultConfig()` to see default values
- Use `copyWith()` to modify existing config
- Pre-fill messages with `initialMessage` parameter
- Customize FAB appearance with `backgroundColor`, `iconColor`, and `size`

## 🤝 Need Help?

- Check the [API Reference](API_REFERENCE.md)
- Review the [Example App](example/)
- Open an [Issue](https://github.com/JabbarKakar/flt_sdk/issues)

---

Happy coding! 🎉

