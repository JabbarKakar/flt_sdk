import 'package:flutter/material.dart';
import 'package:flt_sdk/src/constants.dart';

class FLTConfig {
  final String? webhookUrl;
  final String? appName;
  final String? logoPath;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? backgroundColor;
  final bool? showAppBar;
  final bool? enableDarkMode;
  final Map<String, dynamic>? customHeaders;
  final int? maxRetryAttempts;
  final Duration? retryDelay;
  final bool? enableLogging;

  FLTConfig({
    this.webhookUrl,
    this.appName,
    this.logoPath,
    this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
    this.showAppBar,
    this.enableDarkMode,
    this.customHeaders,
    this.maxRetryAttempts,
    this.retryDelay,
    this.enableLogging,
  });

  factory FLTConfig.defaultConfig() {
    return FLTConfig(
      webhookUrl: 'https://aidevv.3utilities.com/webhook/74ae5e61-7fd9-4b36-a952-43b257d4644e/chat',
      appName: 'FLT Agent',
      logoPath: 'assets/images/new_logo.png',
      primaryColor: AppColors.primaryColorLite,
      secondaryColor: AppColors.musteredColor,
      backgroundColor: AppColors.whiteColor,
      showAppBar: true,
      enableDarkMode: false,
      customHeaders: const {},
      maxRetryAttempts: 2,
      retryDelay: const Duration(seconds: 2),
      enableLogging: true,
    );
  }

  FLTConfig copyWith({
    String? webhookUrl,
    String? appName,
    String? logoPath,
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    bool? showAppBar,
    bool? enableDarkMode,
    Map<String, dynamic>? customHeaders,
    int? maxRetryAttempts,
    Duration? retryDelay,
    bool? enableLogging,
  }) {
    return FLTConfig(
      webhookUrl: webhookUrl ?? this.webhookUrl,
      appName: appName ?? this.appName,
      logoPath: logoPath ?? this.logoPath,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      showAppBar: showAppBar ?? this.showAppBar,
      enableDarkMode: enableDarkMode ?? this.enableDarkMode,
      customHeaders: customHeaders ?? this.customHeaders,
      maxRetryAttempts: maxRetryAttempts ?? this.maxRetryAttempts,
      retryDelay: retryDelay ?? this.retryDelay,
      enableLogging: enableLogging ?? this.enableLogging,
    );
  }
}