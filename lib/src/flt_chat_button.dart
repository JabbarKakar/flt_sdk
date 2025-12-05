import 'package:flutter/material.dart';
import 'package:flt_sdk/flt_sdk.dart';
import 'package:flt_sdk/src/flt_chat_widget.dart';

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
  bool _showChat = false;
  OverlayEntry? _overlayEntry;

  void _toggleChat() {
    if (_showChat) {
      // If the chat is already shown, close it
      _overlayEntry?.remove();
      _overlayEntry = null;
      _showChat = false;
    } else {
      // Show the chat widget in an overlay
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          top: 0,
          child: FLTChatWidget(
            initialMessage: widget.initialMessage,
            onChatClosed: () {
              _overlayEntry?.remove();
              _overlayEntry = null;
              _showChat = false;
              widget.onChatClosed?.call();
            },
          ),
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);
      _showChat = true;
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = FLTSDK.config;
    final buttonSize = widget.size ?? 56.0;

    return FloatingActionButton(
      onPressed: _toggleChat,
      backgroundColor: widget.backgroundColor ?? config.primaryColor,
      child: Icon(
        Icons.chat,
        color: widget.iconColor ?? Colors.white,
      ),
    );
  }
}