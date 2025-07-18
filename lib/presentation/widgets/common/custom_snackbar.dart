import 'package:flutter/material.dart';

class CustomSnackBar {
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle_outline,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 6),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error_outline,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 5),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning_outlined,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info_outline,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}