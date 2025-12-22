library flt_sdk;

import 'package:flutter/material.dart';
import 'src/flt_config.dart';
import 'src/flt_chat_screen.dart';
import 'src/flt_chat_button.dart';

export 'src/flt_config.dart';
export 'src/flt_chat_screen.dart';
export 'src/flt_chat_button.dart';
export 'src/constants.dart';

class FLTSDK {
  static FLTConfig? _config;

  /// Initialize the FLT SDK with required configuration
  static void init(FLTConfig config) {
    _config = config;
  }

  /// Get the current configuration
  static FLTConfig get config => _config ?? FLTConfig.defaultConfig();

  /// Creates a chat widget that can be embedded in any app
  static Widget createChatWidget({
    Key? key,
    String? initialMessage,
    VoidCallback? onChatClosed,
  }) {
    return FLTChatScreen(
      key: key,
      initialMessage: initialMessage,
      onChatClosed: onChatClosed,
    );
  }

  /// Creates a floating action button that opens the chat widget
  static Widget createChatButton({
    Key? key,
    String? initialMessage,
    VoidCallback? onChatClosed,
    Color? backgroundColor,
    Color? iconColor,
    double? size,
  }) {
    return FLTChatButton(
      key: key,
      initialMessage: initialMessage,
      onChatClosed: onChatClosed,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      size: size,
    );
  }

  /// Automatically opens the chat screen without requiring a button click
  /// Call this method to navigate to the chat screen programmatically
  static void openChatScreen(
    BuildContext context, {
    String? initialMessage,
    VoidCallback? onChatClosed,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FLTChatScreen(
          initialMessage: initialMessage,
          onChatClosed: () {
            onChatClosed?.call();
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }
}