import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flt_sdk/flt_sdk.dart';

class FLTChatScreen extends StatefulWidget {
  final String? initialMessage;
  final VoidCallback? onChatClosed;

  const FLTChatScreen({
    super.key,
    this.initialMessage,
    this.onChatClosed,
  });

  @override
  FLTChatScreenState createState() => FLTChatScreenState();
}

class FLTChatScreenState extends State<FLTChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! Welcome to FLT. How can I help you with your ticket booking today?',
      'isMe': false,
      'time': _getCurrentTime(),
      'avatar': 'assets/images/agent_avatar.png',
      'status': 'read',
      'id': 'initial_message',
    },
  ];

  late String _webhookUrl;
  final Map<String, int> _retryAttempts = {};
  late int _maxRetryAttempts;

  bool _isWaitingForResponse = false;
  late AnimationController _animationController;
  late AnimationController _typingAnimationController;
  Timer? _streamingTimer;
  bool _isStreaming = false;
  final Map<String, AnimationController> _messageAnimations = {};

  static String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  void initState() {
    super.initState();

    final config = FLTSDK.config;
    _webhookUrl = config.webhookUrl ?? 'https://aidev.3utilities.com/webhook/77d24095-3bb5-4158-bfeb-63696c716758/chat';
    _maxRetryAttempts = config.maxRetryAttempts ?? 2;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();

      if (widget.initialMessage?.isNotEmpty == true) {
        _messageController.text = widget.initialMessage!;
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _typingAnimationController.dispose();
    _focusNode.dispose();
    _streamingTimer?.cancel();
    for (var controller in _messageAnimations.values) {
      controller.dispose();
    }
    _messageAnimations.clear();
    super.dispose();
  }

  void _scrollToBottom({bool smooth = true}) {
    if (_scrollController.hasClients) {
      if (smooth) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  String _addMessage(String text, bool isMe, {String status = 'pending'}) {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    // Create animation controller for this message
    final animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _messageAnimations[messageId] = animationController;

    setState(() {
      _messages.add({
        'text': text,
        'isMe': isMe,
        'time': _getCurrentTime(),
        'avatar': isMe ? null : 'assets/images/agent_avatar.png',
        'status': status,
        'id': messageId,
      });
    });

    // Animate message appearance
    animationController.forward();

    if (FLTSDK.config.enableLogging ?? true) {
      debugPrint('✅ Message added to chat: ${isMe ? "User" : "Assistant"} - $text');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return messageId;
  }

  void _updateMessageStatus(String messageId, String status) {
    setState(() {
      final index = _messages.indexWhere((msg) => msg['id'] == messageId);
      if (index != -1) {
        _messages[index]['status'] = status;
        if (FLTSDK.config.enableLogging ?? true) {
          debugPrint('📝 Message status updated: $messageId -> $status');
        }
      }
    });
  }

  void _streamText(String fullText, String messageId) {
    _streamingTimer?.cancel();
    
    setState(() {
      _isStreaming = true;
      _isWaitingForResponse = false;
    });

    int currentIndex = 0;
    const int charsPerTick = 2;
    const duration = Duration(milliseconds: 30);

    _streamingTimer = Timer.periodic(duration, (timer) {
      if (currentIndex >= fullText.length) {
        timer.cancel();
        setState(() {
          _isStreaming = false;
        });
        return;
      }

      setState(() {
        final index = _messages.indexWhere((msg) => msg['id'] == messageId);
        if (index != -1) {
          final endIndex = (currentIndex + charsPerTick).clamp(0, fullText.length);
          _messages[index]['text'] = fullText.substring(0, endIndex);
          currentIndex = endIndex;
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  Future<void> _sendMessageToWebhook(String message, String messageId, {int retryCount = 0}) async {
    _retryAttempts[messageId] = retryCount;

    try {
      if (FLTSDK.config.enableLogging ?? true) {
        debugPrint('🚀 Sending message to webhook: $message');
      }

      final config = FLTSDK.config;

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (config.customHeaders != null) {
        headers.addAll(Map<String, String>.from(config.customHeaders!));
      }

      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: headers,
        body: jsonEncode({
          'action': 'sendMessage',
          'chatInput': message,
        }),
      );

      if (FLTSDK.config.enableLogging ?? true) {
        debugPrint('📡 Response status code: ${response.statusCode}');
        debugPrint('📄 Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (FLTSDK.config.enableLogging ?? true) {
          debugPrint('🔍 Parsed response data: $responseData');
        }

        _updateMessageStatus(messageId, 'sent');

        Timer(const Duration(milliseconds: 500), () {
          _updateMessageStatus(messageId, 'delivered');
        });

        if (responseData['output'] != null && responseData['output'].isNotEmpty) {
          final assistantMessage = responseData['output'].toString();
          if (FLTSDK.config.enableLogging ?? true) {
            debugPrint('✅ Found message in "output" field: $assistantMessage');
          }

          final cleanedMessage = assistantMessage.trim();
          if (FLTSDK.config.enableLogging ?? true) {
            debugPrint('🧹 Cleaned message: $cleanedMessage');
          }

          final assistantMessageId = _addMessage('', false);
          _streamText(cleanedMessage, assistantMessageId);

          Timer(const Duration(milliseconds: 300), () {
            _updateMessageStatus(messageId, 'read');
          });
        } else {
          if (FLTSDK.config.enableLogging ?? true) {
            debugPrint('❌ No message found in response');
          }
          setState(() {
            _isWaitingForResponse = false;
          });
          _addMessage('I received your message but couldn\'t generate a response. Please try again.', false);
        }

        _retryAttempts.remove(messageId);
      } else {
        if (FLTSDK.config.enableLogging ?? true) {
          debugPrint('❌ Response status code and body: Code = ${response.statusCode} | Body = ${response.body}');
        }

        setState(() {
          _isWaitingForResponse = false;
        });

        if (retryCount < _maxRetryAttempts) {
          final delay = config.retryDelay ?? const Duration(seconds: 2);
          if (FLTSDK.config.enableLogging ?? true) {
            debugPrint('🔄 Retrying in ${delay.inSeconds} seconds (attempt ${retryCount + 1}/$_maxRetryAttempts)');
          }

          Timer(delay, () {
            _sendMessageToWebhook(message, messageId, retryCount: retryCount + 1);
          });
        } else {
          _addMessage('Service is not available. Please try again later', false);
          _retryAttempts.remove(messageId);
          _updateMessageStatus(messageId, 'failed');
        }
      }
    } catch (e) {
      if (FLTSDK.config.enableLogging ?? true) {
        debugPrint('💥 Error sending message to webhook: $e');
      }

      setState(() {
        _isWaitingForResponse = false;
      });

      final config = FLTSDK.config;
      if (retryCount < _maxRetryAttempts) {
        final delay = config.retryDelay ?? const Duration(seconds: 2);
        if (FLTSDK.config.enableLogging ?? true) {
          debugPrint('🔄 Retrying in ${delay.inSeconds} seconds (attempt ${retryCount + 1}/$_maxRetryAttempts)');
        }

        Timer(delay, () {
          _sendMessageToWebhook(message, messageId, retryCount: retryCount + 1);
        });
      } else {
        _addMessage('Service is not available. Please try again later', false);
        _retryAttempts.remove(messageId);
        _updateMessageStatus(messageId, 'failed');
      }
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = _messageController.text;
      final messageId = _addMessage(message, true, status: 'pending');

      setState(() {
        _isWaitingForResponse = true;
      });

      _sendMessageToWebhook(message, messageId);
      _messageController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  Widget _buildFormattedMessage(String text, bool isMe) {
    if (_isStructuredMessage(text)) {
      return _buildStructuredMessage(text, isMe);
    }

    return SelectableText(
      text,
      style: TextStyle(
        color: isMe ? Colors.white : Colors.black87,
        fontSize: 15.5,
        height: 1.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
    );
  }

  bool _isStructuredMessage(String text) {
    return text.contains('###') || text.contains('**');
  }

  Widget _buildStructuredMessage(String text, bool isMe) {
    final lines = text.split('\n');
    List<Widget> formattedWidgets = [];

    for (String line in lines) {
      if (line.trim().isEmpty) {
        formattedWidgets.add(const SizedBox(height: 6));
        continue;
      }

      Widget lineWidget;

      if (line.trim().startsWith('###')) {
        final heading = line.replaceAll('###', '').trim();
        lineWidget = Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Text(
            heading,
            style: TextStyle(
              color: FLTSDK.config.primaryColor ?? AppColors.primaryColorLite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.4,
              letterSpacing: 0.2,
            ),
          ),
        );
      } else if (line.contains('**')) {
        lineWidget = _buildBoldTextLine(line, isMe);
      } else {
        String cleanLine = line.replaceAll(RegExp(r'^\d+\.\s'), '').replaceAll(RegExp(r'^-\s*'), '');

        lineWidget = Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SelectableText(
            cleanLine,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 15.5,
              height: 1.5,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.15,
            ),
          ),
        );
      }

      formattedWidgets.add(lineWidget);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: formattedWidgets,
    );
  }

  Widget _buildBoldTextLine(String line, bool isMe) {
    String cleanLine = line.replaceAll(RegExp(r'^\d+\.\s'), '').replaceAll(RegExp(r'^-\s*'), '');

    List<TextSpan> spans = [];
    final parts = cleanLine.split('**');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(
            text: parts[i],
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ));
        }
      } else {
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(
            text: parts[i],
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 15.5,
              height: 1.5,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.15,
            ),
          ));
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SelectableText.rich(
        TextSpan(children: spans),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final config = FLTSDK.config;
    final primaryColor = config.primaryColor ?? AppColors.primaryColorLite;

    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _typingAnimationController,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final value = (_typingAnimationController.value + delay) % 1.0;
                    final opacity = 0.3 + 0.7 * (0.5 + 0.5 * sin(value * 2 * pi));
                    return Container(
                      margin: EdgeInsets.only(right: index < 2 ? 6.0 : 0.0),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = FLTSDK.config;
    final primaryColor = config.primaryColor ?? AppColors.primaryColorLite;

    return Scaffold(
      backgroundColor: config.backgroundColor ?? AppColors.whiteColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: config.backgroundColor ?? AppColors.whiteColor,
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  itemCount: _messages.length + (_isWaitingForResponse ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isWaitingForResponse && index == _messages.length) {
                      return _buildTypingIndicator();
                    }
                    final message = _messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
            ),
            _buildInputArea(primaryColor, config),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(Color primaryColor, FLTConfig config) {
    return Container(
      decoration: BoxDecoration(
        color: config.backgroundColor ?? AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 15.5,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _sendMessage();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withOpacity(0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: primaryColor.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;
    final status = message['status'] as String;
    final config = FLTSDK.config;
    final primaryColor = config.primaryColor ?? AppColors.primaryColorLite;
    final messageId = message['id'] as String;
    final animationController = _messageAnimations[messageId];

    Widget bubble = Container(
      margin: EdgeInsets.only(
        bottom: 12,
        top: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: isMe
                  ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                  : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isMe
                    ? LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withOpacity(0.92),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isMe ? 24 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 24),
                ),
                border: isMe
                    ? null
                    : Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: isMe
                        ? primaryColor.withOpacity(0.25)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  if (!isMe)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                ],
              ),
              child: SelectionArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFormattedMessage(message['text'] as String, isMe),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          message['time'] as String,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isMe
                                ? Colors.white.withOpacity(0.75)
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          _buildStatusIcon(status),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 10),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.9),
                    primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );

    if (animationController != null) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(isMe ? 0.3 : -0.3, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animationController,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: bubble,
        ),
      );
    }

    return bubble;
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icon(
          Icons.access_time_rounded,
          color: Colors.white.withOpacity(0.7),
          size: 14,
        );
      case 'sent':
        return Icon(
          Icons.check_rounded,
          color: Colors.white.withOpacity(0.7),
          size: 14,
        );
      case 'delivered':
        return Icon(
          Icons.done_all_rounded,
          color: Colors.white.withOpacity(0.7),
          size: 14,
        );
      case 'read':
        return const Icon(
          Icons.done_all_rounded,
          color: AppColors.musteredColor,
          size: 14,
        );
      case 'failed':
        return Icon(
          Icons.error_outline_rounded,
          color: Colors.white.withOpacity(0.7),
          size: 14,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
