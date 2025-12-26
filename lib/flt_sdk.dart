library flt_sdk;

import 'package:flt_sdk/flt_sdk.dart';
import 'package:flutter/material.dart';

export 'src/constants.dart';
export 'src/flt_chat_screen.dart';
export 'src/flt_config.dart';

class FLTSDK {
  static FLTConfig? _config;
  static void init(FLTConfig config) {
    _config = config;
  }

  static FLTConfig get config => _config ?? FLTConfig.defaultConfig();
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
}