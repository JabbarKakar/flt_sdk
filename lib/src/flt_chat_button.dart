import 'package:flutter/material.dart';
import 'package:flt_sdk/flt_sdk.dart';

class FLTChatButton extends StatefulWidget {
  final String? initialMessage;
  final VoidCallback? onChatClosed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const FLTChatButton({
    Key? key,
    this.initialMessage,
    this.onChatClosed,
    this.backgroundColor,
    this.iconColor,
    this.size,
  }) : super(key: key);

  @override
  _FLTChatButtonState createState() => _FLTChatButtonState();
}

class _FLTChatButtonState extends State<FLTChatButton> {
  bool _isChatOpen = false;

  void _openChat() {
    setState(() {
      _isChatOpen = true;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FLTChatScreen(
          initialMessage: widget.initialMessage,
          onChatClosed: () {
            setState(() {
              _isChatOpen = false;
            });
            widget.onChatClosed?.call();
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = FLTSDK.config;
    final size = widget.size ?? 56.0;
    final backgroundColor = widget.backgroundColor ?? (config.primaryColor ?? Colors.blue);
    final iconColor = widget.iconColor ?? Colors.white;

    return FloatingActionButton(
      onPressed: _isChatOpen ? null : _openChat,
      backgroundColor: backgroundColor,
      child: Icon(
        Icons.chat,
        color: iconColor,
        size: size * 0.5,
      ),
      tooltip: 'Open Chat',
    );
  }
}

