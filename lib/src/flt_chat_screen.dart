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
  Timer? _streamingTimer;
  bool _isStreaming = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();

      // Only send initial message if it's not empty and not null
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
    _focusNode.dispose();
    _streamingTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _addMessage(String text, bool isMe, {String status = 'pending'}) {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

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
    const int charsPerTick = 2; // Number of characters to add per tick
    const duration = Duration(milliseconds: 30); // Speed of typing

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
          // Add characters up to the next position
          final endIndex = (currentIndex + charsPerTick).clamp(0, fullText.length);
          _messages[index]['text'] = fullText.substring(0, endIndex);
          currentIndex = endIndex;
        }
      });

      // Auto-scroll as text appears
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

      // Fix for the map spread operator issue
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

        // Extract message from the 'output' field
        if (responseData['output'] != null && responseData['output'].isNotEmpty) {
          final assistantMessage = responseData['output'].toString();
          if (FLTSDK.config.enableLogging ?? true) {
            debugPrint('✅ Found message in "output" field: $assistantMessage');
          }

          // Clean up the message
          final cleanedMessage = assistantMessage.trim();
          if (FLTSDK.config.enableLogging ?? true) {
            debugPrint('🧹 Cleaned message: $cleanedMessage');
          }

          // Add an empty message first, then stream the text into it
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
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
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
        formattedWidgets.add(const SizedBox(height: 4));
        continue;
      }

      Widget lineWidget;

      // Handle ### headings (markdown h3) - BLUE BOLD
      if (line.trim().startsWith('###')) {
        final heading = line.replaceAll('###', '').trim();
        lineWidget = Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            heading,
            style: TextStyle(
              color: FLTSDK.config.primaryColor ?? AppColors.primaryColorLite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.4,
              letterSpacing: 0.3,
            ),
          ),
        );
      }
      // Handle lines with **bold** text - BLACK BOLD
      else if (line.contains('**')) {
        lineWidget = _buildBoldTextLine(line, isMe);
      }
      // All other text - remove markdown formatting and display as regular text
      else {
        // Remove any markdown formatting that might be present
        String cleanLine = line.replaceAll(RegExp(r'^\d+\.\s'), '').replaceAll(RegExp(r'^-\s*'), '');

        lineWidget = Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: SelectableText(
            cleanLine,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
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
    // Remove any list markers first
    String cleanLine = line.replaceAll(RegExp(r'^\d+\.\s'), '').replaceAll(RegExp(r'^-\s*'), '');

    List<TextSpan> spans = [];
    final parts = cleanLine.split('**');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        // Odd indices are bold text (between **)
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(
            text: parts[i],
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ));
        }
      } else {
        // Even indices are regular text
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(
            text: parts[i],
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ));
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: SelectableText.rich(
        TextSpan(
          children: spans,
        ),
      ),
    );
  }


  Widget _buildWaveDots() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FLTSDK.config.primaryColor ?? AppColors.primaryColorLite,
                  (FLTSDK.config.primaryColor ?? AppColors.primaryColorLite).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (FLTSDK.config.primaryColor ?? AppColors.primaryColorLite).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade50,
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final value = (_animationController.value + delay) % 1.0;
                    final scale = 0.6 + 0.4 * (0.5 + 0.5 * sin(value * 2 * pi));
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        margin: EdgeInsets.only(right: index < 2 ? 6.0 : 0.0),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              FLTSDK.config.primaryColor ?? AppColors.primaryColorLite,
                              (FLTSDK.config.primaryColor ?? AppColors.primaryColorLite).withOpacity(0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (FLTSDK.config.primaryColor ?? AppColors.primaryColorLite).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
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

    return SafeArea(

      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: config.backgroundColor ?? AppColors.whiteColor,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isWaitingForResponse ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isWaitingForResponse && index == _messages.length) {
                      return _buildWaveDots();
                    }
                    final message = _messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
      
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: config.backgroundColor ?? AppColors.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade50,
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
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
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                          onTap: () {
                            _focusNode.requestFocus();
                          },
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _sendMessage();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            config.primaryColor ?? AppColors.primaryColorLite,
                            (config.primaryColor ?? AppColors.primaryColorLite).withOpacity(0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (config.primaryColor ?? AppColors.primaryColorLite).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: (config.primaryColor ?? AppColors.primaryColorLite).withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _sendMessage,
                          borderRadius: BorderRadius.circular(28),
                          child: const Center(
                            child: Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ) ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;
    final status = message['status'] as String;
    final config = FLTSDK.config;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    config.primaryColor ?? AppColors.primaryColorLite,
                    (config.primaryColor ?? AppColors.primaryColorLite).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (config.primaryColor ?? AppColors.primaryColorLite).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                IntrinsicWidth(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: isMe
                        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                        : const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? LinearGradient(
                              colors: [
                                config.primaryColor ?? AppColors.primaryColorLite,
                                (config.primaryColor ?? AppColors.primaryColorLite).withOpacity(0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                Colors.grey.shade50,
                                Colors.white,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(isMe ? 20 : 24),
                      border: isMe
                          ? null
                          : Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: isMe
                              ? (config.primaryColor ?? AppColors.primaryColorLite).withOpacity(0.3)
                              : Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SelectionArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormattedMessage(message['text'] as String, isMe),
                          if (isMe) ...[
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    message['time'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  _buildStatusIcon(status),
                                ],
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    message['time'] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 3),
                                    _buildStatusIcon(status),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    config.primaryColor ?? AppColors.primaryColorLite,
                    (config.primaryColor ?? AppColors.primaryColorLite).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (config.primaryColor ?? AppColors.primaryColorLite).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icon(
          Icons.access_time,
          color: Colors.white.withOpacity(0.7),
          size: 12,
        );
      case 'sent':
        return Icon(
          Icons.check,
          color: Colors.white.withOpacity(0.7),
          size: 12,
        );
      case 'delivered':
        return Icon(
          Icons.done_all,
          color: Colors.white.withOpacity(0.7),
          size: 12,
        );
      case 'read':
        return const Icon(
          Icons.done_all,
          color: AppColors.musteredColor,
          size: 12,
        );
      case 'failed':
        return Icon(
          Icons.error_outline,
          color: Colors.white.withOpacity(0.7),
          size: 12,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}