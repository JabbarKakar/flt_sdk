library flt_sdk;

import 'package:flutter/material.dart';

export 'src/flt_config.dart';
export 'src/flt_chat_widget.dart';
export 'src/flt_chat_button.dart';
export 'src/flt_chat_screen.dart';
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
    return FLTChatWidget(
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
}