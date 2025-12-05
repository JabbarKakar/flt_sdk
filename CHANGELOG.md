# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of FLT SDK
- Chat widget integration with full-screen support
- Floating action button (FAB) for quick chat access
- Webhook-based chat functionality
- Customizable UI (colors, logos, branding)
- Message status tracking (pending → sent → delivered → read)
- Retry logic for failed requests with configurable attempts and delays
- Markdown formatting support (headings with `###` and bold text with `**`)
- Theme customization (light/dark mode support)
- Custom HTTP headers support
- Debug logging with configurable enable/disable
- Comprehensive error handling
- Loading animations (wave dots) for better UX
- Auto-scroll to latest messages
- Message timestamps
- Selectable text in messages

### Features
- **FLTSDK Class**: Main entry point with `init()`, `createChatWidget()`, and `createChatButton()` methods
- **FLTConfig Class**: Comprehensive configuration options for customization
- **FLTChatWidget**: Full-screen chat widget with AppBar
- **FLTChatButton**: Floating action button that opens chat in overlay
- **FLTChatScreen**: Main chat interface with message list and input

### Technical Details
- Flutter SDK: >=3.9.0
- Dart SDK: ^3.9.0
- Dependencies: `http: ^1.1.0`
- Material Design 3 support
