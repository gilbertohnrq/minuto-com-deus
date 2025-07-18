import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          initialValue: widget.initialValue,
          controller: widget.controller,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
          onTap: widget.onTap,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          textCapitalization: widget.textCapitalization,
          style: textTheme.bodyLarge?.copyWith(
            color: widget.enabled
                ? colorScheme.onSurface
                : colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            prefixText: widget.prefixText,
            suffixText: widget.suffixText,
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            filled: true,
            fillColor: widget.enabled
                ? colorScheme.surface
                : colorScheme.surface.withValues(alpha: 0.5),
            counterStyle: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            errorStyle: textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomPasswordField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;

  const CustomPasswordField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label ?? 'Senha',
      hint: hint ?? 'Digite sua senha',
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      textInputAction: textInputAction,
      focusNode: focusNode,
      autofocus: autofocus,
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
      prefixIcon: const Icon(Icons.lock_outline),
    );
  }
}

class CustomEmailField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;

  const CustomEmailField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label ?? 'E-mail',
      hint: hint ?? 'Digite seu e-mail',
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      textInputAction: textInputAction,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      prefixIcon: const Icon(Icons.email_outlined),
    );
  }
}

class CustomNameField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;

  const CustomNameField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label ?? 'Nome',
      hint: hint ?? 'Digite seu nome',
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      textInputAction: textInputAction,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      prefixIcon: const Icon(Icons.person_outline),
    );
  }
}
