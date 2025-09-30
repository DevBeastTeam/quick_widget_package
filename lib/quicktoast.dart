import 'package:flutter/material.dart';

enum ToastType {
  flat,
  corner,
  rounded,
}

class Quick {
  /// Show Toast message
  static Future<void> toast({
    required BuildContext context,
    String message = "Hello from quick_widgets 🚀",
    Color backgroundColor = Colors.black87,
    int durationInSeconds = 2,
    ToastType toastType = ToastType.flat,
    double radius = 20,
    TextStyle textStyle = const TextStyle(color: Colors.white),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    bool showCloseIcon = false,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? width,
    double elevation = 6.0,
    String closeBtnLabel = "Hide",
    Function? onCloseBtnTap,
    BorderSide? border,
  }) async {
    try {
      // Hide current snackbars (clean UI)
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show new toast (Snackbar based)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: margin,
          padding: padding,
          width: width,
          elevation: elevation,
          showCloseIcon: showCloseIcon,
          action: onCloseBtnTap == null
              ? null
              : SnackBarAction(
                  label: closeBtnLabel,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  }),
          shape: toastType == ToastType.rounded
              ? RoundedRectangleBorder(
                  side: border!,
                  borderRadius: BorderRadiusGeometry.circular(radius))
              : toastType == ToastType.rounded
                  ? BeveledRectangleBorder(
                      side: border!,
                      borderRadius: BorderRadiusGeometry.circular(radius))
                  : null,
          content: Text(
            message,
            style: textStyle,
          ),
          backgroundColor: backgroundColor,
          duration: Duration(seconds: durationInSeconds),
          behavior: behavior,
        ),
      );
    } catch (e) {
      debugPrint("❌ quick_widgets Error: $e");
    }
  }
}
