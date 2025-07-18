import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final effectiveBackgroundColor = backgroundColor ??
        (isOutlined ? Colors.transparent : colorScheme.primary);
    final effectiveForegroundColor = foregroundColor ??
        (isOutlined ? colorScheme.primary : colorScheme.onPrimary);

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(effectiveForegroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: textTheme.labelLarge?.copyWith(
                  color: effectiveForegroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    Widget button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: effectiveForegroundColor,
              side: BorderSide(
                color: effectiveForegroundColor.withValues(alpha: 0.8),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
            ),
            child: buttonChild,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: effectiveBackgroundColor,
              foregroundColor: effectiveForegroundColor,
              elevation: 2,
              shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
            ),
            child: buttonChild,
          );

    if (width != null || height != null) {
      button = SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return button;
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final double iconSize;
  final bool isOutlined;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 48,
    this.iconSize = 24,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor = backgroundColor ??
        (isOutlined ? Colors.transparent : colorScheme.primaryContainer);
    final effectiveForegroundColor = foregroundColor ??
        (isOutlined ? colorScheme.primary : colorScheme.onPrimaryContainer);

    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(size / 4),
        border: isOutlined
            ? Border.all(
                color: effectiveForegroundColor.withValues(alpha: 0.5),
                width: 1,
              )
            : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: iconSize,
          color: effectiveForegroundColor,
        ),
        tooltip: tooltip,
        splashRadius: size / 2,
      ),
    );

    return button;
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isExtended;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.isExtended = false,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
    final effectiveForegroundColor = foregroundColor ?? colorScheme.onPrimary;

    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        tooltip: tooltip,
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: effectiveForegroundColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon),
    );
  }
}
