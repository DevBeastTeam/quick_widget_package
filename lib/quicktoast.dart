import 'package:flutter/material.dart';

class QuickToast {
  // Base config (agar future me aur customization karna ho)
  static const String _defaultMessage = "Hello from QuickToast 🚀";

  /// Show Toast message
  static Future<void> show({
    required BuildContext context,
    String? message,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    int durationInSeconds = 2,
  }) async {
    try {
      // Hide current snackbars (clean UI)
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show new toast (Snackbar based)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message ?? _defaultMessage,
            style: TextStyle(color: textColor),
          ),
          backgroundColor: backgroundColor,
          duration: Duration(seconds: durationInSeconds),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint("❌ QuickToast Error: $e");
    }
  }
}
