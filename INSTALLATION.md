# Installation Guide

This guide will help you install and set up FLT SDK in your Flutter project.

## Prerequisites

- Flutter SDK >=3.9.0
- Dart SDK ^3.9.0
- A Flutter project

## Installation Methods

### Method 1: Git Dependency (Recommended)

Add FLT SDK to your `pubspec.yaml`:

```yaml
dependencies:
  flt_sdk:
    git:
      url: https://github.com/JabbarKakar/flt_sdk.git
      ref: main
```

For production apps, use a specific version tag:

```yaml
dependencies:
  flt_sdk:
    git:
      url: https://github.com/JabbarKakar/flt_sdk.git
      ref: v1.0.0  # Use specific version
```

### Method 2: SSH (If you have access)

```yaml
dependencies:
  flt_sdk:
    git:
      url: git@github.com:JabbarKakar/flt_sdk.git
      ref: main
```

### Method 3: Local Path (For Development)

If you've cloned the repository locally:

```yaml
dependencies:
  flt_sdk:
    path: ../flt_sdk
```

## Install Dependencies

After adding the dependency, run:

```bash
flutter pub get
```

## Verify Installation

Create a simple test to verify the SDK is installed:

```dart
import 'package:flt_sdk/flt_sdk.dart';

void main() {
  // Test import
  final config = FLTConfig.defaultConfig();
  print('FLT SDK installed successfully!');
  print('Default app name: ${config.appName}');
}
```

## Next Steps

1. **Initialize the SDK** - See [Quick Start Guide](README.md#-quick-start)
2. **Configure Webhook** - Set up your webhook URL
3. **Add Chat Widget** - Integrate chat into your app
4. **Customize** - Customize colors, logos, and branding

## Troubleshooting

### Issue: Package not found

**Solution**: Make sure the repository URL is correct and the repository is public (if using public access).

### Issue: Version conflict

**Solution**: Check your Flutter and Dart SDK versions match the requirements (Flutter >=3.9.0, Dart ^3.9.0).

### Issue: Assets not loading

**Solution**: Make sure you've added the logo asset to your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/logo.png
```

## Support

If you encounter any issues during installation, please:
1. Check the [GitHub Issues](https://github.com/JabbarKakar/flt_sdk/issues)
2. Verify your Flutter and Dart versions
3. Try running `flutter clean` and `flutter pub get` again

