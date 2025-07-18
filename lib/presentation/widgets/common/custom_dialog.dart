import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String? title;
  final String? content;
  final Widget? contentWidget;
  final List<Widget>? actions;
  final IconData? icon;
  final Color? iconColor;
  final bool barrierDismissible;
  final EdgeInsetsGeometry? contentPadding;

  const CustomDialog({
    super.key,
    this.title,
    this.content,
    this.contentWidget,
    this.actions,
    this.icon,
    this.iconColor,
    this.barrierDismissible = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      title: title != null || icon != null
          ? Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: iconColor ?? colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                ],
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            )
          : null,
      content: contentWidget ??
          (content != null
              ? Text(
                  content!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                )
              : null),
      contentPadding: contentPadding ??
          const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
      actions: actions,
      actionsPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
    );
  }

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    IconData? icon,
    Color? iconColor,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        title: title,
        content: content,
        icon: icon,
        iconColor: iconColor,
        barrierDismissible: barrierDismissible,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
    IconData? icon,
    Color? iconColor,
    bool barrierDismissible = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        title: title,
        content: content,
        icon: icon,
        iconColor: iconColor,
        barrierDismissible: barrierDismissible,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
    bool barrierDismissible = true,
  }) {
    return showInfo(
      context: context,
      title: title,
      content: content,
      buttonText: buttonText,
      icon: Icons.error_outline,
      iconColor: Theme.of(context).colorScheme.error,
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
    bool barrierDismissible = true,
  }) {
    return showInfo(
      context: context,
      title: title,
      content: content,
      buttonText: buttonText,
      icon: Icons.check_circle_outline,
      iconColor: Colors.green,
      barrierDismissible: barrierDismissible,
    );
  }
}

class LoadingDialog extends StatelessWidget {
  final String? message;

  const LoadingDialog({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: colorScheme.surface,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    String? message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}