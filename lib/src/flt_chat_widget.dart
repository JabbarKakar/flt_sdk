import 'package:flutter/material.dart';
import 'package:flt_sdk/flt_sdk.dart';
import 'package:flt_sdk/src/flt_chat_screen.dart';

class FLTChatWidget extends StatefulWidget {
  final String? initialMessage;
  final VoidCallback? onChatClosed;

  const FLTChatWidget({
    Key? key,
    this.initialMessage,
    this.onChatClosed,
  }) : super(key: key);

  @override
  _FLTChatWidgetState createState() => _FLTChatWidgetState();
}

class _FLTChatWidgetState extends State<FLTChatWidget> {
  @override
  Widget build(BuildContext context) {
    final config = FLTSDK.config;

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: config.primaryColor ?? AppColors.primaryColorLite,
          brightness: Brightness.light,
          primary: config.primaryColor ?? AppColors.primaryColorLite,
          secondary: config.secondaryColor ?? AppColors.musteredColor,
          surface: AppColors.whiteColor,
          background: config.backgroundColor ?? AppColors.whiteColor,
          onPrimary: AppColors.whiteColor,
          onSecondary: AppColors.whiteColor,
          onSurface: AppColors.blackColor,
          onBackground: AppColors.blackColor,
          error: AppColors.errorColor,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: config.backgroundColor ?? AppColors.whiteColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: config.primaryColor ?? AppColors.primaryColorLite,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    config.logoPath ?? 'assets/images/new_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.confirmation_num,
                        color: Colors.white,
                        size: 24,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                config.appName ?? 'FLT Agent',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              widget.onChatClosed?.call();
            },
          ),
        ),
        body: FLTChatScreen(
          initialMessage: widget.initialMessage,
          onChatClosed: widget.onChatClosed,
        ),
      ),
    
    
    );
  }
}