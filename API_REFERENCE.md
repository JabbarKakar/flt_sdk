# API Reference

Complete API documentation for FLT SDK.

## FLTSDK

Main entry point for the FLT SDK.

### Static Methods

#### `init(FLTConfig config)`

Initializes the SDK with the provided configuration.

**Parameters:**
- `config` (FLTConfig, required): Configuration object

**Example:**
```dart
FLTSDK.init(
  FLTConfig(
    webhookUrl: 'https://api.example.com/chat',
    appName: 'My App',
  ),
);
```

---

#### `createChatWidget({Key? key, String? initialMessage, VoidCallback? onChatClosed})`

Creates a full-screen chat widget that can be embedded in your app.

**Parameters:**
- `key` (Key?, optional): Widget key
- `initialMessage` (String?, optional): Initial message to pre-fill in the input field
- `onChatClosed` (VoidCallback?, optional): Callback function called when chat is closed

**Returns:** `Widget` - A chat widget

**Example:**
```dart
FLTSDK.createChatWidget(
  initialMessage: 'Hello!',
  onChatClosed: () {
    Navigator.pop(context);
  },
)
```

---

#### `createChatButton({Key? key, String? initialMessage, VoidCallback? onChatClosed, Color? backgroundColor, Color? iconColor, double? size})`

Creates a floating action button that opens the chat widget in an overlay.

**Parameters:**
- `key` (Key?, optional): Widget key
- `initialMessage` (String?, optional): Initial message to pre-fill
- `onChatClosed` (VoidCallback?, optional): Callback when chat is closed
- `backgroundColor` (Color?, optional): Button background color (default: primary color from config)
- `iconColor` (Color?, optional): Icon color (default: white)
- `size` (double?, optional): Button size in pixels (default: 56.0)

**Returns:** `Widget` - A floating action button

**Example:**
```dart
FLTSDK.createChatButton(
  backgroundColor: Colors.blue,
  iconColor: Colors.white,
  size: 64.0,
  onChatClosed: () {
    print('Chat closed');
  },
)
```

---

#### `config` (Getter)

Gets the current SDK configuration.

**Returns:** `FLTConfig` - Current configuration (returns default config if not initialized)

**Example:**
```dart
final config = FLTSDK.config;
print('App name: ${config.appName}');
print('Webhook URL: ${config.webhookUrl}');
```

---

## FLTConfig

Configuration class for customizing SDK behavior.

### Constructor

```dart
FLTConfig({
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
})
```

### Properties

#### `webhookUrl` (String?)
Webhook endpoint URL for chat messages. **Required for functionality.**

#### `appName` (String?)
Name displayed in the chat header. Default: `'FLT Agent'`

#### `logoPath` (String?)
Path to your app logo asset. Default: `'assets/images/new_logo.png'`

#### `primaryColor` (Color?)
Primary theme color used for buttons, headers, etc. Default: `Color(0xff283B8C)`

#### `secondaryColor` (Color?)
Secondary theme color. Default: `Color(0xffFCB41A)`

#### `backgroundColor` (Color?)
Background color of the chat interface. Default: `Colors.white`

#### `showAppBar` (bool?)
Whether to show the app bar in the chat widget. Default: `true`

#### `enableDarkMode` (bool?)
Enable dark mode support. Default: `false`

#### `customHeaders` (Map<String, dynamic>?)
Custom HTTP headers to include in webhook requests. Default: `{}`

#### `maxRetryAttempts` (int?)
Maximum number of retry attempts for failed requests. Default: `2`

#### `retryDelay` (Duration?)
Delay between retry attempts. Default: `Duration(seconds: 2)`

#### `enableLogging` (bool?)
Enable debug logging. Default: `true` (set to `false` in production)

### Factory Methods

#### `FLTConfig.defaultConfig()`

Returns a configuration with default values.

**Returns:** `FLTConfig` - Default configuration

**Example:**
```dart
final config = FLTConfig.defaultConfig();
```

---

#### `copyWith({...})`

Creates a copy of the configuration with updated values.

**Parameters:** All parameters are optional and match the constructor.

**Returns:** `FLTConfig` - New configuration instance

**Example:**
```dart
final newConfig = config.copyWith(
  appName: 'New App Name',
  primaryColor: Colors.red,
);
```

---

## FLTChatWidget

Full-screen chat widget with AppBar. (Internal use - created via `FLTSDK.createChatWidget()`)

## FLTChatButton

Floating action button widget. (Internal use - created via `FLTSDK.createChatButton()`)

## FLTChatScreen

Main chat screen with message list and input. (Internal use)

## AppColors

Constants class with predefined colors.

### Static Properties

- `primaryColorLite` - Primary color: `Color(0xff283B8C)`
- `musteredColor` - Mustard color: `Color(0xffFCB41A)`
- `whiteColor` - White: `Colors.white`
- `blackColor` - Black: `Colors.black`
- `cardBackground` - Card background: `Color(0xffFAFAFA)`
- `borderColor` - Border color: `Color(0xffE0E0E0)`
- `textSecondary` - Secondary text color: `Color(0xff666666)`
- And more...

---

## Message Status Values

Messages can have the following status values:

- `'pending'` - Message is being sent
- `'sent'` - Message sent successfully
- `'delivered'` - Message delivered to server
- `'read'` - Message read (for user messages)
- `'failed'` - Message failed to send

---

## Webhook API Contract

### Request Format

```json
{
  "action": "sendMessage",
  "chatInput": "User's message text"
}
```

### Response Format

```json
{
  "output": "Assistant's response text"
}
```

### HTTP Headers

Default headers:
- `Content-Type: application/json`

Custom headers can be added via `FLTConfig.customHeaders`.

---

## Error Handling

The SDK handles errors gracefully:

1. **Network Errors**: Automatic retry with configurable attempts
2. **Invalid Responses**: Shows error message to user
3. **Timeout**: Retries with exponential backoff
4. **Invalid JSON**: Logs error and shows user-friendly message

---

## Best Practices

1. **Initialize Early**: Call `FLTSDK.init()` in `main()` before `runApp()`
2. **Use Specific Versions**: Pin to specific version tags in production
3. **Disable Logging**: Set `enableLogging: false` in production
4. **Custom Headers**: Use for authentication tokens
5. **Error Handling**: Implement `onChatClosed` callback for navigation

---

For more examples, see the [README.md](README.md) and [example](example) directory.

